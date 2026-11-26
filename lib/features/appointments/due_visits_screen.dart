import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../data/models/clinic_models.dart';

class DueVisitsScreen extends ConsumerWidget {
  const DueVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueAsync = ref.watch(overdueVisitsProvider);
    final upcomingAsync = ref.watch(upcomingVisitsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ভিজিট ও ফলো-আপ (Due Visits)'),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'বকেয়া / মিসড ভিজিট'),
              Tab(text: 'আজ ও আসন্ন ভিজিট'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _VisitsList(
              asyncVisits: overdueAsync,
              isOverdue: true,
              emptyText: 'কোনো বকেয়া/মিসড ভিজিট নেই',
            ),
            _VisitsList(
              asyncVisits: upcomingAsync,
              isOverdue: false,
              emptyText: 'কোনো আসন্ন ফলো-আপ ভিজিট নেই',
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitsList extends ConsumerWidget {
  final AsyncValue<List<AppointmentWithPatient>> asyncVisits;
  final bool isOverdue;
  final String emptyText;

  const _VisitsList({
    required this.asyncVisits,
    required this.isOverdue,
    required this.emptyText,
  });

  static final _dateTimeFormat = DateFormat('EEE, dd MMM yyyy • hh:mm a');
  static final _shortDateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncVisits.when(
      data: (visits) {
        if (visits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOverdue ? Icons.event_available : Icons.event_note,
                  size: 64,
                  color: Colors.teal.shade200,
                ),
                const SizedBox(height: 12),
                Text(
                  emptyText,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: visits.length,
          itemBuilder: (ctx, i) {
            final item = visits[i];
            final appt = item.appointment;
            final patient = item.patient;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isOverdue ? Colors.orange.shade200 : Colors.teal.shade100,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push('/patients/${patient.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  patient.phone,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            isOverdue ? 'বকেয়া ভিজিট' : 'ফলো-আপ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isOverdue
                                  ? Colors.orange.shade900
                                  : Colors.teal.shade900,
                            ),
                          ),
                          backgroundColor: isOverdue
                              ? Colors.orange.shade50
                              : Colors.teal.shade50,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 15, color: Colors.teal),
                        const SizedBox(width: 6),
                        Text(
                          _dateTimeFormat.format(appt.appointmentDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (appt.note != null && appt.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'নোট: ${appt.note}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await ref
                                  .read(databaseProvider)
                                  .updateAppointmentStatus(
                                    appt.id,
                                    AppConstants.statusCompleted,
                                  );
                              ref.invalidate(todayAppointmentCountProvider);
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 17),
                            label: const Text('সম্পন্ন',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'কল করুন',
                          onPressed: () =>
                              WhatsAppHelper.callPhone(patient.phone),
                          icon: const Icon(Icons.call, size: 18),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'WhatsApp ভিজিট রিমাইন্ডার',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade800,
                          ),
                          onPressed: () {
                            final doctor = ref
                                    .read(authRepositoryProvider)
                                    .currentName ??
                                'My Dental Clinic';
                            final dateStr =
                                _shortDateFormat.format(appt.appointmentDate);
                            final msg = isOverdue
                                ? 'আসসালামু আলাইকুম ${patient.name},\nআপনার ডেন্টাল ফলো-আপ ভিজিট ($dateStr) নির্ধারিত ছিল। অনুগ্রহ করে পরবর্তী ভিজিটের জন্য ক্লিনিকে যোগাযোগ করুন।\n— $doctor'
                                : 'আসসালামু আলাইকুম ${patient.name},\nআগামী $dateStr তারিখে আপনার ডেন্টাল চেক-আপ / ফলো-আপ ভিজিট রয়েছে।\n— $doctor';
                            WhatsAppHelper.openWhatsAppChat(
                              phone: patient.phone,
                              message: msg,
                            );
                          },
                          icon: const Icon(Icons.chat, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('ত্রুটি: $e')),
    );
  }
}
