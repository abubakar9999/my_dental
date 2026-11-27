import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../local/database.dart';

class SupabaseSyncService {
  final AppDatabase db;
  final bool Function() isOfflineCheck;

  bool _isSyncing = false;

  SupabaseSyncService({
    required this.db,
    required this.isOfflineCheck,
  });

  bool get isOffline => isOfflineCheck();

  Future<SupabaseClient?> _getClientIfOnline() async {
    if (isOffline) return null;
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

  /// Flushes queued local mutations to Supabase ONLY when `isOffline == false`.
  /// When `isOffline == true`, immediately returns 0 without touching Supabase.
  Future<int> flushQueue() async {
    if (isOffline || _isSyncing) return 0;

    final client = await _getClientIfOnline();
    if (client == null) return 0;

    _isSyncing = true;
    int syncedCount = 0;

    try {
      final items = await db.getPendingSyncItems();
      if (items.isEmpty) return 0;

      for (final item in items) {
        if (isOffline) break;

        final map = jsonDecode(item.payload) as Map<String, dynamic>;
        final table = item.targetTable;

        try {
          if (item.operation == 'upsert') {
            if (table == 'tooth_conditions') {
              await client
                  .from(table)
                  .upsert(map, onConflict: 'patient_id,tooth_number');
            } else {
              await client.from(table).upsert(map);
            }
          } else if (item.operation == 'delete') {
            if (table == 'tooth_conditions') {
              await client
                  .from(table)
                  .delete()
                  .eq('patient_id', map['patient_id'])
                  .eq('tooth_number', map['tooth_number']);
            } else {
              await client.from(table).delete().eq('id', map['id']);
            }
          }

          await db.deleteSyncItem(item.id);
          syncedCount++;
        } catch (e) {
          debugPrint('Supabase sync item #${item.id} ($table) failed: $e');
          // Stop on network/permission failure so ordering (e.g. patient before treatment) stays intact
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }
}
