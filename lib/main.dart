import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'core/providers.dart';

Future<void> _loadEnvSafely() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    try {
      await dotenv.load(fileName: "assets/.env");
    } catch (_) {
      debugPrint("Notice: .env file not found or failed to load: $e");
    }
  }
}

Future<SharedPreferences?> _loadPrefsSafely() async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint("Notice: SharedPreferences error: $e");
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final results = await Future.wait<dynamic>([
    _loadEnvSafely(),
    _loadPrefsSafely(),
  ]);
  final prefs = results[1] as SharedPreferences?;

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
  static const _seedKey = 'procedures_seeded_v2';

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs?.getBool(_seedKey) != true) {
      ref.read(databaseProvider).seedProcedurePrices().then((_) {
        prefs?.setBool(_seedKey, true);
      });
    }
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
