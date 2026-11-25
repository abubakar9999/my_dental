import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrescriptionPdfGenerator {
  static Future<void> generate({
    required String patientName,
    required String patientPhone,
    required int patientAge,
    required List<Map<String, dynamic>> medicines,
    String? advice,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final currentDate = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
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
                          'MY DENTAL CLINIC',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Oral & Dental Care Center',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Specialized in Scaling, RCT, Crown, Implant & Orthodontics',
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
                          'Date: $currentDate',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Phone: +880 1XXX-XXXXXX',
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
              pw.SizedBox(height: 16),

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
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      'Age: ${patientAge > 0 ? '$patientAge yrs' : 'N/A'}',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.Text(
                      'Contact: $patientPhone',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // ─── Rx Symbol ───────────────────────────────────────
              pw.Text(
                'Rx',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.teal700,
                ),
              ),
              pw.SizedBox(height: 12),

              // ─── Medicines Table ─────────────────────────────────
              if (medicines.isNotEmpty)
                pw.TableHelper.fromTextArray(
                  headers: ['#', 'Medicine Name', 'Dose', 'Duration', 'Timing'],
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.teal,
                  ),
                  cellHeight: 28,
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
                  padding: const pw.EdgeInsets.symmetric(vertical: 20),
                  child: pw.Text(
                    'No specific medications prescribed.',
                    style: const pw.TextStyle(
                      color: PdfColors.grey600,
                      fontSize: 11,
                    ),
                  ),
                ),

              pw.SizedBox(height: 24),

              // ─── Advice Section ──────────────────────────────────
              if (advice != null && advice.trim().isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
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
                          fontSize: 12,
                          color: PdfColors.teal800,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        advice,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // ─── Footer & Signature ──────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Generated via My Dental App',
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
                        'Doctor\'s Signature',
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Prescription_${patientName.replaceAll(' ', '_')}.pdf',
    );
  }
}
