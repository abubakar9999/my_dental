import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_dental/core/constants.dart';
import 'package:my_dental/core/providers.dart';
import 'package:my_dental/core/utils/whatsapp_helper.dart';
import 'package:my_dental/data/auth/auth_repository.dart';
import 'package:my_dental/features/auth/login_screen.dart';
import 'package:my_dental/features/dental_chart/models/dental_data.dart';
import 'package:my_dental/features/prescriptions/prescription_pdf.dart';

void main() {
  test('Dental procedures list is loaded with valid prices', () {
    expect(AppConstants.defaultProcedures.isNotEmpty, true);
    for (final proc in AppConstants.defaultProcedures) {
      expect(proc['name'], isNotNull);
      expect((proc['price'] as num) > 0, true);
    }
  });

  test('Payment methods include cash and mobile banking', () {
    expect(AppConstants.paymentMethods.contains('নগদ (Cash)'), true);
    expect(AppConstants.paymentMethods.contains('বিকাশ (bKash)'), true);
  });

  test('Dental chart data correctly defines 32 adult teeth and 20 deciduous teeth', () {
    final adultTotal = DentalData.upperRightAdult.length +
        DentalData.upperLeftAdult.length +
        DentalData.lowerLeftAdult.length +
        DentalData.lowerRightAdult.length;
    expect(adultTotal, 32);

    final childTotal = DentalData.upperRightChild.length +
        DentalData.upperLeftChild.length +
        DentalData.lowerLeftChild.length +
        DentalData.lowerRightChild.length;
    expect(childTotal, 20);

    // FDI to Universal mapping verification
    expect(DentalData.fdiToUniversal['11'], '8'); // Upper Right Central Incisor
    expect(DentalData.fdiToUniversal['21'], '9'); // Upper Left Central Incisor
    expect(DentalData.fdiToUniversal['36'], '19'); // Lower Left 1st Molar
    expect(DentalData.fdiToUniversal['46'], '30'); // Lower Right 1st Molar
  });

  test('ClinicProfile restores saved session from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({
      'clinic_logged_in_profile':
          '{"id":1,"full_name":"ডা. ডেন্টিস্ট","role":"dentist","email":"doctor@dental.com","phone":"01700000000"}',
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = AuthRepository(prefs: prefs);

    expect(repo.isLoggedIn, true);
    expect(repo.currentName, 'ডা. ডেন্টিস্ট');
    expect(repo.currentPhone, '01700000000');
    expect(repo.currentEmail, 'doctor@dental.com');

    await repo.signOut();
    expect(repo.isLoggedIn, false);
  });

  testWidgets('LoginScreen renders phone/email and password fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('ফোন নম্বর বা ইমেইল *'), findsOneWidget);
    expect(find.text('পাসওয়ার্ড *'), findsOneWidget);
    expect(find.text('লগইন করুন'), findsOneWidget);
  });

  test('WhatsAppHelper normalizes BD phone numbers and summary builds Rx + investigations', () {
    expect(WhatsAppHelper.normalizePhone('01712-345678'), '8801712345678');
    expect(WhatsAppHelper.normalizePhone('+880 1811 223344'), '8801811223344');

    expect(AppConstants.defaultInvestigations.isNotEmpty, true);
    expect(AppConstants.expenseCategories.isNotEmpty, true);

    final summary = PrescriptionPdfGenerator.buildWhatsAppSummaryText(
      patientName: 'রহিম উদ্দিন',
      medicines: [
        {
          'name': 'Tab. Napa 500mg',
          'dose': '1+0+1',
          'duration': '5 দিন',
          'timing': 'খাওয়ার পর',
        },
      ],
      investigations: [
        {'name': 'OPG (Orthopantomogram)', 'toothNumber': '36'},
      ],
      nextVisitDate: DateTime(2026, 12, 1),
      doctorName: 'ডা. ডেন্টিস্ট',
    );

    expect(summary.contains('OPG (Orthopantomogram)'), true);
    expect(summary.contains('Tab. Napa 500mg'), true);
    expect(summary.contains('01 Dec 2026'), true);
  });

  test('ClinicSettingsNotifier defaults visit fee to 1000 and persists updates', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = ClinicSettingsNotifier(prefs);

    expect(settings.firstVisitFee, 1000.0);
    expect(settings.followUpFee, 0.0);
    expect(AppConstants.paymentCategories.contains('ভিজিট ফি (Visit Fee)'), true);

    await settings.update(
      newFirstVisitFee: 1200.0,
      newFollowUpFee: 500.0,
      newClinicName: 'Smile Care Dental',
      newClinicPhone: '01711111111',
    );

    final reloaded = ClinicSettingsNotifier(prefs);
    expect(reloaded.firstVisitFee, 1200.0);
    expect(reloaded.followUpFee, 500.0);
    expect(reloaded.clinicName, 'Smile Care Dental');
  });
}
