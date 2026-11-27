import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../data/local/database.dart';
import '../dental_chart/dental_chart_view.dart';
import '../payments/billing_pdf.dart';
import '../prescriptions/prescription_pdf.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final int patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormat = NumberFormat('#,##0', 'en_US');
  final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
  final _shortDateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDeletePatient(Patient patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('রোগী ডিলিট নিশ্চিতকরণ'),
        content: Text(
          'আপনি কি নিশ্চিত যে "${patient.name}" এর সকল তথ্য ও চিকিৎসার ইতিহাস ডিলিট করতে চান? এটি পূর্বাবস্থায় ফিরিয়ে আনা যাবে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(databaseProvider).deletePatient(widget.patientId);
              ref.invalidate(patientCountProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('রোগী মুছে ফেলা হয়েছে')),
                );
                context.pop();
              }
            },
            child: const Text('ডিলিট করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientProvider(widget.patientId));
    final treatmentsStream = ref.watch(treatmentsForPatientProvider(widget.patientId));
    final investigationsStream = ref.watch(investigationsForPatientProvider(widget.patientId));
    final paymentsStream = ref.watch(paymentsForPatientProvider(widget.patientId));
    final prescriptionsStream = ref.watch(prescriptionsForPatientProvider(widget.patientId));
    final appointmentsFuture = ref.watch(appointmentsForPatientProvider(widget.patientId));

    final totalCostFuture = ref.watch(totalCostForPatientProvider(widget.patientId));
    final totalPaidFuture = ref.watch(totalPaidForPatientProvider(widget.patientId));
    final totalDiscountFuture =
        ref.watch(totalDiscountForPatientProvider(widget.patientId));

    return patientAsync.when(
      data: (patient) {
        return Scaffold(
          appBar: AppBar(
            title: Text(patient.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'সম্পাদনা',
                onPressed: () => context.push('/patients/${patient.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'ডিলিট',
                onPressed: () => _confirmDeletePatient(patient),
              ),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Basic Patient Info Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.teal.shade100,
                                      child: Text(
                                        patient.name.isNotEmpty
                                            ? patient.name[0].toUpperCase()
                                            : 'P',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            patient.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 16, color: Colors.teal),
                                              const SizedBox(width: 6),
                                              Text(
                                                patient.phone,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (patient.age != null || patient.gender != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '${patient.age != null ? 'বয়স: ${patient.age}' : ''} ${patient.gender != null ? '• ${patient.gender}' : ''}',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (patient.address != null && patient.address!.isNotEmpty) ...[
                                  const Divider(height: 24),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          patient.address!,
                                          style: TextStyle(color: Colors.grey.shade800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (patient.medicalHistory != null &&
                                    patient.medicalHistory!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.history_edu, size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'হিস্ট্রি: ${patient.medicalHistory}',
                                          style: const TextStyle(color: Colors.blueGrey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (patient.allergies != null &&
                                    patient.allergies!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'অ্যালার্জি: ${patient.allergies}',
                                            style: TextStyle(
                                              color: Colors.red.shade800,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Balance / Dues Summary Card
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: AppTheme.tintedBg(
                                    context, Colors.teal.shade50, const Color(0xFF142D2A)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('মোট খরচ',
                                          style: TextStyle(
                                              fontSize: 12, color: AppTheme.mutedText(context))),
                                      const SizedBox(height: 4),
                                      totalCostFuture.when(
                                        data: (cost) => Text(
                                          '৳${_currencyFormat.format(cost)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.adaptiveColor(context,
                                                Colors.teal, Colors.tealAccent.shade200),
                                          ),
                                        ),
                                        loading: () => const Text('...'),
                                        error: (_, __) => const Text('৳0'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Card(
                                color: AppTheme.tintedBg(
                                    context, Colors.green.shade50, const Color(0xFF132E1C)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('পরিশোধিত',
                                          style: TextStyle(
                                              fontSize: 12, color: AppTheme.mutedText(context))),
                                      const SizedBox(height: 4),
                                      totalPaidFuture.when(
                                        data: (paid) => Text(
                                          '৳${_currencyFormat.format(paid)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.adaptiveColor(context,
                                                Colors.green.shade700, Colors.greenAccent.shade200),
                                          ),
                                        ),
                                        loading: () => const Text('...'),
                                        error: (_, __) => const Text('৳0'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Card(
                                color: AppTheme.tintedBg(
                                    context, Colors.red.shade50, const Color(0xFF331818)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('মোট বাকি',
                                          style: TextStyle(
                                              fontSize: 12, color: AppTheme.mutedText(context))),
                                      const SizedBox(height: 4),
                                      totalCostFuture.when(
                                        data: (cost) {
                                          return totalPaidFuture.when(
                                            data: (paid) {
                                              final disc = totalDiscountFuture.valueOrNull ?? 0.0;
                                              final due = cost - (paid + disc);
                                              return Text(
                                                '৳${_currencyFormat.format(due > 0 ? due : 0)}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: due > 0
                                                      ? AppTheme.adaptiveColor(context,
                                                          Colors.red, Colors.redAccent.shade100)
                                                      : AppTheme.adaptiveColor(context,
                                                          Colors.green, Colors.greenAccent.shade200),
                                                ),
                                              );
                                            },
                                            loading: () => const Text('...'),
                                            error: (_, __) => const Text('৳0'),
                                          );
                                        },
                                        loading: () => const Text('...'),
                                        error: (_, __) => const Text('৳0'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if ((totalDiscountFuture.valueOrNull ?? 0.0) > 0) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Chip(
                              avatar: const Icon(Icons.discount_outlined,
                                  size: 16, color: Colors.deepOrange),
                              label: Text(
                                'মোট ডিসকাউন্ট: ৳${_currencyFormat.format(totalDiscountFuture.valueOrNull ?? 0.0)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepOrange),
                              ),
                              backgroundColor: Colors.orange.shade50,
                              side: BorderSide(color: Colors.orange.shade200),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final db = ref.read(databaseProvider);
                                  final txs = await db.getTreatmentsForPatient(patient.id);
                                  final invs = await db.watchInvestigationsForPatient(patient.id).first;
                                  final pays = await db.getPaymentsForPatient(patient.id);
                                  final settings = ref.read(clinicSettingsProvider);
                                  final doctor = ref.read(authRepositoryProvider).currentName;
                                  await BillingPdfGenerator.printInvoice(
                                    patient: patient,
                                    treatments: txs,
                                    investigations: invs,
                                    payments: pays,
                                    clinicName: settings.clinicName,
                                    clinicPhone: settings.clinicPhone,
                                    doctorName: doctor,
                                  );
                                },
                                icon: const Icon(Icons.receipt_long, size: 17),
                                label: const Text('বিল প্রিন্ট / PDF', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final db = ref.read(databaseProvider);
                                  final txs = await db.getTreatmentsForPatient(patient.id);
                                  final invs = await db.watchInvestigationsForPatient(patient.id).first;
                                  final pays = await db.getPaymentsForPatient(patient.id);
                                  final settings = ref.read(clinicSettingsProvider);
                                  final doctor = ref.read(authRepositoryProvider).currentName;
                                  await BillingPdfGenerator.shareInvoiceToWhatsApp(
                                    patient: patient,
                                    treatments: txs,
                                    investigations: invs,
                                    payments: pays,
                                    clinicName: settings.clinicName,
                                    clinicPhone: settings.clinicPhone,
                                    doctorName: doctor,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green.shade800,
                                  side: BorderSide(color: Colors.green.shade300),
                                ),
                                icon: const Icon(Icons.share, size: 17),
                                label: const Text('WhatsApp বিল PDF', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: Colors.teal,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.teal,
                      tabs: const [
                        Tab(text: 'ডেন্টাল চার্ট'),
                        Tab(text: 'চিকিৎসা'),
                        Tab(text: 'ইনভেস্টিগেশন'),
                        Tab(text: 'পেমেন্ট'),
                        Tab(text: 'প্রেসক্রিপশন'),
                        Tab(text: 'অ্যাপয়েন্টমেন্ট'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // 1. 2D Dental Chart Tab
                DentalChartView(patientId: widget.patientId),

                // 2. Treatments Tab
                _buildTreatmentsTab(treatmentsStream),

                // 3. Investigations Tab
                _buildInvestigationsTab(investigationsStream),

                // 4. Payments Tab
                _buildPaymentsTab(paymentsStream),

                // 5. Prescriptions Tab
                _buildPrescriptionsTab(prescriptionsStream, patient),

                // 6. Appointments Tab
                _buildAppointmentsTab(appointmentsFuture),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('ত্রুটি')),
        body: Center(child: Text('রোগীর তথ্য পাওয়া যায়নি: $e')),
      ),
    );
  }

  Widget _buildTreatmentsTab(AsyncValue<List<Treatment>> treatmentsStream) {
    return Scaffold(
      body: treatmentsStream.when(
        data: (treatments) {
          if (treatments.isEmpty) {
            return const Center(child: Text('কোনো চিকিৎসার তথ্য নেই'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: treatments.length,
            itemBuilder: (ctx, i) {
              final t = treatments[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.procedure, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '৳${_currencyFormat.format(t.cost)}',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (t.toothNumber != null && t.toothNumber!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'দাঁত #${t.toothNumber}',
                                style: TextStyle(
                                  color: Colors.teal.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _shortDateFormat.format(t.date),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      if (t.notes != null && t.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(t.notes!, style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () async {
                      await ref.read(databaseProvider).deleteTreatment(t.id);
                      ref.invalidate(totalCostForPatientProvider(widget.patientId));
                      ref.invalidate(totalDuesProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_treatment',
        onPressed: () => context.push('/patients/${widget.patientId}/treatments/add'),
        icon: const Icon(Icons.add),
        label: const Text('চিকিৎসা যোগ'),
      ),
    );
  }

  void _showAddInvestigationDialog() {
    final nameController = TextEditingController();
    final toothController = TextEditingController();
    final costController = TextEditingController(text: '0');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন ইনভেস্টিগেশন অ্যাসাইন'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: AppConstants.defaultInvestigations.map((item) {
                  final name = item['name'] as String;
                  final price = (item['price'] as num).toDouble();
                  return ActionChip(
                    label: Text(name, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      nameController.text = name;
                      costController.text = price.toStringAsFixed(0);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'পরীক্ষার নাম *',
                  hintText: 'OPG / IOPA X-Ray',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: toothController,
                decoration: const InputDecoration(
                  labelText: 'দাঁত নম্বর (ঐচ্ছিক)',
                  hintText: '36',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ফি (৳) (০ দিলে বিলে যোগ হবে না)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'নোট / নির্দেশনা',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final cost = double.tryParse(costController.text.trim()) ?? 0.0;
              final tooth = toothController.text.trim();
              final notes = notesController.text.trim();
              final db = ref.read(databaseProvider);

              await db.insertInvestigation(
                InvestigationsCompanion.insert(
                  patientId: widget.patientId,
                  testName: name,
                  toothNumber: drift.Value(tooth.isEmpty ? null : tooth),
                  cost: drift.Value(cost),
                  resultNotes: drift.Value(notes.isEmpty ? null : notes),
                  date: DateTime.now(),
                ),
              );
              ref.invalidate(totalCostForPatientProvider(widget.patientId));
              ref.invalidate(totalDuesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('অ্যাসাইন করুন'),
          ),
        ],
      ),
    );
  }

  void _showUpdateInvestigationDialog(Investigation inv) {
    String selectedStatus = inv.status;
    final notesController = TextEditingController(text: inv.resultNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(inv.testName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'স্ট্যাটাস'),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('অপেক্ষমাণ (Pending)')),
                  DropdownMenuItem(value: 'completed', child: Text('সম্পন্ন (Completed)')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedStatus = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'রিপোর্ট / ফলাফল নোট',
                  hintText: 'উদাঃ Periapical radiolucency seen...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(databaseProvider).updateInvestigationStatus(
                      inv.id,
                      selectedStatus,
                      resultNotes: notesController.text.trim(),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('আপডেট করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestigationsTab(
    AsyncValue<List<Investigation>> investigationsStream,
  ) {
    return Scaffold(
      body: investigationsStream.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('কোনো ইনভেস্টিগেশন অ্যাসাইন করা হয়নি'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final inv = items[i];
              final isDone = inv.status == 'completed';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () => _showUpdateInvestigationDialog(inv),
                  leading: CircleAvatar(
                    backgroundColor: isDone ? Colors.green.shade50 : Colors.orange.shade50,
                    child: Icon(
                      isDone ? Icons.check_circle_outline : Icons.biotech,
                      color: isDone ? Colors.green : Colors.orange.shade700,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          inv.testName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (inv.cost > 0)
                        Text(
                          '৳${_currencyFormat.format(inv.cost)}',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDone ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isDone ? 'সম্পন্ন' : 'অপেক্ষমাণ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDone ? Colors.green.shade800 : Colors.orange.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (inv.toothNumber != null && inv.toothNumber!.isNotEmpty) ...[
                            Text('দাঁত #${inv.toothNumber} • ',
                                style: const TextStyle(fontSize: 12)),
                          ],
                          Text(
                            _shortDateFormat.format(inv.date),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      if (inv.resultNotes != null && inv.resultNotes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ফলাফল/নোট: ${inv.resultNotes}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () async {
                      await ref.read(databaseProvider).deleteInvestigation(inv.id);
                      ref.invalidate(totalCostForPatientProvider(widget.patientId));
                      ref.invalidate(totalDuesProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_investigation',
        onPressed: _showAddInvestigationDialog,
        icon: const Icon(Icons.biotech),
        label: const Text('পরীক্ষা অ্যাসাইন'),
      ),
    );
  }

  Widget _buildPaymentsTab(AsyncValue<List<Payment>> paymentsStream) {
    return Scaffold(
      body: paymentsStream.when(
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text('কোনো পেমেন্টের রেকর্ড নেই'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (ctx, i) {
              final p = payments[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: Icon(Icons.payment, color: Colors.green.shade700),
                  ),
                  title: Row(
                    children: [
                      Text(
                        '৳${_currencyFormat.format(p.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (p.discount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ছাড়: ৳${_currencyFormat.format(p.discount)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${p.category} • ${p.method} • ${_shortDateFormat.format(p.date)}'
                    '${p.notes != null && p.notes!.isNotEmpty ? '\nনোট: ${p.notes}' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () async {
                      await ref.read(databaseProvider).deletePayment(p.id);
                      ref.invalidate(totalPaidForPatientProvider(widget.patientId));
                      ref.invalidate(totalDiscountForPatientProvider(widget.patientId));
                      ref.invalidate(totalDuesProvider);
                      ref.invalidate(todayIncomeProvider);
                      ref.invalidate(monthlyIncomeProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_payment',
        onPressed: () => context.push('/patients/${widget.patientId}/payments/add'),
        icon: const Icon(Icons.add),
        label: const Text('পেমেন্ট গ্রহণ'),
      ),
    );
  }

  Widget _buildPrescriptionsTab(
    AsyncValue<List<Prescription>> prescriptionsStream,
    Patient patient,
  ) {
    return Scaffold(
      body: prescriptionsStream.when(
        data: (prescriptions) {
          if (prescriptions.isEmpty) {
            return const Center(child: Text('কোনো প্রেসক্রিপশন নেই'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (ctx, i) {
              final rx = prescriptions[i];
              List<dynamic> medList = [];
              try {
                medList = jsonDecode(rx.medicines) as List<dynamic>;
              } catch (_) {}

              List<dynamic> invList = [];
              try {
                invList = jsonDecode(rx.investigations) as List<dynamic>;
              } catch (_) {}

              final convertedMeds =
                  medList.map((m) => Map<String, dynamic>.from(m as Map)).toList();
              final convertedInvs =
                  invList.map((m) => Map<String, dynamic>.from(m as Map)).toList();
              final profile = ref.read(authRepositoryProvider).currentProfile;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description_outlined, color: Colors.teal),
                              const SizedBox(width: 8),
                              Text(
                                _shortDateFormat.format(rx.date),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.share, color: Colors.green.shade700),
                                tooltip: 'WhatsApp-এ PDF শেয়ার',
                                onPressed: () async {
                                  final db = ref.read(databaseProvider);
                                  final cost = await db.getTotalCostForPatient(patient.id);
                                  final paid = await db.getTotalPaidForPatient(patient.id);
                                  final due = cost - paid;
                                  await PrescriptionPdfGenerator.sharePdf(
                                    patientName: patient.name,
                                    patientPhone: patient.phone,
                                    patientAge: patient.age ?? 0,
                                    medicines: convertedMeds,
                                    investigations: convertedInvs,
                                    advice: rx.advice,
                                    nextVisitDate: rx.nextVisitDate,
                                    doctorName: rx.doctorName ?? profile?.fullName,
                                    doctorQualification: profile?.qualification,
                                    doctorPhone: profile?.phone,
                                    currentDue: due > 0 ? due : null,
                                    prescriptionDate: rx.date,
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.chat_outlined, color: Colors.green.shade600),
                                tooltip: 'সরাসরি WhatsApp চ্যাট',
                                onPressed: () async {
                                  final text = PrescriptionPdfGenerator.buildWhatsAppSummaryText(
                                    patientName: patient.name,
                                    medicines: convertedMeds,
                                    investigations: convertedInvs,
                                    advice: rx.advice,
                                    nextVisitDate: rx.nextVisitDate,
                                    doctorName: rx.doctorName ?? profile?.fullName,
                                  );
                                  await WhatsAppHelper.openWhatsAppChat(
                                    phone: patient.phone,
                                    message: text,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.print, color: Colors.teal),
                                tooltip: 'প্রিন্ট / PDF',
                                onPressed: () async {
                                  final db = ref.read(databaseProvider);
                                  final cost = await db.getTotalCostForPatient(patient.id);
                                  final paid = await db.getTotalPaidForPatient(patient.id);
                                  final due = cost - paid;
                                  await PrescriptionPdfGenerator.generate(
                                    patientName: patient.name,
                                    patientPhone: patient.phone,
                                    patientAge: patient.age ?? 0,
                                    medicines: convertedMeds,
                                    investigations: convertedInvs,
                                    advice: rx.advice,
                                    nextVisitDate: rx.nextVisitDate,
                                    doctorName: rx.doctorName ?? profile?.fullName,
                                    doctorQualification: profile?.qualification,
                                    doctorPhone: profile?.phone,
                                    currentDue: due > 0 ? due : null,
                                    prescriptionDate: rx.date,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                onPressed: () async {
                                  await ref.read(databaseProvider).deletePrescription(rx.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      if (convertedInvs.isNotEmpty) ...[
                        const Text(
                          'পরীক্ষা (Investigations):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal),
                        ),
                        const SizedBox(height: 2),
                        ...convertedInvs.map((inv) {
                          final tooth = inv['toothNumber']?.toString() ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Text(
                              '• ${inv['name'] ?? ''}${tooth.isNotEmpty ? ' (দাঁত #$tooth)' : ''}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }),
                        const SizedBox(height: 6),
                      ],
                      ...medList.map((m) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '• ${m['name'] ?? ''} - ${m['dose'] ?? ''} (${m['duration'] ?? ''}) - ${m['timing'] ?? ''}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }),
                      if (rx.advice != null && rx.advice!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'পরামর্শ: ${rx.advice}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (rx.nextVisitDate != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'পরবর্তী ভিজিট: ${_shortDateFormat.format(rx.nextVisitDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_rx',
        onPressed: () => context.push('/patients/${widget.patientId}/prescriptions/add'),
        icon: const Icon(Icons.add),
        label: const Text('প্রেসক্রিপশন তৈরি'),
      ),
    );
  }

  Widget _buildAppointmentsTab(AsyncValue<List<Appointment>> appointmentsFuture) {
    return Scaffold(
      body: appointmentsFuture.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('কোনো অ্যাপয়েন্টমেন্ট নেই'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (ctx, i) {
              final a = appointments[i];
              Color statusColor;
              String statusText;
              switch (a.status) {
                case 'completed':
                  statusColor = Colors.green;
                  statusText = 'সম্পন্ন';
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  statusText = 'বাতিল';
                  break;
                default:
                  statusColor = Colors.orange;
                  statusText = 'অপেক্ষমাণ';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.15),
                    child: Icon(Icons.event, color: statusColor),
                  ),
                  title: Text(
                    _dateFormat.format(a.appointmentDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: a.note != null && a.note!.isNotEmpty
                      ? Text(a.note!)
                      : null,
                  trailing: Chip(
                    label: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                    backgroundColor: statusColor.withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_appt',
        onPressed: () => context.push('/appointments/add?patientId=${widget.patientId}'),
        icon: const Icon(Icons.add),
        label: const Text('অ্যাপয়েন্টমেন্ট দিন'),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
