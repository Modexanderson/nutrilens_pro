// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Initialize Hive
    await Hive.initFlutter();
    await StorageService.init();

    // Initialize Mobile Ads
    await MobileAds.instance.initialize();

    // Initialize notifications
    await NotificationService.instance.init();

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
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class NutriLensProApp extends ConsumerStatefulWidget {
  const NutriLensProApp({super.key});

  @override
  ConsumerState<NutriLensProApp> createState() => _NutriLensProAppState();
}

class _NutriLensProAppState extends ConsumerState<NutriLensProApp> {
  bool _showOnboarding = false;
  bool _initialized = false;

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

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

    Widget homeWidget;
    if (_showOnboarding) {
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
      navigatorObservers: [observer],
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
