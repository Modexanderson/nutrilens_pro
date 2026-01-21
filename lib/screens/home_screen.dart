// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scanner_screen.dart';
import 'search_screen.dart';
import 'tracker_screen.dart';
import 'profile_screen.dart';
import '../services/ad_service.dart';
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
