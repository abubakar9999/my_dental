import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/local/database.dart';

class TreatmentFormScreen extends ConsumerStatefulWidget {
  final int patientId;
  final String? initialToothNumber;

  const TreatmentFormScreen({
    super.key,
    required this.patientId,
    this.initialToothNumber,
  });

  @override
  ConsumerState<TreatmentFormScreen> createState() =>
      _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends ConsumerState<TreatmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _procedureController = TextEditingController();
  late final TextEditingController _toothNumberController;
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _toothNumberController =
        TextEditingController(text: widget.initialToothNumber ?? '');
  }

  @override
  void dispose() {
    _procedureController.dispose();
    _toothNumberController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
      final db = ref.read(databaseProvider);

      await db.insertTreatment(
        TreatmentsCompanion.insert(
          patientId: widget.patientId,
          procedure: _procedureController.text.trim(),
          cost: drift.Value(cost),
          date: _selectedDate,
          toothNumber: drift.Value(
            _toothNumberController.text.trim().isEmpty
                ? null
                : _toothNumberController.text.trim(),
          ),
          notes: drift.Value(
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        ),
      );

      ref.invalidate(totalCostForPatientProvider(widget.patientId));
      ref.invalidate(totalDuesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('চিকিৎসার তথ্য সংরক্ষিত হয়েছে'),
            backgroundColor: Colors.teal,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('সংরক্ষণে ত্রুটি: $e'),
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
    final procedurePricesAsync = ref.watch(procedurePricesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন চিকিৎসা'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Procedure Preset Selector Dropdown
              procedurePricesAsync.when(
                data: (prices) {
                  return DropdownButtonFormField<ProcedurePrice>(
                    decoration: const InputDecoration(
                      labelText: 'প্রসিডিউর বাছাই করুন (ডিফল্ট তালিকা)',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    items: prices.map((p) {
                      return DropdownMenuItem<ProcedurePrice>(
                        value: p,
                        child: Text('${p.name} - ৳${p.defaultPrice.toInt()}'),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      if (selected != null) {
                        setState(() {
                          _procedureController.text = selected.name;
                          _costController.text =
                              selected.defaultPrice.toStringAsFixed(0);
                        });
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Procedure Name Field (Editable / Custom)
              TextFormField(
                controller: _procedureController,
                decoration: const InputDecoration(
                  labelText: 'চিকিৎসার নাম *',
                  hintText: 'উদাঃ RCT, স্কেলিং, কম্পোজিট ফিলিং',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'চিকিৎসার নাম লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tooth Number & Cost Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _toothNumberController,
                      decoration: const InputDecoration(
                        labelText: 'দাঁতের নম্বর',
                        hintText: '11, 24, 36...',
                        prefixIcon: Icon(Icons.tag),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'খরচ (৳) *',
                        prefixIcon: Icon(Icons.money),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'খরচের পরিমাণ দিন';
                        }
                        if (double.tryParse(val.trim()) == null) {
                          return 'সঠিক সংখ্যা দিন';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Picker
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
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'চিকিৎসা সংক্রান্ত নোট ও পরামর্শ (ঐচ্ছিক)',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveTreatment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  'চিকিৎসা রেকর্ড সংরক্ষণ করুন',
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
