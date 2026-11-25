import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  Patients,
  Appointments,
  Treatments,
  Payments,
  Prescriptions,
  ProcedurePrices,
  ToothConditions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(toothConditions);
          }
          if (from < 3) {
            await m.createTable(users);
          }
          if (from < 4 && from >= 3) {
            await m.addColumn(users, users.phone);
          }
        },
      );

  // ─── Users (Table-Based Auth System) ─────────────────────

  Stream<List<User>> watchAllUsers() => select(users).watch();

  Future<List<User>> getAllUsers() => select(users).get();

  Future<User?> getUser(int id) =>
      (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<User?> getUserByIdentifier(String identifier) {
    final clean = identifier.trim();
    final lower = clean.toLowerCase();
    return (select(users)
          ..where((t) => t.email.lower().equals(lower) | t.phone.equals(clean))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<User?> authenticateUser(String identifier, String password) async {
    final user = await getUserByIdentifier(identifier);
    if (user != null && user.isActive && user.password == password) {
      return user;
    }
    return null;
  }

  Future<void> upsertSyncedUser({
    required String name,
    String? email,
    String? phone,
    required String password,
    required String role,
  }) async {
    User? existing;
    if (phone != null && phone.trim().isNotEmpty) {
      existing = await getUserByIdentifier(phone);
    }
    if (existing == null && email != null && email.trim().isNotEmpty) {
      existing = await getUserByIdentifier(email);
    }

    if (existing != null) {
      await updateUser(
        UsersCompanion(
          id: Value(existing.id),
          name: Value(name),
          email: Value(email),
          phone: Value(phone),
          password: Value(password),
          role: Value(role),
          isActive: const Value(true),
        ),
      );
    } else {
      await insertUser(
        UsersCompanion(
          name: Value(name),
          email: Value(email),
          phone: Value(phone),
          password: Value(password),
          role: Value(role),
          isActive: const Value(true),
        ),
      );
    }
  }

  Future<int> insertUser(UsersCompanion entry) => into(users).insert(entry);

  Future<void> updateUser(UsersCompanion entry) =>
      (update(users)..where((t) => t.id.equals(entry.id.value))).write(entry);

  Future<int> deleteUser(int id) =>
      (delete(users)..where((t) => t.id.equals(id))).go();

  Future<void> seedDefaultUser() async {
    final existing = await getAllUsers();
    if (existing.isEmpty) {
      await into(users).insert(
        const UsersCompanion(
          name: Value('ডা. ডেন্টিস্ট (Admin)'),
          email: Value('doctor@dental.com'),
          phone: Value('01700000000'),
          password: Value('123456'),
          role: Value('dentist'),
          isActive: Value(true),
        ),
      );
    }
  }

  // ─── Patients ────────────────────────────────────────────

  Stream<List<Patient>> watchAllPatients() => select(patients).watch();

  Future<List<Patient>> getAllPatients() => select(patients).get();

  Future<Patient> getPatient(int id) =>
      (select(patients)..where((t) => t.id.equals(id))).getSingle();

  Future<List<Patient>> searchPatients(String query) {
    return (select(patients)
          ..where((t) =>
              t.name.like('%$query%') | t.phone.like('%$query%')))
        .get();
  }

  Future<int> insertPatient(PatientsCompanion entry) =>
      into(patients).insert(entry);

  Future<bool> updatePatient(PatientsCompanion entry) async {
    final rows = await (update(patients)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
    return rows > 0;
  }

  Future<int> deletePatient(int id) =>
      (delete(patients)..where((t) => t.id.equals(id))).go();

  Future<int> getPatientCount() async {
    final count = countAll();
    final query = selectOnly(patients)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ─── Appointments ────────────────────────────────────────

  Stream<List<Appointment>> watchAllAppointments() =>
      select(appointments).watch();

  Future<List<Appointment>> getAppointmentsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appointments)
          ..where((t) =>
              t.appointmentDate.isBiggerOrEqualValue(start) &
              t.appointmentDate.isSmallerThanValue(end))
          ..orderBy([
            (t) => OrderingTerm.asc(t.appointmentDate),
          ]))
        .get();
  }

  Stream<List<Appointment>> watchAppointmentsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appointments)
          ..where((t) =>
              t.appointmentDate.isBiggerOrEqualValue(start) &
              t.appointmentDate.isSmallerThanValue(end))
          ..orderBy([
            (t) => OrderingTerm.asc(t.appointmentDate),
          ]))
        .watch();
  }

  Future<List<Appointment>> getAppointmentsForPatient(int patientId) =>
      (select(appointments)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.appointmentDate),
            ]))
          .get();

  Future<int> insertAppointment(AppointmentsCompanion entry) =>
      into(appointments).insert(entry);

  Future<void> updateAppointmentStatus(int id, String status) =>
      (update(appointments)..where((t) => t.id.equals(id)))
          .write(AppointmentsCompanion(status: Value(status)));

  Future<int> deleteAppointment(int id) =>
      (delete(appointments)..where((t) => t.id.equals(id))).go();

  Future<int> getTodayAppointmentCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final count = countAll();
    final query = selectOnly(appointments)
      ..addColumns([count])
      ..where(appointments.appointmentDate.isBiggerOrEqualValue(start) &
          appointments.appointmentDate.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ─── Treatments ──────────────────────────────────────────

  Future<List<Treatment>> getTreatmentsForPatient(int patientId) =>
      (select(treatments)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<Treatment>> watchTreatmentsForPatient(int patientId) =>
      (select(treatments)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<int> insertTreatment(TreatmentsCompanion entry) =>
      into(treatments).insert(entry);

  Future<int> deleteTreatment(int id) =>
      (delete(treatments)..where((t) => t.id.equals(id))).go();

  Future<double> getTotalCostForPatient(int patientId) async {
    final cost = treatments.cost.sum();
    final query = selectOnly(treatments)
      ..addColumns([cost])
      ..where(treatments.patientId.equals(patientId));
    final result = await query.getSingle();
    return result.read(cost) ?? 0.0;
  }

  // ─── Payments ────────────────────────────────────────────

  Future<List<Payment>> getPaymentsForPatient(int patientId) =>
      (select(payments)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<Payment>> watchPaymentsForPatient(int patientId) =>
      (select(payments)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<int> insertPayment(PaymentsCompanion entry) =>
      into(payments).insert(entry);

  Future<int> deletePayment(int id) =>
      (delete(payments)..where((t) => t.id.equals(id))).go();

  Future<double> getTotalPaidForPatient(int patientId) async {
    final total = payments.amount.sum();
    final query = selectOnly(payments)
      ..addColumns([total])
      ..where(payments.patientId.equals(patientId));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<double> getTodayIncome() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final total = payments.amount.sum();
    final query = selectOnly(payments)
      ..addColumns([total])
      ..where(payments.date.isBiggerOrEqualValue(start) &
          payments.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<double> getMonthlyIncome() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final total = payments.amount.sum();
    final query = selectOnly(payments)
      ..addColumns([total])
      ..where(payments.date.isBiggerOrEqualValue(start) &
          payments.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<double> getTotalDues() async {
    final totalCost = treatments.cost.sum();
    final costQuery = selectOnly(treatments)..addColumns([totalCost]);
    final costResult = await costQuery.getSingle();
    final allCost = costResult.read(totalCost) ?? 0.0;

    final totalPaid = payments.amount.sum();
    final paidQuery = selectOnly(payments)..addColumns([totalPaid]);
    final paidResult = await paidQuery.getSingle();
    final allPaid = paidResult.read(totalPaid) ?? 0.0;

    return allCost - allPaid;
  }

  // ─── Prescriptions ──────────────────────────────────────

  Future<List<Prescription>> getPrescriptionsForPatient(int patientId) =>
      (select(prescriptions)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<Prescription>> watchPrescriptionsForPatient(int patientId) =>
      (select(prescriptions)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<int> insertPrescription(PrescriptionsCompanion entry) =>
      into(prescriptions).insert(entry);

  Future<int> deletePrescription(int id) =>
      (delete(prescriptions)..where((t) => t.id.equals(id))).go();

  // ─── Procedure Prices ───────────────────────────────────

  Future<List<ProcedurePrice>> getAllProcedurePrices() =>
      select(procedurePrices).get();

  Stream<List<ProcedurePrice>> watchAllProcedurePrices() =>
      select(procedurePrices).watch();

  Future<int> insertProcedurePrice(ProcedurePricesCompanion entry) =>
      into(procedurePrices).insert(entry);

  Future<void> updateProcedurePrice(ProcedurePricesCompanion entry) =>
      (update(procedurePrices)
            ..where((t) => t.id.equals(entry.id.value)))
          .write(entry);

  Future<int> deleteProcedurePrice(int id) =>
      (delete(procedurePrices)..where((t) => t.id.equals(id))).go();

  /// Seeds default procedure prices on first run
  Future<void> seedProcedurePrices() async {
    final existing = await getAllProcedurePrices();
    if (existing.isNotEmpty) return;

    await batch((b) {
      for (final proc in [
        {'name': 'স্কেলিং (Scaling)', 'price': 2000.0},
        {'name': 'ফিলিং (Filling)', 'price': 1500.0},
        {'name': 'RCT (Root Canal)', 'price': 8000.0},
        {'name': 'এক্সট্র্যাকশন (Extraction)', 'price': 1000.0},
        {'name': 'ক্রাউন (Crown)', 'price': 5000.0},
        {'name': 'ব্রিজ (Bridge)', 'price': 15000.0},
        {'name': 'ডেনচার (Denture)', 'price': 12000.0},
        {'name': 'ইমপ্লান্ট (Implant)', 'price': 35000.0},
        {'name': 'অর্থোডন্টিক্স (Orthodontics)', 'price': 50000.0},
        {'name': 'হোয়াইটেনিং (Whitening)', 'price': 5000.0},
        {'name': 'এক্স-রে (X-Ray)', 'price': 500.0},
        {'name': 'পরামর্শ (Consultation)', 'price': 500.0},
      ]) {
        b.insert(
          procedurePrices,
          ProcedurePricesCompanion.insert(
            name: proc['name'] as String,
            defaultPrice: proc['price'] as double,
          ),
        );
      }
    });
  }

  // ─── Tooth Conditions ───────────────────────────────────

  Future<List<ToothCondition>> getToothConditionsForPatient(int patientId) =>
      (select(toothConditions)..where((t) => t.patientId.equals(patientId)))
          .get();

  Stream<List<ToothCondition>> watchToothConditionsForPatient(int patientId) =>
      (select(toothConditions)..where((t) => t.patientId.equals(patientId)))
          .watch();

  Future<ToothCondition?> getToothCondition(int patientId, String toothNumber) =>
      (select(toothConditions)
            ..where((t) =>
                t.patientId.equals(patientId) &
                t.toothNumber.equals(toothNumber)))
          .getSingleOrNull();

  Future<void> setToothCondition({
    required int patientId,
    required String toothNumber,
    required String condition,
    String? surfaces,
    String? notes,
  }) async {
    final existing = await getToothCondition(patientId, toothNumber);
    if (existing != null) {
      await (update(toothConditions)..where((t) => t.id.equals(existing.id)))
          .write(ToothConditionsCompanion(
        condition: Value(condition),
        surfaces: Value(surfaces),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      await into(toothConditions).insert(
        ToothConditionsCompanion.insert(
          patientId: patientId,
          toothNumber: toothNumber,
          condition: Value(condition),
          surfaces: Value(surfaces),
          notes: Value(notes),
        ),
      );
    }
  }

  Future<void> resetToothCondition(int patientId, String toothNumber) =>
      (delete(toothConditions)
            ..where((t) =>
                t.patientId.equals(patientId) &
                t.toothNumber.equals(toothNumber)))
          .go();
}

// ─── Database Connection ─────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'my_dental.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
