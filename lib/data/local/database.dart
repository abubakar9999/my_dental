import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import '../models/clinic_models.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Users, Patients, Appointments, Treatments, Payments, Prescriptions, Investigations, Expenses, ProcedurePrices, ToothConditions, SyncQueue])
class AppDatabase extends _$AppDatabase {
  /// Optional callback fired whenever local data changes and should be synced if online.
  void Function()? onLocalMutation;

  /// Returns whether the app is currently in strict Offline Mode (`isOffline == true`).
  /// When true, NO data is queued or sent to Supabase — everything stays in local SQLite.
  bool Function()? isOfflineCheck;

  AppDatabase({this.onLocalMutation, this.isOfflineCheck}) : super(_openConnection());

  AppDatabase.forTesting(super.e, {this.onLocalMutation, this.isOfflineCheck});

  bool get isOfflineMode => isOfflineCheck?.call() ?? false;

  Future<void> _enqueueIfOnline(String targetTable, String recordKey, String operation, Map<String, dynamic> payload) async {
    if (isOfflineMode) return;
    await into(syncQueue).insert(SyncQueueCompanion.insert(targetTable: targetTable, recordKey: recordKey, operation: operation, payload: jsonEncode(payload)));
    onLocalMutation?.call();
  }

  Stream<int> watchPendingSyncCount() {
    final c = countAll();
    final q = selectOnly(syncQueue)..addColumns([c]);
    return q.watchSingle().map((r) => r.read(c) ?? 0);
  }

  Future<List<SyncQueueData>> getPendingSyncItems() => (select(syncQueue)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<int> deleteSyncItem(int id) => (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<int> clearSyncQueue() => delete(syncQueue).go();

  @override
  int get schemaVersion => 7;

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
      if (from < 7) {
        await m.createTable(syncQueue);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_patients_name_phone ON patients(name, phone);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_appointments_date_status ON appointments(appointment_date, status);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_treatments_patient_date ON treatments(patient_id, date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_payments_patient_date ON payments(patient_id, date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_investigations_patient_date ON investigations(patient_id, date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_prescriptions_patient_date ON prescriptions(patient_id, date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tooth_conditions_patient ON tooth_conditions(patient_id, tooth_number);');
    },
  );

  // ─── Users (Table-Based Auth System) ─────────────────────

  Stream<List<User>> watchAllUsers() => select(users).watch();

  Future<List<User>> getAllUsers() => select(users).get();

  Future<User?> getUser(int id) => (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();

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
          ..where((t) => t.email.lower().equals(lower) | t.phone.isIn(phoneVariants))
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

  Future<void> upsertSyncedUser({required String name, String? email, String? phone, required String password, required String role}) async {
    User? existing;
    if (phone != null && phone.trim().isNotEmpty) {
      existing = await getUserByIdentifier(phone);
    }
    if (existing == null && email != null && email.trim().isNotEmpty) {
      existing = await getUserByIdentifier(email);
    }

    if (existing != null) {
      await updateUser(UsersCompanion(id: Value(existing.id), name: Value(name), email: Value(email), phone: Value(phone), password: Value(password), role: Value(role), isActive: const Value(true)));
    } else {
      await insertUser(UsersCompanion(name: Value(name), email: Value(email), phone: Value(phone), password: Value(password), role: Value(role), isActive: const Value(true)));
    }
  }

  Future<int> insertUser(UsersCompanion entry) => into(users).insert(entry);

  Future<void> updateUser(UsersCompanion entry) => (update(users)..where((t) => t.id.equals(entry.id.value))).write(entry);

  Future<int> deleteUser(int id) => (delete(users)..where((t) => t.id.equals(id))).go();

  // ─── Patients ────────────────────────────────────────────

  Stream<List<Patient>> watchAllPatients() => select(patients).watch();

  Future<List<Patient>> getAllPatients() => select(patients).get();

  Future<Patient> getPatient(int id) => (select(patients)..where((t) => t.id.equals(id))).getSingle();

  Future<List<Patient>> searchPatients(String query) {
    return (select(patients)..where((t) => t.name.like('%$query%') | t.phone.like('%$query%'))).get();
  }

  Future<int> insertPatient(PatientsCompanion entry) async {
    final id = await into(patients).insert(entry);
    final pRow = await getPatient(id);
    await _enqueueIfOnline('patients', '$id', 'upsert', {
      'id': pRow.id,
      'name': pRow.name,
      'phone': pRow.phone,
      'age': pRow.age,
      'gender': pRow.gender,
      'address': pRow.address,
      'medical_history': pRow.medicalHistory,
      'allergies': pRow.allergies,
      'created_at': pRow.createdAt.toUtc().toIso8601String(),
    });
    return id;
  }

  Future<bool> updatePatient(PatientsCompanion entry) async {
    final rows = await (update(patients)..where((t) => t.id.equals(entry.id.value))).write(entry);
    if (rows > 0) {
      final pRow = await getPatient(entry.id.value);
      await _enqueueIfOnline('patients', '${pRow.id}', 'upsert', {
        'id': pRow.id,
        'name': pRow.name,
        'phone': pRow.phone,
        'age': pRow.age,
        'gender': pRow.gender,
        'address': pRow.address,
        'medical_history': pRow.medicalHistory,
        'allergies': pRow.allergies,
        'created_at': pRow.createdAt.toUtc().toIso8601String(),
      });
    }
    return rows > 0;
  }

  Future<int> deletePatient(int id) async {
    final rows = await (delete(patients)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('patients', '$id', 'delete', {'id': id});
    }
    return rows;
  }

  Future<int> getPatientCount() async {
    final count = countAll();
    final query = selectOnly(patients)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ─── Appointments ────────────────────────────────────────

  Stream<List<Appointment>> watchAllAppointments() => select(appointments).watch();

  Future<List<Appointment>> getAppointmentsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appointments)
          ..where((t) => t.appointmentDate.isBiggerOrEqualValue(start) & t.appointmentDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.appointmentDate)]))
        .get();
  }

  Stream<List<Appointment>> watchAppointmentsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appointments)
          ..where((t) => t.appointmentDate.isBiggerOrEqualValue(start) & t.appointmentDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.appointmentDate)]))
        .watch();
  }

  Stream<List<AppointmentWithPatient>> watchAppointmentsWithPatientForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appointments).join([innerJoin(patients, patients.id.equalsExp(appointments.patientId))])
          ..where(appointments.appointmentDate.isBiggerOrEqualValue(start) & appointments.appointmentDate.isSmallerThanValue(end))
          ..orderBy([OrderingTerm.asc(appointments.appointmentDate)]))
        .watch()
        .map((rows) => rows.map((r) => AppointmentWithPatient(appointment: r.readTable(appointments), patient: r.readTable(patients))).toList());
  }

  Future<List<Appointment>> getAppointmentsForPatient(int patientId) =>
      (select(appointments)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.appointmentDate)]))
          .get();

  Future<int> insertAppointment(AppointmentsCompanion entry) async {
    final id = await into(appointments).insert(entry);
    final row = await (select(appointments)..where((t) => t.id.equals(id))).getSingle();
    await _enqueueIfOnline('appointments', '$id', 'upsert', {
      'id': row.id,
      'patient_id': row.patientId,
      'appointment_date': row.appointmentDate.toUtc().toIso8601String(),
      'status': row.status,
      'note': row.note,
      'created_at': row.createdAt.toUtc().toIso8601String(),
    });
    return id;
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    await (update(appointments)..where((t) => t.id.equals(id))).write(AppointmentsCompanion(status: Value(status)));
    final row = await (select(appointments)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      await _enqueueIfOnline('appointments', '$id', 'upsert', {
        'id': row.id,
        'patient_id': row.patientId,
        'appointment_date': row.appointmentDate.toUtc().toIso8601String(),
        'status': row.status,
        'note': row.note,
        'created_at': row.createdAt.toUtc().toIso8601String(),
      });
    }
  }

  Future<int> deleteAppointment(int id) async {
    final rows = await (delete(appointments)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('appointments', '$id', 'delete', {'id': id});
    }
    return rows;
  }

  Future<int> getTodayAppointmentCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final count = countAll();
    final query = selectOnly(appointments)
      ..addColumns([count])
      ..where(appointments.appointmentDate.isBiggerOrEqualValue(start) & appointments.appointmentDate.isSmallerThanValue(end));
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

  Future<int> insertTreatment(TreatmentsCompanion entry) async {
    final id = await into(treatments).insert(entry);
    final row = await (select(treatments)..where((t) => t.id.equals(id))).getSingle();
    await _enqueueIfOnline('treatments', '$id', 'upsert', {
      'id': row.id,
      'patient_id': row.patientId,
      'tooth_number': row.toothNumber,
      'procedure': row.procedure,
      'cost': row.cost,
      'date': row.date.toUtc().toIso8601String(),
      'notes': row.notes,
      'created_at': row.createdAt.toUtc().toIso8601String(),
    });
    return id;
  }

  Future<int> deleteTreatment(int id) async {
    final rows = await (delete(treatments)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('treatments', '$id', 'delete', {'id': id});
    }
    return rows;
  }

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

  Future<int> insertPayment(PaymentsCompanion entry) async {
    final id = await into(payments).insert(entry);
    final row = await (select(payments)..where((t) => t.id.equals(id))).getSingle();
    await _enqueueIfOnline('payments', '$id', 'upsert', {
      'id': row.id,
      'patient_id': row.patientId,
      'treatment_id': row.treatmentId,
      'amount': row.amount,
      'discount': row.discount,
      'category': row.category,
      'notes': row.notes,
      'date': row.date.toUtc().toIso8601String(),
      'method': row.method,
      'created_at': row.createdAt.toUtc().toIso8601String(),
    });
    return id;
  }

  Future<int> deletePayment(int id) async {
    final rows = await (delete(payments)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('payments', '$id', 'delete', {'id': id});
    }
    return rows;
  }

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
      ..where(payments.date.isBiggerOrEqualValue(start) & payments.date.isSmallerThanValue(end));
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
      ..where(payments.date.isBiggerOrEqualValue(start) & payments.date.isSmallerThanValue(end));
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

  dynamic _tryDecodeJson(String? raw, {dynamic fallback}) {
    if (raw == null || raw.isEmpty) return fallback;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return fallback;
    }
  }

  Future<int> insertPrescription(PrescriptionsCompanion entry) async {
    final id = await into(prescriptions).insert(entry);
    final row = await (select(prescriptions)..where((t) => t.id.equals(id))).getSingle();
    await _enqueueIfOnline('prescriptions', '$id', 'upsert', {
      'id': row.id,
      'patient_id': row.patientId,
      'doctor_name': row.doctorName,
      'date': row.date.toUtc().toIso8601String(),
      'medicines': _tryDecodeJson(row.medicines, fallback: []),
      'investigations': _tryDecodeJson(row.investigations, fallback: []),
      'advice': row.advice,
      'next_visit_date': row.nextVisitDate?.toUtc().toIso8601String(),
      'created_at': row.createdAt.toUtc().toIso8601String(),
    });
    return id;
  }

  Future<int> deletePrescription(int id) async {
    final rows = await (delete(prescriptions)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('prescriptions', '$id', 'delete', {'id': id});
    }
    return rows;
  }

  // ─── Procedure Prices ───────────────────────────────────

  Future<List<ProcedurePrice>> getAllProcedurePrices() => select(procedurePrices).get();

  Stream<List<ProcedurePrice>> watchAllProcedurePrices() => select(procedurePrices).watch();

  Future<int> insertProcedurePrice(ProcedurePricesCompanion entry) async {
    final id = await into(procedurePrices).insert(entry);
    final row = await (select(procedurePrices)..where((t) => t.id.equals(id))).getSingle();
    await _enqueueIfOnline('procedure_prices', '$id', 'upsert', {'id': row.id, 'name': row.name, 'default_price': row.defaultPrice});
    return id;
  }

  Future<void> updateProcedurePrice(ProcedurePricesCompanion entry) async {
    await (update(procedurePrices)..where((t) => t.id.equals(entry.id.value))).write(entry);
    final row = await (select(procedurePrices)..where((t) => t.id.equals(entry.id.value))).getSingleOrNull();
    if (row != null) {
      await _enqueueIfOnline('procedure_prices', '${row.id}', 'upsert', {'id': row.id, 'name': row.name, 'default_price': row.defaultPrice});
    }
  }

  Future<int> deleteProcedurePrice(int id) async {
    final rows = await (delete(procedurePrices)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('procedure_prices', '$id', 'delete', {'id': id});
    }
    return rows;
  }

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
        b.insert(procedurePrices, ProcedurePricesCompanion.insert(name: proc['name'] as String, defaultPrice: proc['price'] as double));
      }
    });
  }

  // ─── Tooth Conditions ───────────────────────────────────

  Future<List<ToothCondition>> getToothConditionsForPatient(int patientId) => (select(toothConditions)..where((t) => t.patientId.equals(patientId))).get();

  Stream<List<ToothCondition>> watchToothConditionsForPatient(int patientId) => (select(toothConditions)..where((t) => t.patientId.equals(patientId))).watch();

  Future<ToothCondition?> getToothCondition(int patientId, String toothNumber) => (select(toothConditions)..where((t) => t.patientId.equals(patientId) & t.toothNumber.equals(toothNumber))).getSingleOrNull();

  Future<void> setToothCondition({required int patientId, required String toothNumber, required String condition, String? surfaces, String? notes}) async {
    final existing = await getToothCondition(patientId, toothNumber);
    final now = DateTime.now();
    if (existing != null) {
      await (update(toothConditions)..where((t) => t.id.equals(existing.id))).write(ToothConditionsCompanion(condition: Value(condition), surfaces: Value(surfaces), notes: Value(notes), updatedAt: Value(now)));
    } else {
      await into(toothConditions).insert(ToothConditionsCompanion.insert(patientId: patientId, toothNumber: toothNumber, condition: Value(condition), surfaces: Value(surfaces), notes: Value(notes)));
    }
    await _enqueueIfOnline('tooth_conditions', '$patientId:$toothNumber', 'upsert', {
      'patient_id': patientId,
      'tooth_number': toothNumber,
      'condition': condition,
      'surfaces': _tryDecodeJson(surfaces),
      'notes': notes,
      'updated_at': now.toUtc().toIso8601String(),
    });
  }

  Future<void> resetToothCondition(int patientId, String toothNumber) async {
    final rows = await (delete(toothConditions)..where((t) => t.patientId.equals(patientId) & t.toothNumber.equals(toothNumber))).go();
    if (rows > 0) {
      await _enqueueIfOnline('tooth_conditions', '$patientId:$toothNumber', 'delete', {'patient_id': patientId, 'tooth_number': toothNumber});
    }
  }

  // ─── Investigations ─────────────────────────────────────

  Stream<List<Investigation>> watchInvestigationsForPatient(int patientId) =>
      (select(investigations)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<int> insertInvestigation(InvestigationsCompanion entry) async {
    final id = await into(investigations).insert(entry);
    final row = await (select(investigations)..where((t) => t.id.equals(id))).getSingle();
    await _enqueueIfOnline('investigations', '$id', 'upsert', {
      'id': row.id,
      'patient_id': row.patientId,
      'test_name': row.testName,
      'tooth_number': row.toothNumber,
      'status': row.status,
      'result_notes': row.resultNotes,
      'cost': row.cost,
      'date': row.date.toUtc().toIso8601String(),
      'created_at': row.createdAt.toUtc().toIso8601String(),
    });
    return id;
  }

  Future<void> updateInvestigationStatus(int id, String status, {String? resultNotes}) async {
    await (update(investigations)..where((t) => t.id.equals(id))).write(InvestigationsCompanion(status: Value(status), resultNotes: resultNotes != null ? Value(resultNotes) : const Value.absent()));
    final row = await (select(investigations)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      await _enqueueIfOnline('investigations', '$id', 'upsert', {
        'id': row.id,
        'patient_id': row.patientId,
        'test_name': row.testName,
        'tooth_number': row.toothNumber,
        'status': row.status,
        'result_notes': row.resultNotes,
        'cost': row.cost,
        'date': row.date.toUtc().toIso8601String(),
        'created_at': row.createdAt.toUtc().toIso8601String(),
      });
    }
  }

  Future<int> deleteInvestigation(int id) async {
    final rows = await (delete(investigations)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('investigations', '$id', 'delete', {'id': id});
    }
    return rows;
  }

  // ─── Expenses & Accounts ────────────────────────────────

  Stream<List<Expense>> watchAllExpenses() => (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<int> insertExpense(ExpensesCompanion entry) async {
    final id = await into(expenses).insert(entry);
    final row = await (select(expenses)..where((t) => t.id.equals(id))).getSingle();
    await _enqueueIfOnline('expenses', '$id', 'upsert', {
      'id': row.id,
      'title': row.title,
      'category': row.category,
      'amount': row.amount,
      'date': row.date.toUtc().toIso8601String(),
      'notes': row.notes,
      'created_at': row.createdAt.toUtc().toIso8601String(),
    });
    return id;
  }

  Future<int> deleteExpense(int id) async {
    final rows = await (delete(expenses)..where((t) => t.id.equals(id))).go();
    if (rows > 0) {
      await _enqueueIfOnline('expenses', '$id', 'delete', {'id': id});
    }
    return rows;
  }

  Future<double> getTotalIncomeInRange(DateTime start, DateTime end) async {
    final total = payments.amount.sum();
    final query = selectOnly(payments)
      ..addColumns([total])
      ..where(payments.date.isBiggerOrEqualValue(start) & payments.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<double> getTotalDiscountInRange(DateTime start, DateTime end) async {
    final total = payments.discount.sum();
    final query = selectOnly(payments)
      ..addColumns([total])
      ..where(payments.date.isBiggerOrEqualValue(start) & payments.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<double> getTotalExpenseInRange(DateTime start, DateTime end) async {
    final total = expenses.amount.sum();
    final query = selectOnly(expenses)
      ..addColumns([total])
      ..where(expenses.date.isBiggerOrEqualValue(start) & expenses.date.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(total) ?? 0.0;
  }

  Future<List<PaymentWithPatient>> getPaymentsInRangeWithPatient(DateTime start, DateTime end) async {
    final rows =
        await (select(payments).join([innerJoin(patients, patients.id.equalsExp(payments.patientId))])
              ..where(payments.date.isBiggerOrEqualValue(start) & payments.date.isSmallerThanValue(end))
              ..orderBy([OrderingTerm.desc(payments.date)]))
            .get();

    return rows.map((r) => PaymentWithPatient(payment: r.readTable(payments), patient: r.readTable(patients))).toList();
  }

  Future<List<Expense>> getExpensesInRange(DateTime start, DateTime end) =>
      (select(expenses)
            ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end))
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
      costByPatient[inv.patientId] = (costByPatient[inv.patientId] ?? 0.0) + inv.cost;
      trackDate(inv.patientId, inv.date);
    }

    final paidByPatient = <int, double>{};
    final discountByPatient = <int, double>{};
    for (final p in allPayments) {
      paidByPatient[p.patientId] = (paidByPatient[p.patientId] ?? 0.0) + p.amount;
      discountByPatient[p.patientId] = (discountByPatient[p.patientId] ?? 0.0) + p.discount;
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
        dues.add(PatientDueSummary(patient: patient, totalCost: cost, totalPaid: paid, totalDiscount: disc, due: due, lastVisitDate: lastVisitByPatient[patient.id]));
      }
    }

    dues.sort((a, b) => b.due.compareTo(a.due));
    return dues;
  }

  Stream<List<PatientDueSummary>> watchPatientsWithDue() {
    return customSelect('SELECT 1', readsFrom: {patients, treatments, investigations, payments, appointments}).watch().asyncMap((_) => getPatientsWithDue());
  }

  Future<List<AppointmentWithPatient>> getWaitingVisits({required bool overdueOnly}) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final query = select(appointments).join([innerJoin(patients, patients.id.equalsExp(appointments.patientId))]);

    if (overdueOnly) {
      query
        ..where(appointments.status.equals('waiting') & appointments.appointmentDate.isSmallerThanValue(startOfToday))
        ..orderBy([OrderingTerm.desc(appointments.appointmentDate)]);
    } else {
      query
        ..where(appointments.status.equals('waiting') & appointments.appointmentDate.isBiggerOrEqualValue(startOfToday))
        ..orderBy([OrderingTerm.asc(appointments.appointmentDate)]);
    }

    final rows = await query.get();
    return rows.map((r) => AppointmentWithPatient(appointment: r.readTable(appointments), patient: r.readTable(patients))).toList();
  }

  Stream<List<AppointmentWithPatient>> watchWaitingVisits({required bool overdueOnly}) {
    return customSelect('SELECT 1', readsFrom: {appointments, patients}).watch().asyncMap((_) => getWaitingVisits(overdueOnly: overdueOnly));
  }

  // ─── Bulk Table Readers (For Online-Format Export) ───────

  Future<List<Appointment>> getAllAppointments() =>
      (select(appointments)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<Treatment>> getAllTreatments() =>
      (select(treatments)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<Payment>> getAllPayments() =>
      (select(payments)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<Prescription>> getAllPrescriptions() =>
      (select(prescriptions)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<Investigation>> getAllInvestigations() =>
      (select(investigations)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<Expense>> getAllExpenses() =>
      (select(expenses)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<ToothCondition>> getAllToothConditions() =>
      (select(toothConditions)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  /// Flushes SQLite WAL buffer into the main `.sqlite` file before export.
  Future<void> checkpointWal() => customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
}

// ─── Database Connection ─────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'my_dental.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        rawDb.execute('PRAGMA journal_mode = WAL;');
        rawDb.execute('PRAGMA synchronous = NORMAL;');
        rawDb.execute('PRAGMA temp_store = MEMORY;');
        rawDb.execute('PRAGMA cache_size = -8000;');
        rawDb.execute('PRAGMA busy_timeout = 5000;');
      },
    );
  });
}
