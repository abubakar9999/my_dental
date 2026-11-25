import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'core/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    try {
      await dotenv.load(fileName: "assets/.env");
    } catch (_) {
      debugPrint("Notice: .env file not found or failed to load: $e");
    }
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint("Notice: Supabase initialization error: $e");
  }

  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint("Notice: SharedPreferences error: $e");
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyDentalApp(),
    ),
  );
}

class MyDentalApp extends ConsumerStatefulWidget {
  const MyDentalApp({super.key});

  @override
  ConsumerState<MyDentalApp> createState() => _MyDentalAppState();
}

class _MyDentalAppState extends ConsumerState<MyDentalApp> {
  @override
  void initState() {
    super.initState();
    // Seed default procedure prices and default user on first run
    ref.read(databaseProvider).seedProcedurePrices();
    ref.read(databaseProvider).seedDefaultUser();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
