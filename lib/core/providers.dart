import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'router.dart';
import '../data/local/database.dart';
import '../data/auth/auth_repository.dart';

// ─── Preferences & Database ───────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ─── Table-Based Auth (Supabase Profiles + Offline SQLite) ─────

final authRepositoryProvider = ChangeNotifierProvider<AuthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  SupabaseClient? client;
  try {
    client = Supabase.instance.client;
  } catch (_) {}
  return AuthRepository(db: db, supabase: client, prefs: prefs);
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

