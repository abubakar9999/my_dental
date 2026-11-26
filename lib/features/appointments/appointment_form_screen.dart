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
  final _visitFeeController = TextEditingController();

  int? _selectedPatientId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _chargeVisitFee = true;
  bool _collectNow = false;
  String _paymentMethod = AppConstants.paymentMethods.first;
  bool _isLoading = false;

  final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.preselectedPatientId;
    final defaultFee = ref.read(clinicSettingsProvider).firstVisitFee;
    _visitFeeController.text = defaultFee.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _visitFeeController.dispose();
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

      final fee = double.tryParse(_visitFeeController.text.trim()) ?? 0.0;
      if (_chargeVisitFee && fee > 0) {
        await db.insertTreatment(
          TreatmentsCompanion.insert(
            patientId: _selectedPatientId!,
            procedure: 'ভিজিট ফি (Visit Fee)',
            cost: drift.Value(fee),
            date: appointmentDateTime,
            notes: const drift.Value('অ্যাপয়েন্টমেন্ট থেকে চার্জকৃত'),
          ),
        );

        if (_collectNow) {
          await db.insertPayment(
            PaymentsCompanion.insert(
              patientId: _selectedPatientId!,
              amount: fee,
              category: const drift.Value('ভিজিট ফি (Visit Fee)'),
              notes: const drift.Value('ভিজিট ফি তাৎক্ষণিক আদায়'),
              date: DateTime.now(),
              method: _paymentMethod,
            ),
          );
        }
      }

      ref.invalidate(todayAppointmentCountProvider);
      ref.invalidate(appointmentsForPatientProvider(_selectedPatientId!));
      ref.invalidate(totalCostForPatientProvider(_selectedPatientId!));
      ref.invalidate(totalPaidForPatientProvider(_selectedPatientId!));
      ref.invalidate(totalDuesProvider);
      ref.invalidate(todayIncomeProvider);
      ref.invalidate(monthlyIncomeProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অ্যাপয়েন্টমেন্ট ও ভিজিট ফি সংরক্ষিত হয়েছে'),
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
    final settings = ref.watch(clinicSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন অ্যাপয়েন্টমেন্ট ও ভিজিট'),
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
              const SizedBox(height: 16),

              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'তারিখ *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dateFormat.format(_selectedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'সময় *',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Visit Fee Card
              Card(
                color: Colors.teal.shade50.withAlpha(110),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.teal.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'ভিজিট ফি বিলে যোগ করুন',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'স্বয়ংক্রিয়ভাবে রোগীর বিলে ভিজিট ফি যুক্ত হবে',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _chargeVisitFee,
                        onChanged: (v) => setState(() => _chargeVisitFee = v),
                      ),
                      if (_chargeVisitFee) ...[
                        Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              label: Text(
                                  'নতুন ভিজিট (৳${settings.firstVisitFee.toStringAsFixed(0)})'),
                              onPressed: () => setState(() {
                                _visitFeeController.text =
                                    settings.firstVisitFee.toStringAsFixed(0);
                              }),
                            ),
                            ActionChip(
                              label: Text(
                                  'ফলো-আপ (৳${settings.followUpFee.toStringAsFixed(0)})'),
                              onPressed: () => setState(() {
                                _visitFeeController.text =
                                    settings.followUpFee.toStringAsFixed(0);
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _visitFeeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ভিজিট ফি (৳)',
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('এখনই ভিজিট ফি জমা হয়েছে?'),
                          value: _collectNow,
                          onChanged: (v) => setState(() => _collectNow = v),
                        ),
                        if (_collectNow)
                          DropdownButtonFormField<String>(
                            value: _paymentMethod,
                            decoration: const InputDecoration(
                              labelText: 'পেমেন্ট মাধ্যম',
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                            ),
                            items: AppConstants.paymentMethods
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _paymentMethod = v);
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note Field
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'মন্তব্য বা সমস্যা বিবরণ (ঐচ্ছিক)',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

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
