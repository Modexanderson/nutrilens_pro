// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scanner_screen.dart';
import 'search_screen.dart';
import 'tracker_screen.dart';
import 'profile_screen.dart';
import '../services/ad_service.dart';
import '../services/connectivity_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  int _scanCount = 0;

  final List<Widget> _screens = const [
    ScannerScreen(),
    SearchScreen(),
    TrackerScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    AdService.instance.loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isBannerLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          FirebaseCrashlytics.instance.log('Banner failed: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() => _isBannerLoaded = false);
          }
          // Retry after 60 seconds
          Future.delayed(const Duration(seconds: 60), () {
            if (mounted) _loadBannerAd();
          });
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Show interstitial ad every 5 tab switches to scanner
    if (_selectedIndex == 0) {
      _scanCount++;
      if (_scanCount >= 5) {
        AdService.instance.showInterstitialAd();
        _scanCount = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show offline banner when disconnected
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      body: Column(
        children: [
          // Offline banner
          connectivityAsync.when(
            data: (isConnected) {
              if (!isConnected) {
                return MaterialBanner(
                  content: const Text(
                    'You\'re offline. Some features may be limited.',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange[800],
                  leading:
                      const Icon(Icons.wifi_off, color: Colors.white),
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('DISMISS',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Main content
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner Ad — only show when loaded
          if (_isBannerLoaded && _bannerAd != null)
            SizedBox(
              height: 50,
              child: AdWidget(ad: _bannerAd!),
            ),

          // Navigation Bar
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: Icon(Icons.qr_code_scanner),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.track_changes_outlined),
                selectedIcon: Icon(Icons.track_changes),
                label: 'Tracker',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
