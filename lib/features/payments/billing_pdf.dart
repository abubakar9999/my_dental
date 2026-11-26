import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/whatsapp_helper.dart';
import '../../data/local/database.dart';

class BillingPdfGenerator {
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
      return null;
    }
  }

  static Future<Uint8List> buildInvoiceBytes({
    required Patient patient,
    required List<Treatment> treatments,
    required List<Investigation> investigations,
    required List<Payment> payments,
    required String clinicName,
    required String clinicPhone,
    String? doctorName,
    double? latestPaid,
    double? latestDiscount,
    String? latestMethod,
  }) async {
    final theme = await _loadThemeSafely();
    final pdf = pw.Document(theme: theme);
    final dateFmt = DateFormat('dd MMM yyyy');
    final numFmt = NumberFormat('#,##0', 'en_US');

    double totalCost = 0;
    final chargeRows = <List<String>>[];
    int idx = 1;
    for (final t in treatments) {
      totalCost += t.cost;
      final tooth = (t.toothNumber != null && t.toothNumber!.isNotEmpty)
          ? ' (Tooth #${t.toothNumber})'
          : '';
      chargeRows.add([
        '${idx++}',
        dateFmt.format(t.date),
        '${t.procedure}$tooth',
        'BDT ${numFmt.format(t.cost)}',
      ]);
    }
    for (final inv in investigations) {
      if (inv.cost > 0) {
        totalCost += inv.cost;
        chargeRows.add([
          '${idx++}',
          dateFmt.format(inv.date),
          'Investigation: ${inv.testName}',
          'BDT ${numFmt.format(inv.cost)}',
        ]);
      }
    }

    double totalPaid = 0;
    double totalDiscount = 0;
    final paymentRows = <List<String>>[];
    for (final p in payments) {
      totalPaid += p.amount;
      totalDiscount += p.discount;
      paymentRows.add([
        dateFmt.format(p.date),
        p.category,
        p.method,
        'BDT ${numFmt.format(p.discount)}',
        'BDT ${numFmt.format(p.amount)}',
      ]);
    }

    final due = totalCost - (totalPaid + totalDiscount);
    final netDue = due > 0 ? due : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
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
                      clinicName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                    if (doctorName != null && doctorName.isNotEmpty)
                      pw.Text(
                        doctorName,
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey800,
                        ),
                      ),
                    pw.Text(
                      'Phone: $clinicPhone',
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
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.teal,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'INVOICE / RECEIPT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Date: ${dateFmt.format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Patient Info
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Patient: ${patient.name}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.Text(
                  'Phone: ${patient.phone}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (patient.age != null)
                  pw.Text(
                    'Age: ${patient.age} yrs',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Highlight box if called right after a payment
          if (latestPaid != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                border: pw.Border.all(color: PdfColors.green300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Received Now (${latestMethod ?? "Cash"}): BDT ${numFmt.format(latestPaid)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                      fontSize: 11,
                    ),
                  ),
                  if ((latestDiscount ?? 0) > 0)
                    pw.Text(
                      'Discount Allowed: BDT ${numFmt.format(latestDiscount)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange900,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
          ],

          // Charges Table
          pw.Text(
            'Services & Visit Fees',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              color: PdfColors.teal800,
            ),
          ),
          pw.SizedBox(height: 6),
          if (chargeRows.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: ['#', 'Date', 'Description', 'Fee'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              cellStyle: const pw.TextStyle(fontSize: 9.5),
              data: chargeRows,
            )
          else
            pw.Text('No billed items recorded.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 14),

          // Payments & Discounts History
          if (paymentRows.isNotEmpty) ...[
            pw.Text(
              'Payment & Discount History',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: PdfColors.teal800,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Category', 'Method', 'Discount', 'Paid'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 9.5),
              data: paymentRows,
            ),
            pw.SizedBox(height: 14),
          ],

          // Totals Box
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 240,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.teal300),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColors.grey50,
              ),
              child: pw.Column(
                children: [
                  _summaryLine('Total Bill:', 'BDT ${numFmt.format(totalCost)}'),
                  if (totalDiscount > 0)
                    _summaryLine(
                      'Total Discount:',
                      '- BDT ${numFmt.format(totalDiscount)}',
                      color: PdfColors.orange800,
                    ),
                  _summaryLine(
                    'Total Paid:',
                    'BDT ${numFmt.format(totalPaid)}',
                    color: PdfColors.green800,
                  ),
                  pw.Divider(color: PdfColors.grey400),
                  _summaryLine(
                    'Remaining Due:',
                    'BDT ${numFmt.format(netDue)}',
                    bold: true,
                    color: netDue > 0 ? PdfColors.red700 : PdfColors.teal800,
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Thank you for visiting $clinicName.',
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _summaryLine(
    String label,
    String value, {
    bool bold = false,
    PdfColor? color,
  }) {
    final style = pw.TextStyle(
      fontSize: bold ? 11.5 : 10,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color ?? PdfColors.black,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  static Future<void> printInvoice({
    required Patient patient,
    required List<Treatment> treatments,
    required List<Investigation> investigations,
    required List<Payment> payments,
    required String clinicName,
    required String clinicPhone,
    String? doctorName,
    double? latestPaid,
    double? latestDiscount,
    String? latestMethod,
  }) async {
    final bytes = await buildInvoiceBytes(
      patient: patient,
      treatments: treatments,
      investigations: investigations,
      payments: payments,
      clinicName: clinicName,
      clinicPhone: clinicPhone,
      doctorName: doctorName,
      latestPaid: latestPaid,
      latestDiscount: latestDiscount,
      latestMethod: latestMethod,
    );

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'Invoice_${patient.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> shareInvoiceToWhatsApp({
    required Patient patient,
    required List<Treatment> treatments,
    required List<Investigation> investigations,
    required List<Payment> payments,
    required String clinicName,
    required String clinicPhone,
    String? doctorName,
    double? latestPaid,
    double? latestDiscount,
    String? latestMethod,
  }) async {
    final bytes = await buildInvoiceBytes(
      patient: patient,
      treatments: treatments,
      investigations: investigations,
      payments: payments,
      clinicName: clinicName,
      clinicPhone: clinicPhone,
      doctorName: doctorName,
      latestPaid: latestPaid,
      latestDiscount: latestDiscount,
      latestMethod: latestMethod,
    );

    final numFmt = NumberFormat('#,##0', 'en_US');
    final totalCost = treatments.fold<double>(0, (s, t) => s + t.cost) +
        investigations.fold<double>(0, (s, i) => s + i.cost);
    final totalPaid = payments.fold<double>(0, (s, p) => s + p.amount);
    final totalDisc = payments.fold<double>(0, (s, p) => s + p.discount);
    final netDue = (totalCost - (totalPaid + totalDisc)).clamp(0, double.infinity);

    await WhatsAppHelper.sharePdfFile(
      pdfBytes: bytes,
      fileName: 'Receipt_${patient.name}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      subject: 'Dental Invoice - ${patient.name}',
      text: 'আসসালামু আলাইকুম ${patient.name} (${patient.phone}),\n'
          'আপনার বিল ও পেমেন্ট রিসিপ্ট সংযুক্ত করা হলো।\n'
          'মোট বিল: ৳${numFmt.format(totalCost)} | জমা: ৳${numFmt.format(totalPaid)}'
          '${totalDisc > 0 ? ' | ছাড়: ৳${numFmt.format(totalDisc)}' : ''}'
          ' | বকেয়া: ৳${numFmt.format(netDue)}\n— $clinicName',
    );
  }
}
