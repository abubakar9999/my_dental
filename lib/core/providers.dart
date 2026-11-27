import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'router.dart';
import '../data/local/database.dart';
import '../data/models/clinic_models.dart';
import '../data/auth/auth_repository.dart';
import '../data/remote/supabase_sync_service.dart';

// ─── Clinic Settings (Visit Fees & Clinic Info) ───────────────

class ClinicSettingsNotifier extends ChangeNotifier {
  static const _keyFirstVisit = 'clinic_first_visit_fee';
  static const _keyFollowUp = 'clinic_follow_up_fee';
  static const _keyClinicName = 'clinic_name';
  static const _keyClinicPhone = 'clinic_phone';
  static const _keyOnlineSyncEnabled = 'clinic_online_sync_enabled';

  final SharedPreferences? prefs;
  double firstVisitFee;
  double followUpFee;
  String clinicName;
  String clinicPhone;

  /// Driven strictly by `public.profiles.is_offline` in Supabase:
  /// - `false` (default): app runs 100% offline, no sync option shown, no Supabase writes.
  /// - `true`: sync-to-online option appears in UI and local changes sync to Supabase.
  bool onlineSyncEnabled;

  ClinicSettingsNotifier(this.prefs)
      : firstVisitFee =
            prefs?.getDouble(_keyFirstVisit) ?? AppConstants.defaultFirstVisitFee,
        followUpFee =
            prefs?.getDouble(_keyFollowUp) ?? AppConstants.defaultFollowUpFee,
        clinicName = prefs?.getString(_keyClinicName) ?? 'My Dental Clinic',
        clinicPhone = prefs?.getString(_keyClinicPhone) ?? '+880 1700-000000',
        onlineSyncEnabled = prefs?.getBool(_keyOnlineSyncEnabled) ?? false;

  /// True when the app should run strictly offline without touching Supabase.
  bool get isOffline => !onlineSyncEnabled;

  Future<void> setOnlineSyncEnabled(bool value) async {
    onlineSyncEnabled = value;
    await prefs?.setBool(_keyOnlineSyncEnabled, value);
    notifyListeners();
  }

  Future<void> update({
    required double newFirstVisitFee,
    required double newFollowUpFee,
    required String newClinicName,
    required String newClinicPhone,
    bool? newOnlineSyncEnabled,
  }) async {
    firstVisitFee = newFirstVisitFee;
    followUpFee = newFollowUpFee;
    clinicName = newClinicName.trim().isEmpty ? 'My Dental Clinic' : newClinicName.trim();
    clinicPhone = newClinicPhone.trim();
    if (newOnlineSyncEnabled != null) {
      onlineSyncEnabled = newOnlineSyncEnabled;
      await prefs?.setBool(_keyOnlineSyncEnabled, onlineSyncEnabled);
    }

    await prefs?.setDouble(_keyFirstVisit, firstVisitFee);
    await prefs?.setDouble(_keyFollowUp, followUpFee);
    await prefs?.setString(_keyClinicName, clinicName);
    await prefs?.setString(_keyClinicPhone, clinicPhone);
    notifyListeners();
  }
}

final clinicSettingsProvider =
    ChangeNotifierProvider<ClinicSettingsNotifier>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ClinicSettingsNotifier(prefs);
});

// ─── Preferences & Database ───────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final databaseProvider = Provider<AppDatabase>((ref) {
  final settings = ref.read(clinicSettingsProvider);
  final db = AppDatabase(isOfflineCheck: () => settings.isOffline);
  final syncService = SupabaseSyncService(
    db: db,
    isOfflineCheck: () => settings.isOffline,
  );
  db.onLocalMutation = () {
    if (!settings.isOffline) {
      unawaited(syncService.flushQueue());
    }
  };
  ref.onDispose(() => db.close());
  return db;
});

final supabaseSyncProvider = Provider<SupabaseSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final settings = ref.read(clinicSettingsProvider);
  return SupabaseSyncService(
    db: db,
    isOfflineCheck: () => settings.isOffline,
  );
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(databaseProvider).watchPendingSyncCount();
});

// ─── Table-Based Auth (Supabase Profiles + Offline SQLite) ─────

final authRepositoryProvider = ChangeNotifierProvider<AuthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final settings = ref.read(clinicSettingsProvider);
  SupabaseClient? client;
  try {
    client = Supabase.instance.client;
  } catch (_) {}
  return AuthRepository(
    db: db,
    supabase: client,
    prefs: prefs,
    isOfflineCheck: () => settings.isOffline,
    onCloudOfflineChanged: (val) => settings.setOnlineSyncEnabled(val),
  );
});

final authStateProvider = StreamProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return createRouter(authRepo);
});

// ─── Dashboard Stats ──────────────────────────────────────────

final patientCountProvider = FutureProvider<int>((ref) {
  return ref.watch(databaseProvider).getPatientCount();
});

final todayAppointmentCountProvider = FutureProvider<int>((ref) {
  return ref.watch(databaseProvider).getTodayAppointmentCount();
});

final todayIncomeProvider = FutureProvider<double>((ref) {
  return ref.watch(databaseProvider).getTodayIncome();
});

final monthlyIncomeProvider = FutureProvider<double>((ref) {
  return ref.watch(databaseProvider).getMonthlyIncome();
});

final totalDuesProvider = FutureProvider<double>((ref) {
  return ref.watch(databaseProvider).getTotalDues();
});

// ─── Patients ─────────────────────────────────────────────────

final allPatientsProvider = StreamProvider<List<Patient>>((ref) {
  return ref.watch(databaseProvider).watchAllPatients();
});

final patientSearchProvider =
    FutureProvider.family<List<Patient>, String>((ref, query) {
  if (query.isEmpty) return ref.watch(databaseProvider).getAllPatients();
  return ref.watch(databaseProvider).searchPatients(query);
});

final patientProvider = FutureProvider.family<Patient, int>((ref, id) {
  return ref.watch(databaseProvider).getPatient(id);
});

// ─── Appointments ─────────────────────────────────────────────

final appointmentsForDateProvider =
    StreamProvider.family<List<Appointment>, DateTime>((ref, date) {
  return ref.watch(databaseProvider).watchAppointmentsForDate(date);
});

final appointmentsWithPatientForDateProvider =
    StreamProvider.family<List<AppointmentWithPatient>, DateTime>((ref, date) {
  return ref.watch(databaseProvider).watchAppointmentsWithPatientForDate(date);
});

final appointmentsForPatientProvider =
    FutureProvider.family<List<Appointment>, int>((ref, patientId) {
  return ref.watch(databaseProvider).getAppointmentsForPatient(patientId);
});

// ─── Treatments ───────────────────────────────────────────────

final treatmentsForPatientProvider =
    StreamProvider.family<List<Treatment>, int>((ref, patientId) {
  return ref.watch(databaseProvider).watchTreatmentsForPatient(patientId);
});

final totalCostForPatientProvider =
    FutureProvider.family<double, int>((ref, patientId) {
  return ref.watch(databaseProvider).getTotalCostForPatient(patientId);
});

// ─── Payments ─────────────────────────────────────────────────

final paymentsForPatientProvider =
    StreamProvider.family<List<Payment>, int>((ref, patientId) {
  return ref.watch(databaseProvider).watchPaymentsForPatient(patientId);
});

final totalPaidForPatientProvider =
    FutureProvider.family<double, int>((ref, patientId) {
  return ref.watch(databaseProvider).getTotalPaidForPatient(patientId);
});

final totalDiscountForPatientProvider =
    FutureProvider.family<double, int>((ref, patientId) {
  return ref.watch(databaseProvider).getTotalDiscountForPatient(patientId);
});

// ─── Prescriptions ────────────────────────────────────────────

final prescriptionsForPatientProvider =
    StreamProvider.family<List<Prescription>, int>((ref, patientId) {
  return ref.watch(databaseProvider).watchPrescriptionsForPatient(patientId);
});

// ─── Procedure Prices ─────────────────────────────────────────

final procedurePricesProvider = StreamProvider<List<ProcedurePrice>>((ref) {
  return ref.watch(databaseProvider).watchAllProcedurePrices();
});

// ─── Tooth Conditions (2D Dental Chart) ───────────────────────

final toothConditionsForPatientProvider =
    StreamProvider.family<List<ToothCondition>, int>((ref, patientId) {
  return ref.watch(databaseProvider).watchToothConditionsForPatient(patientId);
});

// ─── Investigations ───────────────────────────────────────────

final investigationsForPatientProvider =
    StreamProvider.family<List<Investigation>, int>((ref, patientId) {
  return ref.watch(databaseProvider).watchInvestigationsForPatient(patientId);
});

// ─── Accounts, Due & Visits ───────────────────────────────────

final patientsWithDueProvider = StreamProvider<List<PatientDueSummary>>((ref) {
  return ref.watch(databaseProvider).watchPatientsWithDue();
});

final overdueVisitsProvider =
    StreamProvider<List<AppointmentWithPatient>>((ref) {
  return ref.watch(databaseProvider).watchWaitingVisits(overdueOnly: true);
});

final upcomingVisitsProvider =
    StreamProvider<List<AppointmentWithPatient>>((ref) {
  return ref.watch(databaseProvider).watchWaitingVisits(overdueOnly: false);
});

final allExpensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(databaseProvider).watchAllExpenses();
});

