import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../data/local/database.dart';
import '../../data/remote/online_data_exporter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static final _currencyFormat = NumberFormat('#,##0', 'en_US');

  void _editProcedurePriceDialog(
    BuildContext context,
    WidgetRef ref,
    ProcedurePrice item,
  ) {
    final controller = TextEditingController(
      text: item.defaultPrice.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${item.name} এর দাম পরিবর্তন'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ডিফল্ট দাম (৳)',
            prefixIcon: Icon(Icons.money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(controller.text.trim());
              if (newPrice != null) {
                final db = ref.read(databaseProvider);
                await db.updateProcedurePrice(
                  ProcedurePricesCompanion(
                    id: drift.Value(item.id),
                    name: drift.Value(item.name),
                    defaultPrice: drift.Value(newPrice),
                  ),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  void _addProcedureDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন প্রসিডিউর যোগ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'প্রসিডিউর এর নাম',
                hintText: 'উদাঃ পলিশিং',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ডিফল্ট ফি (৳)',
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
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              if (name.isNotEmpty) {
                await ref.read(databaseProvider).insertProcedurePrice(
                      ProcedurePricesCompanion.insert(
                        name: name,
                        defaultPrice: price,
                      ),
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
  }

  Future<void> _showExportDialog(BuildContext context, WidgetRef ref) async {
    final format = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'অনলাইন টেবিল ফরম্যাটে ডাটা এক্সপোর্ট',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'এক্সপোর্ট করা ফাইল পরবর্তীতে সরাসরি অনলাইন Supabase টেবিলে ইমপোর্ট করা যাবে।',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedText(ctx)),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.storage, color: Colors.white),
                ),
                title: const Text('SQL ফাইল (.sql) — রেকমেন্ডেড'),
                subtitle: const Text(
                  'Supabase SQL Editor-এ পেস্ট/রান করে সব টেবিলে সরাসরি ইমপোর্ট করুন',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, 'sql'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade600,
                  child: const Icon(Icons.data_object, color: Colors.white),
                ),
                title: const Text('JSON ফাইল (.json)'),
                subtitle: const Text(
                  'অনলাইন টেবিল ও কলামের নাম অনুযায়ী স্ট্রাকচার্ড JSON এক্সপোর্ট',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, 'json'),
              ),
            ],
          ),
        ),
      ),
    );

    if (format == null || !context.mounted) return;
    await _exportOnlineFormat(context, ref, format: format);
  }

  Future<void> _exportOnlineFormat(
    BuildContext context,
    WidgetRef ref, {
    required String format,
  }) async {
    try {
      final db = ref.read(databaseProvider);
      await db.checkpointWal();
      final exporter = OnlineDataExporter(db);

      final timestamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
      final ext = format == 'sql' ? 'sql' : 'json';
      final fileName = 'my_dental_online_export_$timestamp.$ext';

      final String content;
      final int totalRecords;
      if (format == 'sql') {
        final res = await exporter.generateSql();
        content = res.sql;
        totalRecords = res.totalRecords;
      } else {
        final res = await exporter.generateJson();
        content = res.json;
        totalRecords = res.totalRecords;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Dental Online-Format Export ($totalRecords টি রেকর্ড • .$ext)',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('এক্সপোর্ট ত্রুটি: $e')),
        );
      }
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('লগআউট নিশ্চিতকরণ'),
        content: const Text(
          'আপনি কি নিশ্চিত যে লগআউট করতে চান? পুনরায় প্রবেশের জন্য ফোন নম্বর/ইমেইল ও পাসওয়ার্ড প্রয়োজন হবে।',
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
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('লগআউট', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editClinicSettingsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(clinicSettingsProvider);
    final visitCtrl = TextEditingController(
      text: settings.firstVisitFee.toStringAsFixed(0),
    );
    final followUpCtrl = TextEditingController(
      text: settings.followUpFee.toStringAsFixed(0),
    );
    final nameCtrl = TextEditingController(text: settings.clinicName);
    final phoneCtrl = TextEditingController(text: settings.clinicPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ভিজিট ফি ও ক্লিনিক সেটিংস'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'ক্লিনিকের নাম',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'ক্লিনিকের ফোন নম্বর',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: visitCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'নতুন ভিজিট ফি (৳)',
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: followUpCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ফলো-আপ ভিজিট ফি (৳)',
                  prefixIcon: Icon(Icons.repeat),
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
              final firstFee = double.tryParse(visitCtrl.text.trim()) ?? 1000.0;
              final followFee =
                  double.tryParse(followUpCtrl.text.trim()) ?? 0.0;
              await ref.read(clinicSettingsProvider).update(
                    newFirstVisitFee: firstFee,
                    newFollowUpFee: followFee,
                    newClinicName: nameCtrl.text,
                    newClinicPhone: phoneCtrl.text,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proceduresAsync = ref.watch(procedurePricesProvider);
    final authRepo = ref.watch(authRepositoryProvider);
    final clinicSettings = ref.watch(clinicSettingsProvider);
    final pendingSyncAsync = clinicSettings.onlineSyncEnabled
        ? ref.watch(pendingSyncCountProvider)
        : const AsyncValue<int>.data(0);
    final profile = authRepo.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Section 1: Active Profile & Cloud Database ──────────
          Text(
            'ক্লাউড ডেটাবেস ও প্রোফাইল',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.teal, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? 'ডা. ডেন্টিস্ট',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              [
                                if (profile?.phone?.isNotEmpty == true) profile!.phone!,
                                if (profile?.email?.isNotEmpty == true) profile!.email!,
                              ].join(' • '),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          profile?.role ?? 'dentist',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 19),
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(left: 6),
                        tooltip: 'প্রোফাইল স্ট্যাটাস রিফ্রেশ',
                        onPressed: () async {
                          final ok = await ref
                              .read(authRepositoryProvider)
                              .syncProfileFromCloud();
                          final syncOn = ref
                              .read(clinicSettingsProvider)
                              .onlineSyncEnabled;
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? (syncOn
                                          ? 'প্রোফাইল আপডেট হয়েছে: অনলাইন সিঙ্ক চালু'
                                          : 'প্রোফাইল আপডেট হয়েছে: অ্যাপ সম্পূর্ণ অফলাইন মোডে চলবে')
                                      : 'প্রোফাইল রিফ্রেশ করা যায়নি (ইন্টারনেট নেই)',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  if (!clinicSettings.onlineSyncEnabled) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 18,
                          color: AppTheme.adaptiveColor(context,
                              Colors.orange.shade800, Colors.orangeAccent),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'অ্যাপ সম্পূর্ণ অফলাইন মোডে চলছে — সকল ডাটা শুধুমাত্র লোকাল স্টোরেজে সংরক্ষিত হচ্ছে।',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedText(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (clinicSettings.onlineSyncEnabled) ...[
                    const Divider(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.cloud_done_outlined,
                        color: AppTheme.adaptiveColor(
                            context, Colors.teal, Colors.tealAccent.shade200),
                      ),
                      title: const Text(
                        'অনলাইন সিঙ্ক চালু (প্রোফাইল থেকে নির্ধারিত)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'লোকাল স্টোরেজের পাশাপাশি অনলাইন Supabase টেবিলেও ডাটা সিঙ্ক হবে',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'সিঙ্ক সক্রিয়',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.adaptiveColor(context,
                                Colors.teal.shade800, Colors.tealAccent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        pendingSyncAsync.when(
                          data: (count) => Text(
                            'অপেক্ষমাণ সিঙ্ক: $count টি রেকর্ড',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedText(context),
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authRepositoryProvider)
                                .syncProfileFromCloud();
                            final stillEnabled = ref
                                .read(clinicSettingsProvider)
                                .onlineSyncEnabled;
                            final synced = stillEnabled
                                ? await ref
                                    .read(supabaseSyncProvider)
                                    .flushQueue()
                                : 0;
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    !stillEnabled
                                        ? 'প্রোফাইলে অনলাইন সিঙ্ক বন্ধ থাকায় ডাটা লোকালেই থাকবে'
                                        : (synced > 0
                                            ? '$synced টি রেকর্ড Supabase-এ সিঙ্ক হয়েছে'
                                            : 'সব ডাটা অনলাইনে সিঙ্ককৃত আছে'),
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync, size: 17),
                          label: const Text('এখনই অনলাইনে সিঙ্ক',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Section 1.5: Visit Fee & Clinic Settings ────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ভিজিট ফি ও ক্লিনিক তথ্য',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
              ),
              TextButton.icon(
                onPressed: () => _editClinicSettingsDialog(context, ref),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('পরিবর্তন'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.teal),
                  title: Text(clinicSettings.clinicName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ফোন: ${clinicSettings.clinicPhone}'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payments, color: Colors.teal),
                  title: const Text('ডিফল্ট ভিজিট ফি'),
                  subtitle: Text(
                    'নতুন ভিজিট: ৳${_currencyFormat.format(clinicSettings.firstVisitFee)}  •  ফলো-আপ: ৳${_currencyFormat.format(clinicSettings.followUpFee)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editClinicSettingsDialog(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Section 2: Procedure Prices ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'চিকিৎসা ও ডিফল্ট মূল্য তালিকা',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                tooltip: 'নতুন প্রসিডিউর যোগ',
                onPressed: () => _addProcedureDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 8),

          proceduresAsync.when(
            data: (procedures) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: procedures.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = procedures[i];
                    return ListTile(
                      title: Text(item.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '৳${_currencyFormat.format(item.defaultPrice)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                            onPressed: () => _editProcedurePriceDialog(
                              context,
                              ref,
                              item,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('ত্রুটি: $e'),
          ),

          const SizedBox(height: 24),

          // ─── Section 3: Online-Compatible Export ────────────────
          Text(
            'ডাটা এক্সপোর্ট',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.upload_file, color: Colors.white),
              ),
              title: const Text('অফলাইন ডাটা এক্সপোর্ট (অনলাইন ফরম্যাট)'),
              subtitle: const Text(
                'ভবিষ্যতে অনলাইন Supabase টেবিলে ইমপোর্ট করার জন্য .sql / .json ফাইল তৈরি ও শেয়ার করুন',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showExportDialog(context, ref),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Section 4: App Info & Logout ──────────────────────
          Text(
            'অ্যাকাউন্ট ও লগআউট',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.teal),
                  title: Text(AppConstants.appNameBn),
                  subtitle: Text('ভার্সন 1.0.0 • ডেন্টাল ক্লিনিক ম্যানেজমেন্ট'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'লগআউট',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('অ্যাকাউন্ট থেকে লগআউট করুন'),
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
