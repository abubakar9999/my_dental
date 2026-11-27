import 'package:drift/drift.dart';

// ─── Table Definitions ───────────────────────────────────────

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get password => text()();
  TextColumn get name => text()();
  TextColumn get role => text().withDefault(const Constant('dentist'))(); // dentist, receptionist, admin
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().withLength(min: 1, max: 20)();
  IntColumn get age => integer().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get medicalHistory => text().nullable()();
  TextColumn get allergies => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  DateTimeColumn get appointmentDate => dateTime()();
  TextColumn get status =>
      text().withDefault(const Constant('waiting'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Treatments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get toothNumber => text().nullable()();
  TextColumn get procedure => text()();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  IntColumn get treatmentId =>
      integer().nullable().references(Treatments, #id)();
  RealColumn get amount => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  TextColumn get category =>
      text().withDefault(const Constant('ট্রিটমেন্ট / বকেয়া'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Prescriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get medicines => text()(); // JSON string
  TextColumn get investigations =>
      text().withDefault(const Constant('[]'))(); // JSON string
  TextColumn get advice => text().nullable()();
  DateTimeColumn get nextVisitDate => dateTime().nullable()();
  TextColumn get doctorName => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Investigations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get testName => text()();
  TextColumn get toothNumber => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, completed
  TextColumn get resultNotes => text().nullable()();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class ProcedurePrices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get defaultPrice => real()();
}

class ToothConditions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get toothNumber => text()(); // e.g. "11", "24", "36", etc.
  TextColumn get condition =>
      text().withDefault(const Constant('healthy'))(); // healthy, caries, filled, crown, extracted, rct
  TextColumn get surfaces => text().nullable()(); // JSON list e.g. ["mesial", "occlusal"]
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get recordKey => text()();
  TextColumn get operation => text()(); // upsert, delete
  TextColumn get payload => text()(); // JSON map
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
