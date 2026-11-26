import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Normalizes Bangladeshi phone numbers into international format without '+'
  /// e.g., `01712-345678` -> `8801712345678`.
  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) {
      return digits.substring(1);
    }
    if (digits.startsWith('01') && digits.length == 11) {
      return '88$digits';
    }
    return digits;
  }

  /// Opens a direct WhatsApp chat (`wa.me`) with pre-filled text message.
  static Future<bool> openWhatsAppChat({
    required String phone,
    required String message,
  }) async {
    final normalized = normalizePhone(phone);
    if (normalized.isEmpty) return false;

    final uri = Uri.parse(
      'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Opens device phone dialer for the given number.
  static Future<bool> callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return false;
    final uri = Uri.parse('tel:$clean');
    return launchUrl(uri);
  }

  /// Saves PDF bytes to a temporary file and opens the share sheet (for WhatsApp, etc.).
  static Future<void> sharePdfFile({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
    String? text,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');
    final finalName = safeName.endsWith('.pdf') ? safeName : '$safeName.pdf';
    final filePath = p.join(tempDir.path, finalName);
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);

    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/pdf')],
      subject: subject,
      text: text,
    );
  }
}
