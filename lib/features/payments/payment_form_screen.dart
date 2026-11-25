import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final int patientId;

  const PaymentFormScreen({super.key, required this.patientId});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String _selectedMethod = AppConstants.paymentMethods.first;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final _currencyFormat = NumberFormat('#,##0', 'en_US');
  final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  void dispose() {
    _amountController.dispose();
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

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final db = ref.read(databaseProvider);

      await db.insertPayment(
        PaymentsCompanion.insert(
          patientId: widget.patientId,
          amount: amount,
          date: _selectedDate,
          method: _selectedMethod,
        ),
      );

      ref.invalidate(totalPaidForPatientProvider(widget.patientId));
      ref.invalidate(totalDuesProvider);
      ref.invalidate(todayIncomeProvider);
      ref.invalidate(monthlyIncomeProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পেমেন্ট সফলভাবে গ্রহণ করা হয়েছে'),
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
    final totalCostAsync =
        ref.watch(totalCostForPatientProvider(widget.patientId));
    final totalPaidAsync =
        ref.watch(totalPaidForPatientProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('পেমেন্ট গ্রহণ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Due Balance Summary Card
              Card(
                color: Colors.teal.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        radius: 24,
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'বর্তমান বাকি (Due)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            totalCostAsync.when(
                              data: (cost) {
                                return totalPaidAsync.when(
                                  data: (paid) {
                                    final due = cost - paid;
                                    return Text(
                                      '৳${_currencyFormat.format(due > 0 ? due : 0)}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: due > 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    );
                                  },
                                  loading: () => const Text('লোড হচ্ছে...'),
                                  error: (_, __) => const Text('৳0'),
                                );
                              },
                              loading: () => const Text('লোড হচ্ছে...'),
                              error: (_, __) => const Text('৳0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'পরিশোধের পরিমাণ (৳) *',
                  hintText: '500, 1000...',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'টাকার পরিমাণ দিন';
                  }
                  final amount = double.tryParse(val.trim());
                  if (amount == null || amount <= 0) {
                    return 'সঠিক ধনাত্মক সংখ্যা দিন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Payment Method Dropdown
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'পেমেন্ট মাধ্যম *',
                  prefixIcon: Icon(Icons.payment_outlined),
                ),
                items: AppConstants.paymentMethods.map((m) {
                  return DropdownMenuItem<String>(
                    value: m,
                    child: Text(m),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedMethod = val);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'পেমেন্টের তারিখ *',
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
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text(
                  'পেমেন্ট জমা করুন',
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
