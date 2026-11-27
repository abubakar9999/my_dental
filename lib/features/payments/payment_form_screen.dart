import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../data/local/database.dart';
import 'billing_pdf.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final int patientId;

  const PaymentFormScreen({super.key, required this.patientId});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  String _selectedMethod = AppConstants.paymentMethods.first;
  String _selectedCategory = AppConstants.paymentCategories[1];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final _currencyFormat = NumberFormat('#,##0', 'en_US');
  final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  void dispose() {
    _amountController.dispose();
    _discountController.dispose();
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

  void _applyPercentageDiscount(int percent, double currentDue) {
    final base = currentDue > 0
        ? currentDue
        : (double.tryParse(_amountController.text.trim()) ?? 0.0);
    if (base <= 0) return;

    final disc = (base * percent / 100).roundToDouble();
    setState(() {
      _discountController.text = disc.toStringAsFixed(0);
      if (currentDue > 0) {
        final netPay = (currentDue - disc).clamp(0.0, double.infinity);
        _amountController.text = netPay.toStringAsFixed(0);
      }
    });
  }

  Future<void> _savePayment({bool shareReceipt = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0.0;
    if (amount + discount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('পেমেন্ট অথবা ডিসকাউন্টের পরিমাণ ০-এর বেশি হতে হবে'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final notes = _notesController.text.trim();

      await db.insertPayment(
        PaymentsCompanion.insert(
          patientId: widget.patientId,
          amount: amount,
          discount: drift.Value(discount),
          category: drift.Value(_selectedCategory),
          notes: drift.Value(notes.isEmpty ? null : notes),
          date: _selectedDate,
          method: _selectedMethod,
        ),
      );

      ref.invalidate(totalPaidForPatientProvider(widget.patientId));
      ref.invalidate(totalDiscountForPatientProvider(widget.patientId));
      ref.invalidate(totalDuesProvider);
      ref.invalidate(todayIncomeProvider);
      ref.invalidate(monthlyIncomeProvider);

      if (shareReceipt && mounted) {
        final patient = await db.getPatient(widget.patientId);
        final treatments = await db.getTreatmentsForPatient(widget.patientId);
        final invs =
            await db.watchInvestigationsForPatient(widget.patientId).first;
        final payments = await db.getPaymentsForPatient(widget.patientId);
        final settings = ref.read(clinicSettingsProvider);
        final doctor = ref.read(authRepositoryProvider).currentName;

        await BillingPdfGenerator.shareInvoiceToWhatsApp(
          patient: patient,
          treatments: treatments,
          investigations: invs,
          payments: payments,
          clinicName: settings.clinicName,
          clinicPhone: settings.clinicPhone,
          doctorName: doctor,
          latestPaid: amount,
          latestDiscount: discount,
          latestMethod: _selectedMethod,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পেমেন্ট ও ডিসকাউন্ট সফলভাবে সংরক্ষিত হয়েছে'),
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
    final totalDiscountAsync =
        ref.watch(totalDiscountForPatientProvider(widget.patientId));
    final visitFee = ref.watch(clinicSettingsProvider).firstVisitFee;

    final cost = totalCostAsync.valueOrNull ?? 0.0;
    final paid = totalPaidAsync.valueOrNull ?? 0.0;
    final prevDiscount = totalDiscountAsync.valueOrNull ?? 0.0;
    final currentDue = (cost - (paid + prevDiscount)).clamp(0.0, double.infinity);

    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final enteredDiscount =
        double.tryParse(_discountController.text.trim()) ?? 0.0;
    final projectedDue =
        (currentDue - (enteredAmount + enteredDiscount)).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('পেমেন্ট ও ডিসকাউন্ট'),
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
                color: AppTheme.tintedBg(
                  context,
                  Colors.teal.shade50,
                  const Color(0xFF142D2A),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.tintedBg(
                              context,
                              Colors.teal.shade100,
                              Colors.teal.withAlpha(50),
                            ),
                            radius: 24,
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.adaptiveColor(
                                context,
                                Colors.teal.shade800,
                                Colors.tealAccent.shade200,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'বর্তমান বাকি (Current Due)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.mutedText(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${_currencyFormat.format(currentDue)}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: currentDue > 0
                                        ? AppTheme.adaptiveColor(context,
                                            Colors.red, Colors.redAccent.shade100)
                                        : AppTheme.adaptiveColor(context,
                                            Colors.green, Colors.greenAccent.shade200),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'মোট বিল: ৳${_currencyFormat.format(cost)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'জমা: ৳${_currencyFormat.format(paid)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.adaptiveColor(context,
                                  Colors.green.shade800, Colors.greenAccent.shade200),
                            ),
                          ),
                          Text(
                            'ছাড়: ৳${_currencyFormat.format(prevDiscount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.adaptiveColor(context,
                                  Colors.orange.shade900, Colors.orangeAccent.shade200),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Category Chips
              const Text(
                'কালেকশনের ধরন (Category)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: AppConstants.paymentCategories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _selectedCategory = cat;
                      if (cat.contains('ভিজিট') &&
                          _amountController.text.trim().isEmpty) {
                        _amountController.text = visitFee.toStringAsFixed(0);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Quick Amount Fill Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (currentDue > 0)
                    ActionChip(
                      label: Text('পূর্ণ বাকি (৳${currentDue.toStringAsFixed(0)})'),
                      backgroundColor: Colors.teal.shade50,
                      onPressed: () {
                        setState(() {
                          final net = (currentDue - enteredDiscount)
                              .clamp(0.0, double.infinity);
                          _amountController.text = net.toStringAsFixed(0);
                        });
                      },
                    ),
                  ActionChip(
                    label: Text('ভিজিট ৳${visitFee.toStringAsFixed(0)}'),
                    onPressed: () => setState(
                      () => _amountController.text = visitFee.toStringAsFixed(0),
                    ),
                  ),
                  ActionChip(
                    label: const Text('৳২,০০০'),
                    onPressed: () =>
                        setState(() => _amountController.text = '2000'),
                  ),
                  ActionChip(
                    label: const Text('৳৫,০০০'),
                    onPressed: () =>
                        setState(() => _amountController.text = '5000'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Payment Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'পরিশোধের পরিমাণ (৳) *',
                  hintText: '0, 1000, 2000...',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'টাকার পরিমাণ দিন (শুধু ছাড় হলে 0 লিখুন)';
                  }
                  final amount = double.tryParse(val.trim());
                  if (amount == null || amount < 0) {
                    return 'সঠিক সংখ্যা দিন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Discount Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.tintedBg(
                    context,
                    Colors.orange.shade50.withAlpha(110),
                    Colors.orange.withAlpha(28),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.adaptiveColor(
                      context,
                      Colors.orange.shade200,
                      Colors.orange.withAlpha(90),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.discount_outlined,
                          size: 18,
                          color: AppTheme.adaptiveColor(context,
                              Colors.deepOrange, Colors.orangeAccent.shade200),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ডিসকাউন্ট / ছাড় (Discount Process)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.adaptiveColor(context,
                                Colors.deepOrange, Colors.orangeAccent.shade200),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [5, 10, 15, 20].map((pct) {
                        return ActionChip(
                          label: Text('$pct% ছাড়',
                              style: const TextStyle(fontSize: 11)),
                          onPressed: () =>
                              _applyPercentageDiscount(pct, currentDue),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'ডিসকাউন্ট পরিমাণ (৳)',
                        isDense: true,
                      ),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final d = double.tryParse(val.trim());
                          if (d == null || d < 0) {
                            return 'সঠিক ডিসকাউন্ট দিন';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Live Projection Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.tintedBg(
                    context,
                    Colors.blueGrey.shade50,
                    const Color(0xFF1A2828),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'মোট সমন্বয়: ৳${_currencyFormat.format(enteredAmount + enteredDiscount)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      'পরবর্তী বকেয়া: ৳${_currencyFormat.format(projectedDue)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: projectedDue > 0
                            ? AppTheme.adaptiveColor(
                                context, Colors.red, Colors.redAccent.shade100)
                            : AppTheme.adaptiveColor(context, Colors.teal,
                                Colors.tealAccent.shade200),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'মন্তব্য / কিস্তি নোট (ঐচ্ছিক)',
                  hintText: 'উদাঃ ১ম ভিজিট + স্কেলিং ডিসকাউন্ট',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              // Submit + Share Receipt Buttons
              ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : () => _savePayment(shareReceipt: true),
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
                  'জমা ও WhatsApp রিসিপ্ট PDF',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : () => _savePayment(shareReceipt: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text(
                  'শুধু পেমেন্ট জমা করুন',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
