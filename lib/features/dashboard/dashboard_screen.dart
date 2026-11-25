import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static final _currencyFormat = NumberFormat('#,##0', 'en_US');

  String _formatCurrency(double amount) {
    return '৳${_currencyFormat.format(amount)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAppointments = ref.watch(todayAppointmentCountProvider);
    final totalPatients = ref.watch(patientCountProvider);
    final todayIncome = ref.watch(todayIncomeProvider);
    final monthlyIncome = ref.watch(monthlyIncomeProvider);
    final totalDues = ref.watch(totalDuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ড্যাশবোর্ড'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayAppointmentCountProvider);
          ref.invalidate(patientCountProvider);
          ref.invalidate(todayIncomeProvider);
          ref.invalidate(monthlyIncomeProvider);
          ref.invalidate(totalDuesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Stat Cards Grid ---
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  // 1. Today's Appointments
                  _buildStatCard(
                    context,
                    icon: Icons.calendar_today,
                    label: 'আজকের রোগী',
                    asyncValue: todayAppointments,
                    formatValue: (val) => val.toString(),
                    color: Colors.teal,
                  ),

                  // 2. Total Patients
                  _buildStatCard(
                    context,
                    icon: Icons.people,
                    label: 'মোট রোগী',
                    asyncValue: totalPatients,
                    formatValue: (val) => val.toString(),
                    color: Colors.teal.shade700,
                  ),

                  // 3. Today's Income
                  _buildStatCard(
                    context,
                    icon: Icons.attach_money,
                    label: 'আজকের আয়',
                    asyncValue: todayIncome,
                    formatValue: (val) => _formatCurrency(val.toDouble()),
                    color: Colors.green.shade600,
                  ),

                  // 4. Monthly Income
                  _buildStatCard(
                    context,
                    icon: Icons.trending_up,
                    label: 'এই মাসের আয়',
                    asyncValue: monthlyIncome,
                    formatValue: (val) => _formatCurrency(val.toDouble()),
                    color: Colors.blue.shade600,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 5. Total Dues Card
              totalDues.when(
                data: (dues) {
                  final dueAmount = dues.toDouble();
                  final isOverdue = dueAmount > 0;
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isOverdue
                        ? Colors.red.shade50
                        : Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isOverdue
                                ? Colors.red.shade100
                                : Colors.teal.shade100,
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: isOverdue ? Colors.red : Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'মোট বাকি',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(dueAmount),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isOverdue
                                        ? Colors.red
                                        : Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: $e'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Quick Actions ---
              Text(
                'দ্রুত কার্যক্রম',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.person_add,
                      label: 'নতুন রোগী',
                      color: Colors.teal,
                      onTap: () => context.push('/patients/add'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.event_available,
                      label: 'নতুন অ্যাপয়েন্টমেন্ট',
                      color: Colors.teal.shade700,
                      onTap: () => context.push('/appointments/add'),
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

  Widget _buildStatCard<T>(
    BuildContext context, {
    required IconData icon,
    required String label,
    required AsyncValue<T> asyncValue,
    required String Function(T) formatValue,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const Spacer(),
            asyncValue.when(
              data: (val) => Text(
                formatValue(val),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              loading: () => const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
              error: (e, _) => const Text(
                '—',
                style: TextStyle(fontSize: 22, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
