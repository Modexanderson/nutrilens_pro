// lib/screens/demo_home_screen.dart
// Demo home screen for App Store screenshots
// DELETE THIS FILE AFTER TAKING SCREENSHOTS

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_scanner_screen.dart';
import 'search_screen.dart';
import 'tracker_screen.dart';
import 'profile_screen.dart';

class DemoHomeScreen extends ConsumerStatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  ConsumerState<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends ConsumerState<DemoHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DemoScannerScreen(), // Use demo scanner instead of real scanner
    SearchScreen(),
    TrackerScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
