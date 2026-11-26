import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../data/local/database.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  final _timeFormat = DateFormat('hh:mm a');
  final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync =
        ref.watch(appointmentsForDateProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাপয়েন্টমেন্ট ও ভিজিট'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/appointments/due-visits'),
            icon: const Icon(Icons.event_repeat, color: Colors.white, size: 18),
            label: const Text(
              'Due ভিজিট',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.teal),
                  onPressed: () => _changeDate(-1),
                  tooltip: 'আগের দিন',
                ),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          _dateFormat.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.teal),
                  onPressed: () => _changeDate(1),
                  tooltip: 'পরের দিন',
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) {
                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'এই দিনে কোনো অ্যাপয়েন্টমেন্ট নেই',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return _AppointmentCard(
                      appointment: appt,
                      timeFormat: _timeFormat,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('ত্রুটি: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/appointments/add'),
        icon: const Icon(Icons.add),
        label: const Text('নতুন অ্যাপয়েন্টমেন্ট'),
      ),
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final DateFormat timeFormat;

  const _AppointmentCard({
    required this.appointment,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    String statusText;
    switch (appointment.status) {
      case AppConstants.statusCompleted:
        statusColor = Colors.green;
        statusText = 'সম্পন্ন';
        break;
      case AppConstants.statusCancelled:
        statusColor = Colors.red;
        statusText = 'বাতিল';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'অপেক্ষমাণ';
    }

    return FutureBuilder<Patient>(
      future: ref.read(databaseProvider).getPatient(appointment.patientId),
      builder: (context, snapshot) {
        final patientName = snapshot.data?.name ?? 'লোড হচ্ছে...';
        final patientPhone = snapshot.data?.phone ?? '';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (patientPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              patientPhone,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      initialValue: appointment.status,
                      onSelected: (newStatus) async {
                        await ref
                            .read(databaseProvider)
                            .updateAppointmentStatus(
                              appointment.id,
                              newStatus,
                            );
                        ref.invalidate(todayAppointmentCountProvider);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: AppConstants.statusWaiting,
                          child: Text('অপেক্ষমাণ (Waiting)'),
                        ),
                        const PopupMenuItem(
                          value: AppConstants.statusCompleted,
                          child: Text('সম্পন্ন (Completed)'),
                        ),
                        const PopupMenuItem(
                          value: AppConstants.statusCancelled,
                          child: Text('বাতিল (Cancelled)'),
                        ),
                      ],
                      child: Chip(
                        label: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: statusColor.withOpacity(0.12),
                        side: BorderSide(color: statusColor.withOpacity(0.3)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(
                      timeFormat.format(appointment.appointmentDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    if (appointment.note != null &&
                        appointment.note!.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.notes, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.note!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (snapshot.hasData) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/patients/${appointment.patientId}'),
                          icon: const Icon(Icons.person_outline, size: 16),
                          label: const Text('রোগী প্রোফাইল',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                              '/patients/${appointment.patientId}/payments/add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.payments_outlined, size: 16),
                          label: const Text('ফি / পেমেন্ট',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filledTonal(
                        tooltip: 'কল',
                        onPressed: () => WhatsAppHelper.callPhone(patientPhone),
                        icon: const Icon(Icons.call, size: 18),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
