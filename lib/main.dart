// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/demo_data_service.dart';
import 'screens/home_screen.dart';
import 'screens/demo_home_screen.dart';
import 'screens/onboarding_screen.dart';

// ============================================
// DEMO MODE FOR APP STORE SCREENSHOTS
// Set to true to enable demo mode with mock data
// Set to false for production release
// ============================================
const bool kDemoMode = false; // <-- CHANGE TO false BEFORE RELEASE!
// ============================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await StorageService.init();

  // Load demo data if in demo mode
  if (kDemoMode) {
    await DemoDataService.loadDemoData();
  }

  // Initialize Mobile Ads
  await MobileAds.instance.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: NutriLensProApp(),
    ),
  );
}

class NutriLensProApp extends ConsumerStatefulWidget {
  const NutriLensProApp({super.key});

  @override
  ConsumerState<NutriLensProApp> createState() => _NutriLensProAppState();
}

class _NutriLensProAppState extends ConsumerState<NutriLensProApp> {
  bool _showOnboarding = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() {
    final isCompleted = StorageService.isOnboardingCompleted();
    setState(() {
      _showOnboarding = !isCompleted;
      _initialized = true;
    });
  }

  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // In demo mode, skip onboarding and use demo home screen
    Widget homeWidget;
    if (kDemoMode) {
      homeWidget = const DemoHomeScreen();
    } else if (_showOnboarding) {
      homeWidget = OnboardingScreen(onComplete: _completeOnboarding);
    } else {
      homeWidget = const HomeScreen();
    }

    return MaterialApp(
      title: 'NutriLens Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: _initialized
          ? homeWidget
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final isDark = await StorageService.getThemeMode();
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await StorageService.setThemeMode(state == ThemeMode.dark);
  }
}
