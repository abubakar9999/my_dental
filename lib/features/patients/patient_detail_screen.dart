import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/local/database.dart';
import '../dental_chart/dental_chart_view.dart';
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
    _tabController = TabController(length: 5, vsync: this);
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
    final paymentsStream = ref.watch(paymentsForPatientProvider(widget.patientId));
    final prescriptionsStream = ref.watch(prescriptionsForPatientProvider(widget.patientId));
    final appointmentsFuture = ref.watch(appointmentsForPatientProvider(widget.patientId));

    final totalCostFuture = ref.watch(totalCostForPatientProvider(widget.patientId));
    final totalPaidFuture = ref.watch(totalPaidForPatientProvider(widget.patientId));

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
                                color: Colors.teal.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('মোট খরচ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      totalCostFuture.when(
                                        data: (cost) => Text(
                                          '৳${_currencyFormat.format(cost)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
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
                                color: Colors.green.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('পরিশোধিত', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      totalPaidFuture.when(
                                        data: (paid) => Text(
                                          '৳${_currencyFormat.format(paid)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
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
                                color: Colors.red.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('মোট বাকি', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      totalCostFuture.when(
                                        data: (cost) {
                                          return totalPaidFuture.when(
                                            data: (paid) {
                                              final due = cost - paid;
                                              return Text(
                                                '৳${_currencyFormat.format(due > 0 ? due : 0)}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: due > 0 ? Colors.red : Colors.green,
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
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.teal,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.teal,
                      tabs: const [
                        Tab(text: 'ডেন্টাল চার্ট'),
                        Tab(text: 'চিকিৎসা'),
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

                // 3. Payments Tab
                _buildPaymentsTab(paymentsStream),

                // 4. Prescriptions Tab
                _buildPrescriptionsTab(prescriptionsStream, patient),

                // 5. Appointments Tab
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
                  title: Text(
                    '৳${_currencyFormat.format(p.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('${p.method} • ${_shortDateFormat.format(p.date)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () async {
                      await ref.read(databaseProvider).deletePayment(p.id);
                      ref.invalidate(totalPaidForPatientProvider(widget.patientId));
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
                            children: [
                              IconButton(
                                icon: const Icon(Icons.print, color: Colors.teal),
                                tooltip: 'প্রিন্ট / শেয়ার PDF',
                                onPressed: () {
                                  final converted = medList
                                      .map((m) => Map<String, dynamic>.from(m as Map))
                                      .toList();
                                  PrescriptionPdfGenerator.generate(
                                    patientName: patient.name,
                                    patientPhone: patient.phone,
                                    patientAge: patient.age ?? 0,
                                    medicines: converted,
                                    advice: rx.advice,
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
