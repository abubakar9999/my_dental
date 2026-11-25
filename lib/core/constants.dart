import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // App Info
  static const String appName = 'My Dental';
  static const String appNameBn = 'ডেন্টাল ক্লিনিক';

  // Supabase Configuration (Dynamically loaded from .env with safe fallbacks)
  static String get supabaseUrl {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.env['SUPABASE_URL'];
        if (val != null && val.isNotEmpty) return val;
      }
    } catch (_) {}
    return 'https://awhfilekoturpdzjvucl.supabase.co';
  }

  static String get supabaseAnonKey {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.env['SUPABASE_ANON_KEY'];
        if (val != null && val.isNotEmpty) return val;
      }
    } catch (_) {}
    return 'sb_publishable_emu-TMz2xkbs08C6sXT2Ug_xqtdrCUx';
  }

  // Appointment Statuses
  static const String statusWaiting = 'waiting';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Payment Methods
  static const List<String> paymentMethods = [
    'নগদ (Cash)',
    'বিকাশ (bKash)',
    'নগদ মোবাইল (Nagad)',
    'কার্ড (Card)',
    'অন্যান্য (Other)',
  ];

  // Gender Options
  static const List<String> genderOptions = [
    'পুরুষ (Male)',
    'মহিলা (Female)',
    'অন্যান্য (Other)',
  ];

  // Default Dental Procedures
  static const List<Map<String, dynamic>> defaultProcedures = [
    {'name': 'স্কেলিং (Scaling)', 'price': 2000.0},
    {'name': 'ফিলিং (Filling)', 'price': 1500.0},
    {'name': 'RCT (Root Canal)', 'price': 8000.0},
    {'name': 'এক্সট্র্যাকশন (Extraction)', 'price': 1000.0},
    {'name': 'ক্রাউন (Crown)', 'price': 5000.0},
    {'name': 'ব্রিজ (Bridge)', 'price': 15000.0},
    {'name': 'ডেনচার (Denture)', 'price': 12000.0},
    {'name': 'ইমপ্লান্ট (Implant)', 'price': 35000.0},
    {'name': 'অর্থোডন্টিক্স (Orthodontics)', 'price': 50000.0},
    {'name': 'হোয়াইটেনিং (Whitening)', 'price': 5000.0},
    {'name': 'ভেনিয়ার (Veneer)', 'price': 8000.0},
    {'name': 'এক্স-রে (X-Ray)', 'price': 500.0},
    {'name': 'পরামর্শ (Consultation)', 'price': 500.0},
  ];
}
