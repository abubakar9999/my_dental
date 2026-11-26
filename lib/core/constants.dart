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

  // Payment Collection Categories
  static const List<String> paymentCategories = [
    'ভিজিট ফি (Visit Fee)',
    'ট্রিটমেন্ট / বকেয়া',
    'পরীক্ষা (Investigation)',
    'অগ্রিম (Advance)',
  ];

  // Default Visit Fees (৳)
  static const double defaultFirstVisitFee = 1000.0;
  static const double defaultFollowUpFee = 0.0;

  // Gender Options
  static const List<String> genderOptions = [
    'পুরুষ (Male)',
    'মহিলা (Female)',
    'অন্যান্য (Other)',
  ];

  // Default Dental Procedures
  static const List<Map<String, dynamic>> defaultProcedures = [
    {'name': 'ভিজিট / পরামর্শ (Visit Fee)', 'price': 1000.0},
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
  ];

  // Default Dental Investigations / Diagnostic Tests
  static const List<Map<String, dynamic>> defaultInvestigations = [
    {'name': 'IOPA X-Ray', 'price': 300.0},
    {'name': 'OPG (Orthopantomogram)', 'price': 1000.0},
    {'name': 'RVG (Digital X-Ray)', 'price': 400.0},
    {'name': 'CBCT Scan', 'price': 3500.0},
    {'name': 'RBS (Random Blood Sugar)', 'price': 150.0},
    {'name': 'CBC (Complete Blood Count)', 'price': 400.0},
    {'name': 'BT / CT', 'price': 200.0},
    {'name': 'HBsAg / Anti-HCV', 'price': 600.0},
  ];

  // Common Dental Medicine Presets for quick selection
  static const List<Map<String, String>> defaultMedicines = [
    {
      'name': 'Tab. Napa 500mg',
      'dose': '1+0+1',
      'duration': '5 দিন',
      'timing': 'খাওয়ার পর',
    },
    {
      'name': 'Cap. Moxacil 500mg',
      'dose': '1+1+1',
      'duration': '7 দিন',
      'timing': 'খাওয়ার পর',
    },
    {
      'name': 'Tab. Filmet 400mg',
      'dose': '1+1+1',
      'duration': '7 দিন',
      'timing': 'খাওয়ার পর',
    },
    {
      'name': 'Tab. Ketorol 10mg',
      'dose': '1+0+1',
      'duration': '3 দিন',
      'timing': 'ভরা পেটে',
    },
    {
      'name': 'Cap. Sergel 20mg',
      'dose': '1+0+1',
      'duration': '7 দিন',
      'timing': 'খাওয়ার আগে',
    },
    {
      'name': 'Chlorhexidine Mouthwash 0.2%',
      'dose': '10ml কুলকুচি',
      'duration': '14 দিন',
      'timing': 'দিনে ২ বার',
    },
  ];

  // Clinic Expense Categories
  static const List<String> expenseCategories = [
    'ল্যাব চার্জ (Lab Charge)',
    'ডেন্টাল ম্যাটেরিয়াল (Materials)',
    'স্টাফ বেতন (Salary)',
    'ভাড়া ও বিল (Rent & Utilities)',
    'যন্ত্রপাতি (Equipment)',
    'অন্যান্য (Other)',
  ];
}
