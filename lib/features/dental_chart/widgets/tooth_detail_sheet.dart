import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../models/dental_data.dart';

class ToothDetailSheet extends ConsumerStatefulWidget {
  final int patientId;
  final String toothNumber;
  final String currentCondition;
  final List<String> currentSurfaces;
  final String? currentNotes;

  const ToothDetailSheet({
    super.key,
    required this.patientId,
    required this.toothNumber,
    required this.currentCondition,
    required this.currentSurfaces,
    this.currentNotes,
  });

  @override
  ConsumerState<ToothDetailSheet> createState() => _ToothDetailSheetState();
}

class _ToothDetailSheetState extends ConsumerState<ToothDetailSheet> {
  late String _selectedCondition;
  late Set<String> _selectedSurfaces;
  late TextEditingController _notesController;
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _conditions = {
    'healthy': {'label': 'সুস্থ (Healthy)', 'color': const Color(0xFF43A047)},
    'caries': {'label': 'ক্যারিজ / পচন (Caries)', 'color': const Color(0xFFE53935)},
    'filled': {'label': 'ফিলিং করা (Filled)', 'color': const Color(0xFF1E88E5)},
    'crown': {'label': 'ক্রাউন / ক্যাপ (Crown)', 'color': const Color(0xFFFBC02D)},
    'rct': {'label': 'RCT করা (Root Canal)', 'color': const Color(0xFF8E24AA)},
    'extracted': {'label': 'তোলা হয়েছে (Missing)', 'color': const Color(0xFF616161)},
  };

  final Map<String, String> _surfacesMap = {
    'mesial': 'মেসিয়াল (Mesial - M)',
    'occlusal': 'অক্লুজাল (Occlusal - O)',
    'distal': 'ডিস্টাল (Distal - D)',
    'buccal': 'বাকাল (Buccal - B)',
    'lingual': 'লিঙ্গুয়াল (Lingual - L)',
  };

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.currentCondition.isEmpty ? 'healthy' : widget.currentCondition;
    _selectedSurfaces = Set<String>.from(widget.currentSurfaces);
    _notesController = TextEditingController(text: widget.currentNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final surfacesJson = _selectedSurfaces.isNotEmpty
          ? jsonEncode(_selectedSurfaces.toList())
          : null;

      await db.setToothCondition(
        patientId: widget.patientId,
        toothNumber: widget.toothNumber,
        condition: _selectedCondition,
        surfaces: surfacesJson,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('দাঁত #${widget.toothNumber} এর অবস্থা আপডেট হয়েছে'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final universalNum = DentalData.fdiToUniversal[widget.toothNumber] ?? '';
    final toothTitle = DentalData.getToothName(widget.toothNumber);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Tooth Header Title
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.teal.shade50,
                  child: Text(
                    widget.toothNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'দাঁত নম্বর: FDI #${widget.toothNumber} ${universalNum.isNotEmpty ? '(Universal #$universalNum)' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        toothTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Condition Selection
            const Text(
              'দাঁতের বর্তমান অবস্থা (Condition)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _conditions.entries.map((entry) {
                final isSelected = _selectedCondition == entry.key;
                final color = entry.value['color'] as Color;
                final label = entry.value['label'] as String;

                return ChoiceChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: color,
                  backgroundColor: color.withAlpha(25),
                  side: BorderSide(
                    color: isSelected ? color : color.withAlpha(70),
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedCondition = entry.key);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 5 Surface Selection
            if (_selectedCondition != 'extracted') ...[
              const Text(
                'আক্রান্ত সারফেস বা পাশ (Surfaces)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _surfacesMap.entries.map((entry) {
                  final isChecked = _selectedSurfaces.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                    selected: isChecked,
                    selectedColor: Colors.teal.shade100,
                    checkmarkColor: Colors.teal.shade900,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSurfaces.add(entry.key);
                        } else {
                          _selectedSurfaces.remove(entry.key);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'বিশেষ নোট বা মন্তব্য (ঐচ্ছিক)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(
                        '/patients/${widget.patientId}/treatments/add?tooth=${widget.toothNumber}',
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                    label: const Text('চিকিৎসা যোগ', style: TextStyle(color: Colors.teal)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _save,
                    icon: const Icon(Icons.check),
                    label: const Text('সংরক্ষণ করুন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
