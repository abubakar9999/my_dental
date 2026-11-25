import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';

class AppointmentFormScreen extends ConsumerStatefulWidget {
  final int? preselectedPatientId;

  const AppointmentFormScreen({super.key, this.preselectedPatientId});

  @override
  ConsumerState<AppointmentFormScreen> createState() =>
      _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends ConsumerState<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  int? _selectedPatientId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.preselectedPatientId;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে একজন রোগী নির্বাচন করুন')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final db = ref.read(databaseProvider);
      await db.insertAppointment(
        AppointmentsCompanion.insert(
          patientId: _selectedPatientId!,
          appointmentDate: appointmentDateTime,
          status: const drift.Value(AppConstants.statusWaiting),
          note: drift.Value(
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ),
        ),
      );

      ref.invalidate(todayAppointmentCountProvider);
      ref.invalidate(appointmentsForPatientProvider(_selectedPatientId!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অ্যাপয়েন্টমেন্ট সফলভাবে তৈরি হয়েছে'),
            backgroundColor: Colors.teal,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(allPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন অ্যাপয়েন্টমেন্ট'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Selector
              patientsAsync.when(
                data: (patients) {
                  return DropdownButtonFormField<int>(
                    value: _selectedPatientId,
                    decoration: const InputDecoration(
                      labelText: 'রোগী নির্বাচন করুন *',
                      prefixIcon: Icon(Icons.person_search),
                    ),
                    items: patients.map((p) {
                      return DropdownMenuItem<int>(
                        value: p.id,
                        child: Text('${p.name} (${p.phone})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedPatientId = val);
                    },
                    validator: (val) =>
                        val == null ? 'রোগী নির্বাচন করা আবশ্যক' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('রোগীদের তালিকা লোড করা যায়নি: $e'),
              ),
              const SizedBox(height: 20),

              // Date Picker Field
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'তারিখ *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateFormat.format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Picker Field
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'সময় *',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Note Field
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'মন্তব্য বা সমস্যা বিবরণ (ঐচ্ছিক)',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'অ্যাপয়েন্টমেন্ট নিশ্চিত করুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
