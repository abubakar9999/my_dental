import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';

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

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'my_dental.sqlite');
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await Share.shareXFiles(
          [XFile(dbPath)],
          text: 'My Dental App Backup (${DateFormat('yyyy-MM-dd').format(DateTime.now())})',
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ডেটাবেস ফাইল পাওয়া যায়নি')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ব্যাকআপ ত্রুটি: $e')),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        final dbFolder = await getApplicationDocumentsDirectory();
        final targetPath = p.join(dbFolder.path, 'my_dental.sqlite');

        // Copy over existing db
        await pickedFile.copy(targetPath);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ব্যাকআপ সফলভাবে রিস্টোর হয়েছে! অ্যাপটি পুনরায় চালু করুন।'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('রিস্টোর ত্রুটি: $e')),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proceduresAsync = ref.watch(procedurePricesProvider);
    final authRepo = ref.watch(authRepositoryProvider);
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
                    ],
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50.withAlpha(120),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cloud_done_outlined, size: 18, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Supabase টেবিল ভিত্তিক সিস্টেম (${AppConstants.supabaseUrl})।',
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

          // ─── Section 3: Backup & Restore ───────────────────────
          Text(
            'ব্যাকআপ ও রিস্টোর',
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
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.upload_file, color: Colors.white),
                  ),
                  title: const Text('ডেটাবেস এক্সপোর্ট (ব্যাকআপ)'),
                  subtitle: const Text('ফোনে ফাইল সেভ বা হোয়াটসঅ্যাপে শেয়ার করুন'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade600,
                    child: const Icon(Icons.download, color: Colors.white),
                  ),
                  title: const Text('ডেটাবেস ইমপোর্ট (রিস্টোর)'),
                  subtitle: const Text('আগের ব্যাকআপ ফাইল থেকে ডেটা ফিরিয়ে আনুন'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _importBackup(context, ref),
                ),
              ],
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
