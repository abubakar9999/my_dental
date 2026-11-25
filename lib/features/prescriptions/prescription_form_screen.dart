import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

class _PrescriptionFormScreenState
    extends ConsumerState<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_MedicineItem> _medicines = [];
  final _adviceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add one default medicine row
    _medicines.add(_MedicineItem());
  }

  @override
  void dispose() {
    for (var m in _medicines) {
      m.dispose();
    }
    _adviceController.dispose();
    super.dispose();
  }

  void _addMedicineRow() {
    setState(() {
      _medicines.add(_MedicineItem());
    });
  }

  void _removeMedicineRow(int index) {
    if (_medicines.length <= 1) return;
    setState(() {
      _medicines[index].dispose();
      _medicines.removeAt(index);
    });
  }

  Future<void> _savePrescription({bool generatePdf = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final validMeds = _medicines
          .where((m) => m.nameController.text.trim().isNotEmpty)
          .map((m) => m.toMap())
          .toList();

      final advice = _adviceController.text.trim().isEmpty
          ? null
          : _adviceController.text.trim();

      final db = ref.read(databaseProvider);
      await db.insertPrescription(
        PrescriptionsCompanion.insert(
          patientId: widget.patientId,
          date: DateTime.now(),
          medicines: jsonEncode(validMeds),
          advice: drift.Value(advice),
        ),
      );

      ref.invalidate(prescriptionsForPatientProvider(widget.patientId));

      if (generatePdf && mounted) {
        final patient =
            await ref.read(databaseProvider).getPatient(widget.patientId);
        await PrescriptionPdfGenerator.generate(
          patientName: patient.name,
          patientPhone: patient.phone,
          patientAge: patient.age ?? 0,
          medicines: validMeds,
          advice: advice,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('প্রেসক্রিপশন সফলভাবে সংরক্ষিত হয়েছে'),
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
        title: const Text('নতুন প্রেসক্রিপশন'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ওষুধের তালিকা (Rx)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addMedicineRow,
                    icon: const Icon(Icons.add, color: Colors.teal),
                    label: const Text(
                      'আরেকটি ওষুধ',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Medicine Rows
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
                                  labelText: 'ওষুধের নাম *',
                                  hintText: 'উদাঃ Tab. Napa 500mg, Amoxicillin',
                                  isDense: true,
                                ),
                                validator: (val) {
                                  if (index == 0 &&
                                      (val == null || val.trim().isEmpty)) {
                                    return 'কমপক্ষে একটি ওষুধের নাম দিন';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_medicines.length > 1)
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
                                  hintText: '৫ দিন',
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
              const SizedBox(height: 16),

              // Advice Section
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
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'উদাঃ কুসুম গরম পানিতে লবণ দিয়ে কুলকুচি করবেন। শক্ত খাবার এড়িয়ে চলুন। ৭ দিন পর ফলো-আপ।',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () => _savePrescription(generatePdf: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('সংরক্ষণ করুন'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _savePrescription(generatePdf: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.print),
                      label: const Text('সংরক্ষণ ও PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
