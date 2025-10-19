// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scanner_screen.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import '../../data/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  int _scanCount = 0;

  final List<Widget> _screens = const [
    ScannerScreen(),
    HistoryScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    AdService.instance.loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.instance.createBannerAd();
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

    // Show interstitial ad every 5 scans from scanner
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
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner Ad
          if (_bannerAd != null)
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
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
