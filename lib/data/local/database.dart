import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import '../models/clinic_models.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  Patients,
  Appointments,
  Treatments,
  Payments,
  Prescriptions,
  Investigations,
  Expenses,
  ProcedurePrices,
  ToothConditions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
          if (from < 5) {
            if (from >= 1) {
              await m.addColumn(prescriptions, prescriptions.investigations);
              await m.addColumn(prescriptions, prescriptions.nextVisitDate);
              await m.addColumn(prescriptions, prescriptions.doctorName);
            }
            await m.createTable(investigations);
            await m.createTable(expenses);
          }
          if (from < 6 && from >= 1) {
            await m.addColumn(payments, payments.discount);
            await m.addColumn(payments, payments.category);
            await m.addColumn(payments, payments.notes);
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
    final phoneVariants = <String>{clean};
    if (clean.startsWith('01') && clean.length == 11) {
      phoneVariants.add('88$clean');
      phoneVariants.add('+88$clean');
    } else if (clean.startsWith('8801') && clean.length == 13) {
      phoneVariants.add('0${clean.substring(3)}');
      phoneVariants.add('+$clean');
    } else if (clean.startsWith('+8801') && clean.length == 14) {
      phoneVariants.add(clean.substring(1));
      phoneVariants.add('0${clean.substring(4)}');
    }

    return (select(users)
          ..where((t) =>
              t.email.lower().equals(lower) | t.phone.isIn(phoneVariants))
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
    final hasDefaultDoctor = await getUserByIdentifier('doctor@dental.com') ??
        await getUserByIdentifier('01700000000');
    if (hasDefaultDoctor == null) {
      await into(users).insert(
        const UsersCompanion(
          name: Value('ডা. ডেন্টিস্ট (Admin)'),
          email: Value('doctor@dental.com'),
          phone: Value('01700000000'),
          password: Value('123456'),
          role: Value('dentist'),
          isActive: Value(true),
        ),
        mode: InsertMode.insertOrIgnore,
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
    final tCost = treatments.cost.sum();
    final tQuery = selectOnly(treatments)
      ..addColumns([tCost])
      ..where(treatments.patientId.equals(patientId));
    final tResult = await tQuery.getSingle();

    final iCost = investigations.cost.sum();
    final iQuery = selectOnly(investigations)
      ..addColumns([iCost])
      ..where(investigations.patientId.equals(patientId));
    final iResult = await iQuery.getSingle();

    return (tResult.read(tCost) ?? 0.0) + (iResult.read(iCost) ?? 0.0);
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

  Future<double> getTotalDiscountForPatient(int patientId) async {
    final total = payments.discount.sum();
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
    final allTreatmentCost = costResult.read(totalCost) ?? 0.0;

    final totalInvCost = investigations.cost.sum();
    final invQuery = selectOnly(investigations)..addColumns([totalInvCost]);
    final invResult = await invQuery.getSingle();
    final allInvCost = invResult.read(totalInvCost) ?? 0.0;

    final totalPaid = payments.amount.sum();
    final totalDisc = payments.discount.sum();
    final paidQuery = selectOnly(payments)..addColumns([totalPaid, totalDisc]);
    final paidResult = await paidQuery.getSingle();
    final allPaid = paidResult.read(totalPaid) ?? 0.0;
    final allDiscount = paidResult.read(totalDisc) ?? 0.0;

    final due = (allTreatmentCost + allInvCost) - (allPaid + allDiscount);
    return due > 0 ? due : 0.0;
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
        {'name': 'ভিজিট / পরামর্শ (Visit Fee)', 'price': 1000.0},
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

  // ─── Investigations ─────────────────────────────────────

  Stream<List<Investigation>> watchInvestigationsForPatient(int patientId) =>
      (select(investigations)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<int> insertInvestigation(InvestigationsCompanion entry) =>
      into(investigations).insert(entry);

  Future<void> updateInvestigationStatus(
    int id,
    String status, {
    String? resultNotes,
  }) =>
      (update(investigations)..where((t) => t.id.equals(id))).write(
        InvestigationsCompanion(
          status: Value(status),
          resultNotes:
              resultNotes != null ? Value(resultNotes) : const Value.absent(),
        ),
      );

  Future<int> deleteInvestigation(int id) =>
      (delete(investigations)..where((t) => t.id.equals(id))).go();

  // ─── Expenses & Accounts ────────────────────────────────

  Stream<List<Expense>> watchAllExpenses() => (select(expenses)
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  Future<double> getTotalIncomeInRange(DateTime start, DateTime end) async {
    final total = payments.amount.sum();
    final query = selectOnly(payments)
      ..addColumns([total])
      ..where(payments.date.isBiggerOrEqualValue(start) &
          payments.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<double> getTotalDiscountInRange(DateTime start, DateTime end) async {
    final total = payments.discount.sum();
    final query = selectOnly(payments)
      ..addColumns([total])
      ..where(payments.date.isBiggerOrEqualValue(start) &
          payments.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<double> getTotalExpenseInRange(DateTime start, DateTime end) async {
    final total = expenses.amount.sum();
    final query = selectOnly(expenses)
      ..addColumns([total])
      ..where(expenses.date.isBiggerOrEqualValue(start) &
          expenses.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<List<PaymentWithPatient>> getPaymentsInRangeWithPatient(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await (select(payments).join([
      innerJoin(patients, patients.id.equalsExp(payments.patientId)),
    ])
          ..where(payments.date.isBiggerOrEqualValue(start) &
              payments.date.isSmallerThanValue(end))
          ..orderBy([OrderingTerm.desc(payments.date)]))
        .get();

    return rows
        .map(
          (r) => PaymentWithPatient(
            payment: r.readTable(payments),
            patient: r.readTable(patients),
          ),
        )
        .toList();
  }

  Future<List<Expense>> getExpensesInRange(DateTime start, DateTime end) =>
      (select(expenses)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  // ─── Due Patients & Due Visits ──────────────────────────

  Future<List<PatientDueSummary>> getPatientsWithDue() async {
    final allPatients = await select(patients).get();
    final allTreatments = await select(treatments).get();
    final allInvestigations = await select(investigations).get();
    final allPayments = await select(payments).get();
    final allAppts = await select(appointments).get();

    final costByPatient = <int, double>{};
    final lastVisitByPatient = <int, DateTime>{};

    void trackDate(int pid, DateTime d) {
      final prev = lastVisitByPatient[pid];
      if (prev == null || d.isAfter(prev)) {
        lastVisitByPatient[pid] = d;
      }
    }

    for (final t in allTreatments) {
      costByPatient[t.patientId] = (costByPatient[t.patientId] ?? 0.0) + t.cost;
      trackDate(t.patientId, t.date);
    }
    for (final inv in allInvestigations) {
      costByPatient[inv.patientId] =
          (costByPatient[inv.patientId] ?? 0.0) + inv.cost;
      trackDate(inv.patientId, inv.date);
    }

    final paidByPatient = <int, double>{};
    final discountByPatient = <int, double>{};
    for (final p in allPayments) {
      paidByPatient[p.patientId] = (paidByPatient[p.patientId] ?? 0.0) + p.amount;
      discountByPatient[p.patientId] =
          (discountByPatient[p.patientId] ?? 0.0) + p.discount;
    }

    for (final a in allAppts) {
      if (a.status == 'completed') {
        trackDate(a.patientId, a.appointmentDate);
      }
    }

    final dues = <PatientDueSummary>[];
    for (final patient in allPatients) {
      final cost = costByPatient[patient.id] ?? 0.0;
      final paid = paidByPatient[patient.id] ?? 0.0;
      final disc = discountByPatient[patient.id] ?? 0.0;
      final due = cost - (paid + disc);
      if (due > 0.01) {
        dues.add(
          PatientDueSummary(
            patient: patient,
            totalCost: cost,
            totalPaid: paid,
            totalDiscount: disc,
            due: due,
            lastVisitDate: lastVisitByPatient[patient.id],
          ),
        );
      }
    }

    dues.sort((a, b) => b.due.compareTo(a.due));
    return dues;
  }

  Stream<List<PatientDueSummary>> watchPatientsWithDue() {
    return customSelect(
      'SELECT 1',
      readsFrom: {patients, treatments, investigations, payments, appointments},
    ).watch().asyncMap((_) => getPatientsWithDue());
  }

  Future<List<AppointmentWithPatient>> getWaitingVisits({
    required bool overdueOnly,
  }) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final query = select(appointments).join([
      innerJoin(patients, patients.id.equalsExp(appointments.patientId)),
    ]);

    if (overdueOnly) {
      query
        ..where(appointments.status.equals('waiting') &
            appointments.appointmentDate.isSmallerThanValue(startOfToday))
        ..orderBy([OrderingTerm.desc(appointments.appointmentDate)]);
    } else {
      query
        ..where(appointments.status.equals('waiting') &
            appointments.appointmentDate.isBiggerOrEqualValue(startOfToday))
        ..orderBy([OrderingTerm.asc(appointments.appointmentDate)]);
    }

    final rows = await query.get();
    return rows
        .map(
          (r) => AppointmentWithPatient(
            appointment: r.readTable(appointments),
            patient: r.readTable(patients),
          ),
        )
        .toList();
  }

  Stream<List<AppointmentWithPatient>> watchWaitingVisits({
    required bool overdueOnly,
  }) {
    return customSelect(
      'SELECT 1',
      readsFrom: {appointments, patients},
    ).watch().asyncMap((_) => getWaitingVisits(overdueOnly: overdueOnly));
  }
}

// ─── Database Connection ─────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'my_dental.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
