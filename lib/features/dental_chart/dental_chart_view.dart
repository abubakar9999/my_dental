import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/database.dart';
import 'models/dental_data.dart';
import 'widgets/tooth_widget.dart';
import 'widgets/tooth_detail_sheet.dart';

class DentalChartView extends ConsumerStatefulWidget {
  final int patientId;

  const DentalChartView({super.key, required this.patientId});

  @override
  ConsumerState<DentalChartView> createState() => _DentalChartViewState();
}

class _DentalChartViewState extends ConsumerState<DentalChartView> {
  bool _isPediatric = false; // Adult vs Child
  bool _useUniversal = false; // FDI vs Universal
  String _archFilter = 'all'; // 'all', 'upper', 'lower'

  void _showToothDetail({
    required String toothNumber,
    required String currentCondition,
    required List<String> currentSurfaces,
    String? notes,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ToothDetailSheet(
        patientId: widget.patientId,
        toothNumber: toothNumber,
        currentCondition: currentCondition,
        currentSurfaces: currentSurfaces,
        currentNotes: notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conditionsStream =
        ref.watch(toothConditionsForPatientProvider(widget.patientId));

    return conditionsStream.when(
      data: (conditions) {
        // Map toothNumber -> ToothCondition
        final conditionMap = <String, ToothCondition>{};
        for (final c in conditions) {
          conditionMap[c.toothNumber] = c;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Controls Header ─────────────────────────────────
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dentition Type Toggle
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('স্থায়ী দাঁত (৩২)',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('দুধের দাঁত (২০)',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                            selected: {_isPediatric},
                            onSelectionChanged: (set) {
                              setState(() => _isPediatric = set.first);
                            },
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),

                          // Numbering Toggle
                          Row(
                            children: [
                              Text(
                                _useUniversal ? 'Universal' : 'FDI',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.teal,
                                ),
                              ),
                              Switch(
                                value: _useUniversal,
                                activeColor: Colors.teal,
                                onChanged: (val) {
                                  setState(() => _useUniversal = val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Arch Filter Buttons
                      Row(
                        children: [
                          const Text(
                            'চোয়াল:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('সম্পূর্ণ মুখ',
                                style: TextStyle(fontSize: 11)),
                            selected: _archFilter == 'all',
                            onSelected: (_) =>
                                setState(() => _archFilter = 'all'),
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('উপরের চোয়াল',
                                style: TextStyle(fontSize: 11)),
                            selected: _archFilter == 'upper',
                            onSelected: (_) =>
                                setState(() => _archFilter = 'upper'),
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('নিচের চোয়াল',
                                style: TextStyle(fontSize: 11)),
                            selected: _archFilter == 'lower',
                            onSelected: (_) =>
                                setState(() => _archFilter = 'lower'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── Color Legend Banner ─────────────────────────────
              _buildColorLegend(),
              const SizedBox(height: 16),

              // ─── Upper Arch (Maxilla) ────────────────────────────
              if (_archFilter == 'all' || _archFilter == 'upper') ...[
                _buildArchCard(
                  title: 'উপরের চোয়াল (Maxilla / Upper Arch)',
                  isUpper: true,
                  conditionMap: conditionMap,
                ),
                const SizedBox(height: 16),
              ],

              // ─── Lower Arch (Mandible) ────────────────────────────
              if (_archFilter == 'all' || _archFilter == 'lower') ...[
                _buildArchCard(
                  title: 'নিচের চোয়াল (Mandible / Lower Arch)',
                  isUpper: false,
                  conditionMap: conditionMap,
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('চার্ট লোড করতে সমস্যা হয়েছে: $e')),
    );
  }

  Widget _buildColorLegend() {
    final legends = [
      {'label': 'সুস্থ', 'color': const Color(0xFF43A047)},
      {'label': 'ক্যারিজ', 'color': const Color(0xFFE53935)},
      {'label': 'ফিলিং', 'color': const Color(0xFF1E88E5)},
      {'label': 'ক্রাউন', 'color': const Color(0xFFFBC02D)},
      {'label': 'RCT', 'color': const Color(0xFF8E24AA)},
      {'label': 'তোলা', 'color': const Color(0xFF616161)},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: legends.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArchCard({
    required String title,
    required bool isUpper,
    required Map<String, ToothCondition> conditionMap,
  }) {
    List<String> rightTeeth;
    List<String> leftTeeth;

    if (_isPediatric) {
      rightTeeth = isUpper
          ? DentalData.upperRightChild
          : DentalData.lowerRightChild;
      leftTeeth = isUpper
          ? DentalData.upperLeftChild
          : DentalData.lowerLeftChild;
    } else {
      rightTeeth = isUpper
          ? DentalData.upperRightAdult
          : DentalData.lowerRightAdult;
      leftTeeth = isUpper
          ? DentalData.upperLeftAdult
          : DentalData.lowerLeftAdult;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Arch Title & Orientation label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ডান (Right)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const Text(
                  'বাম (Left)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Horizontally Scrollable Teeth Grid
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Right Quadrant
                  ...rightTeeth.map((tNum) => _buildSingleTooth(tNum, conditionMap)),

                  // Midline Divider
                  Container(
                    width: 2,
                    height: 58,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: Colors.red.shade300,
                  ),

                  // Left Quadrant
                  ...leftTeeth.map((tNum) => _buildSingleTooth(tNum, conditionMap)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTooth(
    String toothNumber,
    Map<String, ToothCondition> conditionMap,
  ) {
    final conditionRecord = conditionMap[toothNumber];
    final condition = conditionRecord?.condition ?? 'healthy';
    final notes = conditionRecord?.notes;

    List<String> surfaces = [];
    if (conditionRecord?.surfaces != null) {
      try {
        surfaces = List<String>.from(jsonDecode(conditionRecord!.surfaces!));
      } catch (_) {}
    }

    final displayName = _useUniversal
        ? (DentalData.fdiToUniversal[toothNumber] ?? toothNumber)
        : toothNumber;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ToothWidget(
        toothNumber: toothNumber,
        displayName: displayName,
        condition: condition,
        affectedSurfaces: surfaces,
        onTap: () => _showToothDetail(
          toothNumber: toothNumber,
          currentCondition: condition,
          currentSurfaces: surfaces,
          notes: notes,
        ),
      ),
    );
  }
}
