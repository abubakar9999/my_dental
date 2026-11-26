import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/database.dart' as local;

class ClinicProfile {
  final int? id;
  final String fullName;
  final String role;
  final String? email;
  final String? phone;
  final String? qualification;

  const ClinicProfile({
    this.id,
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
    this.qualification,
  });

  factory ClinicProfile.fromJson(Map<String, dynamic> json) {
    return ClinicProfile(
      id: (json['id'] as num?)?.toInt(),
      fullName: (json['full_name'] as String?) ?? 'ডা. ডেন্টিস্ট',
      role: (json['role'] as String?) ?? 'dentist',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      qualification: json['qualification'] as String?,
    );
  }

  factory ClinicProfile.fromLocalUser(local.User user) {
    return ClinicProfile(
      id: user.id,
      fullName: user.name,
      role: user.role,
      email: user.email,
      phone: user.phone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'role': role,
        'email': email,
        'phone': phone,
        'qualification': qualification,
      };
}

class AuthRepository extends ChangeNotifier {
  static const _sessionKey = 'clinic_logged_in_profile';

  final local.AppDatabase? db;
  final SupabaseClient? supabase;
  final SharedPreferences? prefs;

  ClinicProfile? _currentProfile;
  String? _lastError;
  final _authStateController = StreamController<bool>.broadcast();

  AuthRepository({
    this.db,
    this.supabase,
    this.prefs,
  }) {
    _loadSavedSession();
  }

  void _loadSavedSession() {
    try {
      final raw = prefs?.getString(_sessionKey);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _currentProfile = ClinicProfile.fromJson(map);
      }
    } catch (e) {
      debugPrint('Failed to restore saved profile session: $e');
    }
  }

  bool get isLoggedIn => _currentProfile != null;
  ClinicProfile? get currentProfile => _currentProfile;
  String? get lastError => _lastError;
  String? get currentName => _currentProfile?.fullName;
  String? get currentRole => _currentProfile?.role;
  String? get currentEmail => _currentProfile?.email;
  String? get currentPhone => _currentProfile?.phone;

  String? get currentContact {
    final phone = _currentProfile?.phone;
    if (phone != null && phone.trim().isNotEmpty) return phone;
    return _currentProfile?.email;
  }

  Stream<bool> get authStateChanges => _authStateController.stream;

  Future<void> _setLoggedInProfile(ClinicProfile profile) async {
    _currentProfile = profile;
    try {
      await prefs?.setString(_sessionKey, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('Failed to persist profile session: $e');
    }
    _authStateController.add(true);
    notifyListeners();
  }

  List<String> _phoneVariants(String clean) {
    final variants = <String>{clean};
    if (clean.startsWith('01') && clean.length == 11) {
      variants.add('88$clean');
      variants.add('+88$clean');
    } else if (clean.startsWith('8801') && clean.length == 13) {
      variants.add('0${clean.substring(3)}');
      variants.add('+$clean');
    } else if (clean.startsWith('+8801') && clean.length == 14) {
      variants.add(clean.substring(1));
      variants.add('0${clean.substring(4)}');
    }
    return variants.toList();
  }

  /// Signs in using either Phone number OR Email along with Password
  /// against the Supabase `profiles` table (with local SQLite offline fallback).
  Future<bool> signIn({
    required String identifier,
    required String password,
  }) async {
    _lastError = null;
    final cleanId = identifier.trim();
    if (cleanId.isEmpty || password.isEmpty) return false;

    // 1. Table-based lookup on Supabase `public.profiles`
    if (supabase != null) {
      try {
        Map<String, dynamic>? row;
        if (cleanId.contains('@')) {
          row = await supabase!
              .from('profiles')
              .select()
              .ilike('email', cleanId)
              .limit(1)
              .maybeSingle();
        } else {
          final phones = _phoneVariants(cleanId);
          row = await supabase!
              .from('profiles')
              .select()
              .inFilter('phone', phones)
              .limit(1)
              .maybeSingle();

          // Fallback in case identifier without '@' was stored in email
          row ??= await supabase!
              .from('profiles')
              .select()
              .ilike('email', cleanId)
              .limit(1)
              .maybeSingle();
        }

        if (row != null) {
          final isActive = (row['is_active'] as bool?) ?? true;
          final storedPassword = row['password'] as String?;

          if (storedPassword == null) {
            debugPrint('Supabase profiles table has no password column yet.');
          } else if (isActive && storedPassword == password) {
            final profile = ClinicProfile.fromJson(row);
            await _setLoggedInProfile(profile);

            // Sync user locally so subsequent offline logins also work
            await db?.upsertSyncedUser(
              name: profile.fullName,
              email: profile.email,
              phone: profile.phone,
              password: password,
              role: profile.role,
            );
            return true;
          } else {
            return false;
          }
        } else {
          // Check if profiles table has any rows at all; if it does, user doesn't exist
          final anyProfile = await supabase!
              .from('profiles')
              .select('id')
              .limit(1)
              .maybeSingle();
          if (anyProfile != null) {
            return false;
          }
        }
      } on PostgrestException catch (e) {
        debugPrint('Supabase Postgrest error (${e.code}): ${e.message}');
        if (e.code == '42501') {
          _lastError =
              'Supabase-এ profiles টেবিলের permission দেওয়া নেই (SQL Editor-এ GRANT রান করুন)।';
        }
      } catch (e) {
        debugPrint('Supabase table login error (falling back to offline DB): $e');
      }
    }

    // 2. Offline / Local SQLite fallback (`users` table)
    if (db != null) {
      final user = await db!.authenticateUser(cleanId, password);
      if (user != null) {
        _lastError = null;
        await _setLoggedInProfile(ClinicProfile.fromLocalUser(user));
        return true;
      }
    }

    return false;
  }

  Future<void> signOut() async {
    _currentProfile = null;
    try {
      await prefs?.remove(_sessionKey);
    } catch (_) {}
    _authStateController.add(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
