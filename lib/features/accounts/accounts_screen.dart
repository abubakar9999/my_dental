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
import '../../data/models/clinic_models.dart';

enum _AccountRange { today, thisMonth, allTime }

class AccountsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const AccountsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _AccountRange _selectedRange = _AccountRange.thisMonth;

  final _currencyFormat = NumberFormat('#,##0', 'en_US');
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void didUpdateWidget(covariant AccountsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _tabController.animateTo(widget.initialTab.clamp(0, 2));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _rangeBounds() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _AccountRange.today:
        final start = DateTime(now.year, now.month, now.day);
        return (start, start.add(const Duration(days: 1)));
      case _AccountRange.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start, end);
      case _AccountRange.allTime:
        return (DateTime(2000), DateTime(2100));
    }
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String category = AppConstants.expenseCategories.first;
    DateTime expenseDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('নতুন ক্লিনিক খরচ যোগ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'খরচের বিবরণ *',
                    hintText: 'উদাঃ ডেন্টাল ল্যাব বিল / গ্লাভস',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'ক্যাটাগরি'),
                  items: AppConstants.expenseCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => category = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'পরিমাণ (৳) *',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('তারিখ: '),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_dateFormat.format(expenseDate)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: expenseDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setDialogState(() => expenseDate = picked);
                        }
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'নোট (ঐচ্ছিক)'),
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
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text.trim()) ?? 0;
                if (title.isEmpty || amount <= 0) return;

                final notes = notesController.text.trim();
                await ref.read(databaseProvider).insertExpense(
                      ExpensesCompanion.insert(
                        title: title,
                        category: category,
                        amount: amount,
                        date: expenseDate,
                        notes: drift.Value(notes.isEmpty ? null : notes),
                      ),
                    );
                if (mounted) setState(() {});
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাকাউন্টস ও বকেয়া'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'হিসাব (Ledger)'),
            Tab(text: 'বকেয়া (Due)'),
            Tab(text: 'খরচ (Expense)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryLedgerTab(),
          _buildDuePatientsTab(),
          _buildExpensesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_expense_fab',
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('খরচ যোগ'),
      ),
    );
  }

  Widget _buildSummaryLedgerTab() {
    final (start, end) = _rangeBounds();
    final db = ref.watch(databaseProvider);
    final totalDuesAsync = ref.watch(totalDuesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(totalDuesProvider);
        ref.invalidate(allExpensesProvider);
        setState(() {});
      },
      child: FutureBuilder<
          ({
            double income,
            double expense,
            double discount,
            List<PaymentWithPatient> payments,
          })>(
        future: () async {
          final income = await db.getTotalIncomeInRange(start, end);
          final expense = await db.getTotalExpenseInRange(start, end);
          final discount = await db.getTotalDiscountInRange(start, end);
          final payments = await db.getPaymentsInRangeWithPatient(start, end);
          return (
            income: income,
            expense: expense,
            discount: discount,
            payments: payments,
          );
        }(),
        builder: (context, snapshot) {
          final income = snapshot.data?.income ?? 0.0;
          final expense = snapshot.data?.expense ?? 0.0;
          final discount = snapshot.data?.discount ?? 0.0;
          final netProfit = income - expense;
          final payments = snapshot.data?.payments ?? [];

          final byMethod = <String, double>{};
          final byCategory = <String, double>{};
          for (final item in payments) {
            byMethod[item.payment.method] =
                (byMethod[item.payment.method] ?? 0.0) + item.payment.amount;
            byCategory[item.payment.category] =
                (byCategory[item.payment.category] ?? 0.0) + item.payment.amount;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Period filter chips
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('আজ'),
                    selected: _selectedRange == _AccountRange.today,
                    onSelected: (_) =>
                        setState(() => _selectedRange = _AccountRange.today),
                  ),
                  ChoiceChip(
                    label: const Text('এই মাস'),
                    selected: _selectedRange == _AccountRange.thisMonth,
                    onSelected: (_) =>
                        setState(() => _selectedRange = _AccountRange.thisMonth),
                  ),
                  ChoiceChip(
                    label: const Text('সব সময়'),
                    selected: _selectedRange == _AccountRange.allTime,
                    onSelected: (_) =>
                        setState(() => _selectedRange = _AccountRange.allTime),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Summary cards row 1: Income & Expense
              Row(
                children: [
                  Expanded(
                    child: _SummaryBox(
                      title: 'মোট আয় (Income)',
                      amount: '৳${_currencyFormat.format(income)}',
                      color: Colors.green.shade700,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryBox(
                      title: 'মোট খরচ (Expense)',
                      amount: '৳${_currencyFormat.format(expense)}',
                      color: Colors.orange.shade800,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Summary cards row 2: Net Profit & Total Dues
              Row(
                children: [
                  Expanded(
                    child: _SummaryBox(
                      title: 'নিট লাভ (Net Profit)',
                      amount: '৳${_currencyFormat.format(netProfit)}',
                      color: netProfit >= 0 ? Colors.teal : Colors.red,
                      icon: Icons.account_balance,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _tabController.animateTo(1),
                      borderRadius: BorderRadius.circular(12),
                      child: totalDuesAsync.when(
                        data: (dues) => _SummaryBox(
                          title: 'মোট বকেয়া (Due)',
                          amount: '৳${_currencyFormat.format(dues)}',
                          color: dues > 0 ? Colors.red.shade700 : Colors.teal,
                          icon: Icons.warning_amber_rounded,
                        ),
                        loading: () => const _SummaryBox(
                          title: 'মোট বকেয়া',
                          amount: '...',
                          color: Colors.grey,
                          icon: Icons.hourglass_empty,
                        ),
                        error: (_, _) => const _SummaryBox(
                          title: 'মোট বকেয়া',
                          amount: '৳0',
                          color: Colors.grey,
                          icon: Icons.error_outline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (discount > 0) ...[
                const SizedBox(height: 10),
                Builder(builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Card(
                    color: isDark
                        ? Colors.orange.withAlpha(35)
                        : Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.discount_outlined,
                          color: isDark
                              ? Colors.orangeAccent
                              : Colors.deepOrange),
                      title: const Text('মোট ডিসকাউন্ট দেওয়া হয়েছে'),
                      trailing: Text(
                        '৳${_currencyFormat.format(discount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.orangeAccent
                              : Colors.deepOrange,
                        ),
                      ),
                    ),
                  );
                }),
              ],

              if (byCategory.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'খাত অনুযায়ী কালেকশন (ভিজিট vs ট্রিটমেন্ট)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: byCategory.entries
                        .map(
                          (e) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.category_outlined,
                                color: Colors.teal),
                            title: Text(e.key),
                            trailing: Text(
                              '৳${_currencyFormat.format(e.value)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],

              if (byMethod.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'পেমেন্ট মাধ্যম অনুযায়ী আয়',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: byMethod.entries
                        .map(
                          (e) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.payment, color: Colors.teal),
                            title: Text(e.key),
                            trailing: Text(
                              '৳${_currencyFormat.format(e.value)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                'সাম্প্রতিক পেমেন্ট গ্রহণ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (payments.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('এই সময়ে কোনো পেমেন্ট নেই')),
                  ),
                )
              else
                ...payments.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () => context.push('/patients/${item.patient.id}'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade50,
                        child: Icon(Icons.check, color: Colors.green.shade700),
                      ),
                      title: Text(
                        item.patient.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${item.payment.method} • ${_dateFormat.format(item.payment.date)}',
                      ),
                      trailing: Text(
                        '+৳${_currencyFormat.format(item.payment.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 70),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDuePatientsTab() {
    final duesAsync = ref.watch(patientsWithDueProvider);

    return duesAsync.when(
      data: (dues) {
        if (dues.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.teal),
                SizedBox(height: 12),
                Text(
                  'কোনো রোগীর কাছে টাকা বকেয়া নেই!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: dues.length,
          itemBuilder: (ctx, i) {
            final d = dues[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade100),
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
                            onTap: () =>
                                context.push('/patients/${d.patient.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.patient.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  d.patient.phone,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'বাকি: ৳${_currencyFormat.format(d.due)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'মোট বিল: ৳${_currencyFormat.format(d.totalCost)}  •  জমা: ৳${_currencyFormat.format(d.totalPaid)}'
                      '${d.totalDiscount > 0 ? '  •  ছাড়: ৳${_currencyFormat.format(d.totalDiscount)}' : ''}'
                      '${d.lastVisitDate != null ? '  •  শেষ ভিজিট: ${_dateFormat.format(d.lastVisitDate!)}' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push(
                              '/patients/${d.patient.id}/payments/add',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            icon: const Icon(Icons.payments_outlined, size: 18),
                            label: const Text('পেমেন্ট নিন',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'কল করুন',
                          onPressed: () =>
                              WhatsAppHelper.callPhone(d.patient.phone),
                          icon: const Icon(Icons.call, size: 18),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'WhatsApp রিমাইন্ডার',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade800,
                          ),
                          onPressed: () {
                            final doctor = ref
                                    .read(authRepositoryProvider)
                                    .currentName ??
                                'My Dental Clinic';
                            final msg =
                                'আসসালামু আলাইকুম ${d.patient.name},\nআপনার ডেন্টাল চিকিৎসার ৳${_currencyFormat.format(d.due)} বকেয়া রয়েছে। পরবর্তী সুবিধাজনক সময়ে ক্লিনিকে যোগাযোগ করার জন্য অনুরোধ করা হলো।\n— $doctor';
                            WhatsAppHelper.openWhatsAppChat(
                              phone: d.patient.phone,
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

  Widget _buildExpensesTab() {
    final expensesAsync = ref.watch(allExpensesProvider);

    return expensesAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('এখনো কোনো ক্লিনিক খরচ যোগ করা হয়নি'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final exp = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade50,
                  child: Icon(Icons.receipt_long, color: Colors.orange.shade800),
                ),
                title: Text(
                  exp.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${exp.category} • ${_dateFormat.format(exp.date)}'
                  '${exp.notes != null && exp.notes!.isNotEmpty ? '\n${exp.notes}' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '-৳${_currencyFormat.format(exp.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.redAccent),
                      onPressed: () async {
                        await ref.read(databaseProvider).deleteExpense(exp.id);
                        if (mounted) setState(() {});
                      },
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

class _SummaryBox extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryBox({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final effectiveColor = isDark
        ? Color.lerp(color, Colors.white, 0.35)!
        : color;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: effectiveColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedText(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
