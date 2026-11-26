import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';
import 'prescription_pdf.dart';

class PrescriptionFormScreen extends ConsumerStatefulWidget {
  final int patientId;

  const PrescriptionFormScreen({super.key, required this.patientId});

  @override
  ConsumerState<PrescriptionFormScreen> createState() =>
      _PrescriptionFormScreenState();
}

class _MedicineItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController timingController = TextEditingController();

  _MedicineItem({
    String name = '',
    String dose = '1+0+1',
    String duration = '5 দিন',
    String timing = 'খাওয়ার পর',
  }) {
    nameController.text = name;
    doseController.text = dose;
    durationController.text = duration;
    timingController.text = timing;
  }

  void dispose() {
    nameController.dispose();
    doseController.dispose();
    durationController.dispose();
    timingController.dispose();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text.trim(),
      'dose': doseController.text.trim(),
      'duration': durationController.text.trim(),
      'timing': timingController.text.trim(),
    };
  }
}

class _InvestigationItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController toothController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  _InvestigationItem({
    String name = '',
    String tooth = '',
    double cost = 0.0,
    String notes = '',
  }) {
    nameController.text = name;
    toothController.text = tooth;
    costController.text = cost > 0 ? cost.toStringAsFixed(0) : '';
    notesController.text = notes;
  }

  void dispose() {
    nameController.dispose();
    toothController.dispose();
    costController.dispose();
    notesController.dispose();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text.trim(),
      'toothNumber': toothController.text.trim(),
      'cost': double.tryParse(costController.text.trim()) ?? 0.0,
      'notes': notesController.text.trim(),
    };
  }
}

enum _SaveAction { saveOnly, printPdf, shareWhatsApp }

class _PrescriptionFormScreenState
    extends ConsumerState<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_MedicineItem> _medicines = [];
  final List<_InvestigationItem> _investigations = [];
  final _adviceController = TextEditingController();
  DateTime? _nextVisitDate;
  bool _isLoading = false;

  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _medicines.add(_MedicineItem());
  }

  @override
  void dispose() {
    for (final m in _medicines) {
      m.dispose();
    }
    for (final inv in _investigations) {
      inv.dispose();
    }
    _adviceController.dispose();
    super.dispose();
  }

  void _addMedicineRow({
    String name = '',
    String dose = '1+0+1',
    String duration = '5 দিন',
    String timing = 'খাওয়ার পর',
  }) {
    setState(() {
      if (_medicines.length == 1 &&
          _medicines.first.nameController.text.trim().isEmpty &&
          name.isNotEmpty) {
        _medicines.first.nameController.text = name;
        _medicines.first.doseController.text = dose;
        _medicines.first.durationController.text = duration;
        _medicines.first.timingController.text = timing;
      } else {
        _medicines.add(
          _MedicineItem(
            name: name,
            dose: dose,
            duration: duration,
            timing: timing,
          ),
        );
      }
    });
  }

  void _removeMedicineRow(int index) {
    if (_medicines.length <= 1) {
      setState(() => _medicines.first.nameController.clear());
      return;
    }
    setState(() {
      _medicines[index].dispose();
      _medicines.removeAt(index);
    });
  }

  void _togglePresetInvestigation(String testName, double defaultCost) {
    final existingIdx = _investigations.indexWhere(
      (i) => i.nameController.text.trim().toLowerCase() == testName.toLowerCase(),
    );
    setState(() {
      if (existingIdx >= 0) {
        _investigations[existingIdx].dispose();
        _investigations.removeAt(existingIdx);
      } else {
        _investigations.add(
          _InvestigationItem(name: testName, cost: defaultCost),
        );
      }
    });
  }

  void _addCustomInvestigation() {
    setState(() {
      _investigations.add(_InvestigationItem());
    });
  }

  void _removeInvestigation(int index) {
    setState(() {
      _investigations[index].dispose();
      _investigations.removeAt(index);
    });
  }

  Future<void> _pickNextVisitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextVisitDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _nextVisitDate = picked);
    }
  }

  Future<void> _savePrescription(_SaveAction action) async {
    if (!_formKey.currentState!.validate()) return;

    final validMeds = _medicines
        .where((m) => m.nameController.text.trim().isNotEmpty)
        .map((m) => m.toMap())
        .toList();

    final validInvs = _investigations
        .where((i) => i.nameController.text.trim().isNotEmpty)
        .map((i) => i.toMap())
        .toList();

    if (validMeds.isEmpty && validInvs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('কমপক্ষে একটি ওষুধ অথবা ইনভেস্টিগেশন যোগ করুন'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final advice = _adviceController.text.trim().isEmpty
          ? null
          : _adviceController.text.trim();
      final db = ref.read(databaseProvider);
      final profile = ref.read(authRepositoryProvider).currentProfile;
      final now = DateTime.now();

      await db.insertPrescription(
        PrescriptionsCompanion.insert(
          patientId: widget.patientId,
          date: now,
          medicines: jsonEncode(validMeds),
          investigations: drift.Value(jsonEncode(validInvs)),
          advice: drift.Value(advice),
          nextVisitDate: drift.Value(_nextVisitDate),
          doctorName: drift.Value(profile?.fullName),
        ),
      );

      // Also save each assigned investigation to the Investigations table for tracking & billing
      for (final inv in validInvs) {
        final tooth = (inv['toothNumber'] as String?) ?? '';
        final notes = (inv['notes'] as String?) ?? '';
        final cost = (inv['cost'] as num?)?.toDouble() ?? 0.0;
        await db.insertInvestigation(
          InvestigationsCompanion.insert(
            patientId: widget.patientId,
            testName: inv['name'] as String,
            toothNumber: drift.Value(tooth.isEmpty ? null : tooth),
            resultNotes: drift.Value(notes.isEmpty ? null : notes),
            cost: drift.Value(cost),
            date: now,
          ),
        );
      }

      // If next visit date is set, create a follow-up appointment automatically
      if (_nextVisitDate != null) {
        final followUpDateTime = DateTime(
          _nextVisitDate!.year,
          _nextVisitDate!.month,
          _nextVisitDate!.day,
          10,
          0,
        );
        await db.insertAppointment(
          AppointmentsCompanion.insert(
            patientId: widget.patientId,
            appointmentDate: followUpDateTime,
            note: const drift.Value('ফলো-আপ ভিজিট (প্রেসক্রিপশন)'),
          ),
        );
      }

      ref.invalidate(prescriptionsForPatientProvider(widget.patientId));
      ref.invalidate(investigationsForPatientProvider(widget.patientId));
      ref.invalidate(appointmentsForPatientProvider(widget.patientId));
      ref.invalidate(totalCostForPatientProvider(widget.patientId));
      ref.invalidate(totalDuesProvider);
      ref.invalidate(upcomingVisitsProvider);
      ref.invalidate(todayAppointmentCountProvider);

      if (action != _SaveAction.saveOnly && mounted) {
        final patient = await db.getPatient(widget.patientId);
        final totalCost = await db.getTotalCostForPatient(widget.patientId);
        final totalPaid = await db.getTotalPaidForPatient(widget.patientId);
        final due = totalCost - totalPaid;

        if (action == _SaveAction.shareWhatsApp) {
          await PrescriptionPdfGenerator.sharePdf(
            patientName: patient.name,
            patientPhone: patient.phone,
            patientAge: patient.age ?? 0,
            medicines: validMeds,
            investigations: validInvs,
            advice: advice,
            nextVisitDate: _nextVisitDate,
            doctorName: profile?.fullName,
            doctorQualification: profile?.qualification,
            doctorPhone: profile?.phone,
            currentDue: due > 0 ? due : null,
            prescriptionDate: now,
          );
        } else if (action == _SaveAction.printPdf) {
          await PrescriptionPdfGenerator.generate(
            patientName: patient.name,
            patientPhone: patient.phone,
            patientAge: patient.age ?? 0,
            medicines: validMeds,
            investigations: validInvs,
            advice: advice,
            nextVisitDate: _nextVisitDate,
            doctorName: profile?.fullName,
            doctorQualification: profile?.qualification,
            doctorPhone: profile?.phone,
            currentDue: due > 0 ? due : null,
            prescriptionDate: now,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('প্রেসক্রিপশন ও ইনভেস্টিগেশন সংরক্ষিত হয়েছে'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন প্রেসক্রিপশন ও ইনভেস্টিগেশন'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── 1. Investigations Section ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ইনভেস্টিগেশন / পরীক্ষা (Lab & X-Ray)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addCustomInvestigation,
                    icon: const Icon(Icons.add, size: 18, color: Colors.teal),
                    label: const Text('কাস্টম টেস্ট', style: TextStyle(color: Colors.teal)),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: AppConstants.defaultInvestigations.map((inv) {
                  final name = inv['name'] as String;
                  final price = (inv['price'] as num).toDouble();
                  final selected = _investigations.any(
                    (i) =>
                        i.nameController.text.trim().toLowerCase() ==
                        name.toLowerCase(),
                  );
                  return FilterChip(
                    label: Text(
                      '$name (৳${price.toStringAsFixed(0)})',
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : Colors.teal.shade900,
                      ),
                    ),
                    selected: selected,
                    selectedColor: Colors.teal,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.teal.shade50,
                    onSelected: (_) => _togglePresetInvestigation(name, price),
                  );
                }).toList(),
              ),
              if (_investigations.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...List.generate(_investigations.length, (index) {
                  final inv = _investigations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blueGrey.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.biotech, color: Colors.teal, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: inv.nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'পরীক্ষার নাম *',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () => _removeInvestigation(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: inv.toothController,
                                  decoration: const InputDecoration(
                                    labelText: 'দাঁত নম্বর (ঐচ্ছিক)',
                                    hintText: '36',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: inv.costController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'ফি (৳) (ঐচ্ছিক)',
                                    hintText: '0',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: inv.notesController,
                            decoration: const InputDecoration(
                              labelText: 'নির্দেশনা / নোট',
                              hintText: 'উদাঃ খালি পেটে / ডান পাশের মোলার',
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 20),

              // ─── 2. Medicines Section ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ওষুধের তালিকা (Rx)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _addMedicineRow(),
                    icon: const Icon(Icons.add, color: Colors.teal),
                    label: const Text(
                      'আরেকটি ওষুধ',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.defaultMedicines.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (ctx, i) {
                    final preset = AppConstants.defaultMedicines[i];
                    return ActionChip(
                      label: Text(
                        preset['name']!,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.grey.shade100,
                      onPressed: () => _addMedicineRow(
                        name: preset['name']!,
                        dose: preset['dose']!,
                        duration: preset['duration']!,
                        timing: preset['timing']!,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              ...List.generate(_medicines.length, (index) {
                final item = _medicines[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.teal.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.teal.shade50,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: item.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'ওষুধের নাম',
                                  hintText: 'উদাঃ Tab. Napa 500mg, Amoxicillin',
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => _removeMedicineRow(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: item.doseController,
                                decoration: const InputDecoration(
                                  labelText: 'ডোজ',
                                  hintText: '1+0+1',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: item.durationController,
                                decoration: const InputDecoration(
                                  labelText: 'মেয়াদ',
                                  hintText: '5 দিন',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: item.timingController,
                                decoration: const InputDecoration(
                                  labelText: 'সময়',
                                  hintText: 'খাওয়ার পর',
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // ─── 3. Next Visit Date (Follow-up) ──────────────────
              const Text(
                'পরবর্তী ভিজিট তারিখ (ঐচ্ছিক)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final days in [3, 7, 14])
                    ChoiceChip(
                      label: Text('$days দিন পর'),
                      selected: _nextVisitDate != null &&
                          _nextVisitDate!.difference(DateTime.now()).inDays ==
                              days - 1,
                      onSelected: (_) {
                        setState(() {
                          _nextVisitDate =
                              DateTime.now().add(Duration(days: days));
                        });
                      },
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _nextVisitDate != null
                          ? _dateFormat.format(_nextVisitDate!)
                          : 'তারিখ বাছাই',
                    ),
                    onPressed: _pickNextVisitDate,
                  ),
                  if (_nextVisitDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () => setState(() => _nextVisitDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── 4. Advice Section ───────────────────────────────
              const Text(
                'বিশেষ পরামর্শ ও নির্দেশনা',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _adviceController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'উদাঃ কুসুম গরম পানিতে লবণ দিয়ে কুলকুচি করবেন। শক্ত খাবার এড়িয়ে চলুন।',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // ─── Action Buttons ──────────────────────────────────
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _savePrescription(_SaveAction.shareWhatsApp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: const Text(
                  'সংরক্ষণ ও WhatsApp-এ PDF শেয়ার',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _savePrescription(_SaveAction.saveOnly),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('শুধু সংরক্ষণ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _savePrescription(_SaveAction.printPdf),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.print),
                      label: const Text('প্রিন্ট / PDF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
