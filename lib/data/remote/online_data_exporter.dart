import 'dart:convert';

import '../local/database.dart';

/// Exports local offline SQLite records in exact online Supabase table format
/// (`public.*` tables & columns matching `supabase_schema.sql`) so they can be
/// imported directly into online Supabase tables later.
class OnlineDataExporter {
  final AppDatabase db;

  OnlineDataExporter(this.db);

  static const List<String> _idTables = [
    'procedure_prices',
    'patients',
    'appointments',
    'treatments',
    'payments',
    'prescriptions',
    'investigations',
    'expenses',
    'tooth_conditions',
  ];

  static const Set<String> _jsonbColumns = {
    'medicines',
    'investigations',
    'surfaces',
  };

  static const Set<String> _timestamptzColumns = {
    'created_at',
    'updated_at',
    'appointment_date',
    'date',
    'next_visit_date',
  };

  dynamic _decodeJsonOrFallback(String? raw, dynamic fallback) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return fallback;
    }
  }

  /// Builds table payloads using the exact Supabase table & column names.
  Future<Map<String, List<Map<String, dynamic>>>> buildTablesPayload() async {
    final prices = await db.getAllProcedurePrices();
    final patientRows = await db.getAllPatients();
    final apptRows = await db.getAllAppointments();
    final treatmentRows = await db.getAllTreatments();
    final paymentRows = await db.getAllPayments();
    final rxRows = await db.getAllPrescriptions();
    final invRows = await db.getAllInvestigations();
    final expenseRows = await db.getAllExpenses();
    final toothRows = await db.getAllToothConditions();

    return {
      'procedure_prices': prices
          .map((r) => <String, dynamic>{
                'name': r.name,
                'default_price': r.defaultPrice,
              })
          .toList(),
      'patients': patientRows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'name': r.name,
                'phone': r.phone,
                'age': r.age,
                'gender': r.gender,
                'address': r.address,
                'medical_history': r.medicalHistory,
                'allergies': r.allergies,
                'created_at': r.createdAt.toUtc().toIso8601String(),
              })
          .toList(),
      'appointments': apptRows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'patient_id': r.patientId,
                'appointment_date': r.appointmentDate.toUtc().toIso8601String(),
                'status': r.status,
                'note': r.note,
                'created_at': r.createdAt.toUtc().toIso8601String(),
              })
          .toList(),
      'treatments': treatmentRows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'patient_id': r.patientId,
                'tooth_number': r.toothNumber,
                'procedure': r.procedure,
                'cost': r.cost,
                'date': r.date.toUtc().toIso8601String(),
                'notes': r.notes,
                'created_at': r.createdAt.toUtc().toIso8601String(),
              })
          .toList(),
      'payments': paymentRows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'patient_id': r.patientId,
                'treatment_id': r.treatmentId,
                'amount': r.amount,
                'discount': r.discount,
                'category': r.category,
                'notes': r.notes,
                'date': r.date.toUtc().toIso8601String(),
                'method': r.method,
                'created_at': r.createdAt.toUtc().toIso8601String(),
              })
          .toList(),
      'prescriptions': rxRows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'patient_id': r.patientId,
                'doctor_name': r.doctorName,
                'date': r.date.toUtc().toIso8601String(),
                'medicines': _decodeJsonOrFallback(r.medicines, const []),
                'investigations':
                    _decodeJsonOrFallback(r.investigations, const []),
                'advice': r.advice,
                'next_visit_date': r.nextVisitDate?.toUtc().toIso8601String(),
                'created_at': r.createdAt.toUtc().toIso8601String(),
              })
          .toList(),
      'investigations': invRows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'patient_id': r.patientId,
                'test_name': r.testName,
                'tooth_number': r.toothNumber,
                'status': r.status,
                'result_notes': r.resultNotes,
                'cost': r.cost,
                'date': r.date.toUtc().toIso8601String(),
                'created_at': r.createdAt.toUtc().toIso8601String(),
              })
          .toList(),
      'expenses': expenseRows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'title': r.title,
                'category': r.category,
                'amount': r.amount,
                'date': r.date.toUtc().toIso8601String(),
                'notes': r.notes,
                'created_at': r.createdAt.toUtc().toIso8601String(),
              })
          .toList(),
      'tooth_conditions': toothRows
          .map((r) => <String, dynamic>{
                'patient_id': r.patientId,
                'tooth_number': r.toothNumber,
                'condition': r.condition,
                'surfaces': _decodeJsonOrFallback(r.surfaces, null),
                'notes': r.notes,
                'updated_at': r.updatedAt.toUtc().toIso8601String(),
              })
          .toList(),
    };
  }

  /// Generates a transactional PostgreSQL `.sql` script ready for Supabase SQL Editor.
  Future<({String sql, int totalRecords})> generateSql() async {
    final tables = await buildTablesPayload();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final buf = StringBuffer()
      ..writeln('-- ===============================================================')
      ..writeln('-- MY DENTAL CLINIC — OFFLINE TO ONLINE SUPABASE EXPORT (.sql)')
      ..writeln('-- Exported at (UTC): $nowIso')
      ..writeln('-- Paste/run this file in Supabase SQL Editor to import into online tables.')
      ..writeln('-- ===============================================================')
      ..writeln('BEGIN;')
      ..writeln();

    int total = 0;

    void writeUpsertSection({
      required String table,
      required List<Map<String, dynamic>> rows,
      required String conflictTarget,
      required List<String> conflictKeyColumns,
    }) {
      if (rows.isEmpty) return;
      total += rows.length;
      final columns = rows.first.keys.toList();
      final colList = columns.join(', ');
      final updateCols = columns
          .where((c) => !conflictKeyColumns.contains(c))
          .map((c) => '$c = EXCLUDED.$c')
          .join(', ');

      buf.writeln('-- Table: public.$table (${rows.length} rows)');
      for (final row in rows) {
        final vals = columns
            .map((col) => _formatSqlLiteral(col, row[col]))
            .join(', ');
        buf.writeln(
          'INSERT INTO public.$table ($colList) VALUES ($vals) '
          'ON CONFLICT ($conflictTarget) DO UPDATE SET $updateCols;',
        );
      }
      buf.writeln();
    }

    writeUpsertSection(
      table: 'procedure_prices',
      rows: tables['procedure_prices']!,
      conflictTarget: 'name',
      conflictKeyColumns: const ['name'],
    );
    writeUpsertSection(
      table: 'patients',
      rows: tables['patients']!,
      conflictTarget: 'id',
      conflictKeyColumns: const ['id'],
    );
    writeUpsertSection(
      table: 'appointments',
      rows: tables['appointments']!,
      conflictTarget: 'id',
      conflictKeyColumns: const ['id'],
    );
    writeUpsertSection(
      table: 'treatments',
      rows: tables['treatments']!,
      conflictTarget: 'id',
      conflictKeyColumns: const ['id'],
    );
    writeUpsertSection(
      table: 'payments',
      rows: tables['payments']!,
      conflictTarget: 'id',
      conflictKeyColumns: const ['id'],
    );
    writeUpsertSection(
      table: 'prescriptions',
      rows: tables['prescriptions']!,
      conflictTarget: 'id',
      conflictKeyColumns: const ['id'],
    );
    writeUpsertSection(
      table: 'investigations',
      rows: tables['investigations']!,
      conflictTarget: 'id',
      conflictKeyColumns: const ['id'],
    );
    writeUpsertSection(
      table: 'expenses',
      rows: tables['expenses']!,
      conflictTarget: 'id',
      conflictKeyColumns: const ['id'],
    );
    writeUpsertSection(
      table: 'tooth_conditions',
      rows: tables['tooth_conditions']!,
      conflictTarget: 'patient_id, tooth_number',
      conflictKeyColumns: const ['patient_id', 'tooth_number'],
    );

    buf.writeln('-- Sync PostgreSQL identity sequences to prevent future ID collisions');
    for (final table in _idTables) {
      buf.writeln(
        "SELECT setval(pg_get_serial_sequence('public.$table', 'id'), "
        "COALESCE((SELECT MAX(id) FROM public.$table), 1), "
        "EXISTS (SELECT 1 FROM public.$table));",
      );
    }

    buf
      ..writeln()
      ..writeln('COMMIT;');

    return (sql: buf.toString(), totalRecords: total);
  }

  /// Generates structured JSON matching the exact online Supabase table schema.
  Future<({String json, int totalRecords})> generateJson() async {
    final tables = await buildTablesPayload();
    final counts = <String, int>{
      for (final entry in tables.entries) entry.key: entry.value.length,
    };
    final total = counts.values.fold<int>(0, (sum, c) => sum + c);

    final envelope = <String, dynamic>{
      'format': 'supabase_online_tables_v1',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'record_counts': counts,
      'tables': tables,
    };

    return (
      json: const JsonEncoder.withIndent('  ').convert(envelope),
      totalRecords: total,
    );
  }

  String _quoteSqlString(String value) =>
      "'${value.replaceAll("'", "''")}'";

  String _formatSqlLiteral(String column, dynamic value) {
    if (value == null) return 'NULL';

    if (_jsonbColumns.contains(column)) {
      return '${_quoteSqlString(jsonEncode(value))}::jsonb';
    }

    if (_timestamptzColumns.contains(column) && value is String) {
      return '${_quoteSqlString(value)}::timestamptz';
    }

    if (value is num || value is bool) {
      return '$value';
    }

    return _quoteSqlString(value.toString());
  }
}
