import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/whatsapp_helper.dart';

class PrescriptionPdfGenerator {
  static pw.Font? _cachedRegular;
  static pw.Font? _cachedBold;

  static Future<pw.ThemeData?> _loadThemeSafely() async {
    try {
      _cachedRegular ??= await PdfGoogleFonts.notoSansBengaliRegular()
          .timeout(const Duration(seconds: 2));
      _cachedBold ??= await PdfGoogleFonts.notoSansBengaliBold()
          .timeout(const Duration(seconds: 2));
      return pw.ThemeData.withFont(
        base: _cachedRegular!,
        bold: _cachedBold!,
      );
    } catch (_) {
      // Offline fallback to built-in PDF Helvetica
      return null;
    }
  }

  static Future<Uint8List> buildPdfBytes({
    required String patientName,
    required String patientPhone,
    required int patientAge,
    required List<Map<String, dynamic>> medicines,
    List<Map<String, dynamic>> investigations = const [],
    String? advice,
    DateTime? nextVisitDate,
    String? doctorName,
    String? doctorQualification,
    String? doctorPhone,
    double? currentDue,
    DateTime? prescriptionDate,
  }) async {
    final theme = await _loadThemeSafely();
    final pdf = pw.Document(theme: theme);
    final dateFormat = DateFormat('dd MMM yyyy');
    final displayDate = dateFormat.format(prescriptionDate ?? DateTime.now());
    final resolvedDoctor =
        (doctorName != null && doctorName.trim().isNotEmpty)
            ? doctorName.trim()
            : 'My Dental Clinic';
    final resolvedQual =
        (doctorQualification != null && doctorQualification.trim().isNotEmpty)
            ? doctorQualification.trim()
            : 'BDS, Dental & Oral Care Center';
    final resolvedPhone =
        (doctorPhone != null && doctorPhone.trim().isNotEmpty)
            ? doctorPhone.trim()
            : '+880 1700-000000';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 14),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.teal, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          resolvedDoctor,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          resolvedQual,
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'My Dental Clinic • Specialized Dental Care',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Date: $displayDate',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Phone: $resolvedPhone',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // ─── Patient Info Bar ────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Patient: $patientName',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    pw.Text(
                      'Age: ${patientAge > 0 ? '$patientAge yrs' : 'N/A'}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Phone: $patientPhone',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // ─── Investigations Section (If Assigned) ────────────
              if (investigations.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey50,
                    border: pw.Border.all(color: PdfColors.blueGrey200),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Investigations / Diagnostic Tests Advised:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: PdfColors.teal900,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      ...List<pw.Widget>.generate(investigations.length, (i) {
                        final inv = investigations[i];
                        final name = inv['name']?.toString() ??
                            inv['testName']?.toString() ??
                            '';
                        final tooth = inv['toothNumber']?.toString() ?? '';
                        final notes = inv['notes']?.toString() ?? '';
                        final details = [
                          if (tooth.isNotEmpty) 'Tooth #$tooth',
                          if (notes.isNotEmpty) notes,
                        ].join(' • ');
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 3),
                          child: pw.Text(
                            '${i + 1}. $name${details.isNotEmpty ? ' ($details)' : ''}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              // ─── Rx Symbol ───────────────────────────────────────
              pw.Text(
                'Rx',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.teal700,
                ),
              ),
              pw.SizedBox(height: 8),

              // ─── Medicines Table ─────────────────────────────────
              if (medicines.isNotEmpty)
                pw.TableHelper.fromTextArray(
                  headers: ['#', 'Medicine Name', 'Dose', 'Duration', 'Timing'],
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.teal,
                  ),
                  cellHeight: 26,
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  data: List<List<String>>.generate(
                    medicines.length,
                    (index) {
                      final med = medicines[index];
                      return [
                        '${index + 1}',
                        med['name']?.toString() ?? '',
                        med['dose']?.toString() ?? '',
                        med['duration']?.toString() ?? '',
                        med['timing']?.toString() ?? '',
                      ];
                    },
                  ),
                )
              else
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 14),
                  child: pw.Text(
                    'No medications prescribed on this visit.',
                    style: const pw.TextStyle(
                      color: PdfColors.grey600,
                      fontSize: 10,
                    ),
                  ),
                ),

              pw.SizedBox(height: 18),

              // ─── Advice Section ──────────────────────────────────
              if (advice != null && advice.trim().isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Advice / Instructions:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: PdfColors.teal800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        advice,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
              ],

              // ─── Next Visit & Billing Info ───────────────────────
              if (nextVisitDate != null ||
                  (currentDue != null && currentDue > 0)) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (nextVisitDate != null)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.orange50,
                          border: pw.Border.all(color: PdfColors.orange300),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'Next Follow-up Visit: ${dateFormat.format(nextVisitDate)}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange900,
                          ),
                        ),
                      ),
                    if (currentDue != null && currentDue > 0)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red50,
                          border: pw.Border.all(color: PdfColors.red200),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'Due Balance: BDT ${currentDue.toStringAsFixed(0)}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red800,
                          ),
                        ),
                      ),
                  ],
                ),
              ],

              pw.Spacer(),

              // ─── Footer & Signature ──────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Generated via My Dental Clinic App',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey500,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 140,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.grey600,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        resolvedDoctor,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Opens print preview dialog (with share/save/print options).
  static Future<void> generate({
    required String patientName,
    required String patientPhone,
    required int patientAge,
    required List<Map<String, dynamic>> medicines,
    List<Map<String, dynamic>> investigations = const [],
    String? advice,
    DateTime? nextVisitDate,
    String? doctorName,
    String? doctorQualification,
    String? doctorPhone,
    double? currentDue,
    DateTime? prescriptionDate,
  }) async {
    final bytes = await buildPdfBytes(
      patientName: patientName,
      patientPhone: patientPhone,
      patientAge: patientAge,
      medicines: medicines,
      investigations: investigations,
      advice: advice,
      nextVisitDate: nextVisitDate,
      doctorName: doctorName,
      doctorQualification: doctorQualification,
      doctorPhone: doctorPhone,
      currentDue: currentDue,
      prescriptionDate: prescriptionDate,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Prescription_${patientName.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Generates the PDF file and opens Share Sheet (WhatsApp / Messenger / etc.) with patient caption.
  static Future<void> sharePdf({
    required String patientName,
    required String patientPhone,
    required int patientAge,
    required List<Map<String, dynamic>> medicines,
    List<Map<String, dynamic>> investigations = const [],
    String? advice,
    DateTime? nextVisitDate,
    String? doctorName,
    String? doctorQualification,
    String? doctorPhone,
    double? currentDue,
    DateTime? prescriptionDate,
  }) async {
    final bytes = await buildPdfBytes(
      patientName: patientName,
      patientPhone: patientPhone,
      patientAge: patientAge,
      medicines: medicines,
      investigations: investigations,
      advice: advice,
      nextVisitDate: nextVisitDate,
      doctorName: doctorName,
      doctorQualification: doctorQualification,
      doctorPhone: doctorPhone,
      currentDue: currentDue,
      prescriptionDate: prescriptionDate,
    );

    final nextStr = nextVisitDate != null
        ? '\nপরবর্তী ভিজিট: ${DateFormat('dd MMM yyyy').format(nextVisitDate)}'
        : '';

    await WhatsAppHelper.sharePdfFile(
      pdfBytes: bytes,
      fileName: 'Rx_${patientName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      subject: 'Dental Prescription - $patientName',
      text: 'আসসালামু আলাইকুম $patientName ($patientPhone),\nআপনার ডেন্টাল প্রেসক্রিপশন ও পরামর্শ সংযুক্ত করা হলো।$nextStr\n— ${doctorName ?? 'My Dental Clinic'}',
    );
  }

  /// Builds a clean WhatsApp text summary for direct `wa.me` chat launch.
  static String buildWhatsAppSummaryText({
    required String patientName,
    required List<Map<String, dynamic>> medicines,
    List<Map<String, dynamic>> investigations = const [],
    String? advice,
    DateTime? nextVisitDate,
    String? doctorName,
  }) {
    final buf = StringBuffer();
    buf.writeln('আসসালামু আলাইকুম *$patientName*,');
    buf.writeln('আপনার ডেন্টাল প্রেসক্রিপশন বিবরণ:');
    if (investigations.isNotEmpty) {
      buf.writeln('\n*পরীক্ষা (Investigations):*');
      for (var i = 0; i < investigations.length; i++) {
        final inv = investigations[i];
        final name = inv['name']?.toString() ?? '';
        final tooth = inv['toothNumber']?.toString() ?? '';
        buf.writeln('${i + 1}. $name${tooth.isNotEmpty ? ' (দাঁত #$tooth)' : ''}');
      }
    }
    if (medicines.isNotEmpty) {
      buf.writeln('\n*ওষুধ (Rx):*');
      for (var i = 0; i < medicines.length; i++) {
        final m = medicines[i];
        buf.writeln(
          '${i + 1}. ${m['name'] ?? ''} - ${m['dose'] ?? ''} (${m['duration'] ?? ''}) [${m['timing'] ?? ''}]',
        );
      }
    }
    if (advice != null && advice.trim().isNotEmpty) {
      buf.writeln('\n*পরামর্শ:* ${advice.trim()}');
    }
    if (nextVisitDate != null) {
      buf.writeln(
        '\n*পরবর্তী ভিজিট:* ${DateFormat('dd MMM yyyy').format(nextVisitDate)}',
      );
    }
    buf.writeln('\n— ${doctorName ?? 'My Dental Clinic'}');
    return buf.toString();
  }
}
