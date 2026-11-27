import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../local/database.dart' as local;

class ClinicProfile {
  final int? id;
  final String fullName;
  final String role;
  final String? email;
  final String? phone;
  final String? qualification;
  final bool isOffline;

  const ClinicProfile({
    this.id,
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
    this.qualification,
    this.isOffline = false,
  });

  factory ClinicProfile.fromJson(Map<String, dynamic> json) {
    return ClinicProfile(
      id: (json['id'] as num?)?.toInt(),
      fullName: (json['full_name'] as String?) ?? 'ডা. ডেন্টিস্ট',
      role: (json['role'] as String?) ?? 'dentist',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      qualification: json['qualification'] as String?,
      isOffline: (json['is_offline'] as bool?) ?? false,
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
        'is_offline': isOffline,
      };
}

class AuthRepository extends ChangeNotifier {
  static const _sessionKey = 'clinic_logged_in_profile';

  final local.AppDatabase? db;
  final SupabaseClient? supabase;
  final SharedPreferences? prefs;
  final bool Function()? isOfflineCheck;
  final Future<void> Function(bool)? onCloudOfflineChanged;

  ClinicProfile? _currentProfile;
  String? _lastError;
  final _authStateController = StreamController<bool>.broadcast();

  AuthRepository({
    this.db,
    this.supabase,
    this.prefs,
    this.isOfflineCheck,
    this.onCloudOfflineChanged,
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

  Future<SupabaseClient?> _ensureSupabaseClient() async {
    if (supabase != null) return supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      try {
        await Supabase.initialize(
          url: AppConstants.supabaseUrl,
          anonKey: AppConstants.supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            autoRefreshToken: false,
          ),
        );
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
  }

  /// Signs in using either Phone number OR Email along with Password.
  /// Local-First to minimize Supabase API hits & cost:
  /// 1) Checks local SQLite cache first (0 network hits for returning users).
  /// 2) Falls back to a single combined `.or()` query on Supabase `public.profiles`
  ///    only when the account is not cached locally yet.
  Future<bool> signIn({
    required String identifier,
    required String password,
  }) async {
    _lastError = null;
    final cleanId = identifier.trim();
    if (cleanId.isEmpty || password.isEmpty) return false;

    local.User? localUser;
    if (db != null) {
      localUser = await db!.authenticateUser(cleanId, password);
    }

    // 1. Check Supabase `public.profiles` (1 hit on explicit login so `is_offline`
    //    and `is_active` always stay in sync with cloud profile settings).
    final client = await _ensureSupabaseClient();
    if (client != null) {
      try {
        final escaped = cleanId.replaceAll('"', '\\"');
        final filter = cleanId.contains('@')
            ? 'email.ilike."$escaped"'
            : 'phone.in.(${_phoneVariants(cleanId).map((p) => '"$p"').join(',')}),email.ilike."$escaped"';

        final query = client
            .from('profiles')
            .select()
            .or(filter)
            .limit(1)
            .maybeSingle();

        final row = localUser != null
            ? await query.timeout(const Duration(seconds: 3))
            : await query;

        if (row != null) {
          final isActive = (row['is_active'] as bool?) ?? true;
          final storedPassword = row['password'] as String?;

          if (isActive && storedPassword == password) {
            final profile = ClinicProfile.fromJson(row);
            await _setLoggedInProfile(profile);
            await onCloudOfflineChanged?.call(profile.isOffline);

            // Cache locally so future offline logins work seamlessly
            await db?.upsertSyncedUser(
              name: profile.fullName,
              email: profile.email,
              phone: profile.phone,
              password: password,
              role: profile.role,
            );
            return true;
          }
          return false;
        }
      } on PostgrestException catch (e) {
        debugPrint('Supabase Postgrest error (${e.code}): ${e.message}');
        if (e.code == '42501') {
          _lastError =
              'Supabase-এ profiles টেবিলের permission দেওয়া নেই (SQL Editor-এ GRANT রান করুন)।';
        }
      } catch (e) {
        debugPrint('Supabase table login error (falling back to local if cached): $e');
      }
    }

    // 2. Local SQLite fallback (works fully offline if already cached)
    if (localUser != null) {
      final restored = ClinicProfile.fromLocalUser(localUser);
      await _setLoggedInProfile(restored);
      return true;
    }

    return false;
  }

  /// Manual on-demand profile refresh from Supabase (1 slim query when user taps Refresh).
  Future<bool> syncProfileFromCloud() async {
    final profile = _currentProfile;
    final client = await _ensureSupabaseClient();
    if (client == null || profile == null) return false;

    final lookup = (profile.phone?.isNotEmpty == true)
        ? profile.phone!
        : (profile.email ?? '');
    if (lookup.isEmpty) return false;

    try {
      final safeId = lookup.replaceAll('"', '');
      final filter = lookup.contains('@')
          ? 'email.ilike."$safeId"'
          : 'phone.in.(${_phoneVariants(lookup).map((p) => '"${p.replaceAll('"', '')}"').join(',')}),email.ilike."$safeId"';

      final row = await client
          .from('profiles')
          .select()
          .or(filter)
          .limit(1)
          .maybeSingle();

      if (row != null && ((row['is_active'] as bool?) ?? true)) {
        final profile = ClinicProfile.fromJson(row);
        await _setLoggedInProfile(profile);
        await onCloudOfflineChanged?.call(profile.isOffline);
        return true;
      }
    } catch (e) {
      debugPrint('Profile sync failed: $e');
    }
    return false;
  }

  Future<void> signOut() async {
    _currentProfile = null;
    try {
      await prefs?.remove(_sessionKey);
    } catch (_) {}
    await onCloudOfflineChanged?.call(false);
    _authStateController.add(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
