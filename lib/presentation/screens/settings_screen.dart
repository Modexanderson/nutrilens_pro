// lib/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../main.dart';
import '../../data/services/iap_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final IAPService _iapService = IAPService.instance;
  bool _isIAPInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    await _iapService.initialize();
    if (mounted) {
      setState(() {
        _isIAPInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Appearance',
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: isDark,
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              ),
            ],
          ),
          _buildSection(
            'Support Development',
            [
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Support with a Donation'),
                subtitle: const Text('Help us keep this app free'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showDonationDialog,
              ),
            ],
          ),
          _buildSection(
            'About',
            [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About NutriLens Pro'),
                subtitle: const Text('Version 1.0.0'),
                onTap: _showAboutDialog,
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchURL('https://yourwebsite.com/privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchURL('https://yourwebsite.com/terms'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Open Source Licenses'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'NutriLens Pro',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(size: 48),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'Data',
            [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Data Source'),
                subtitle: const Text('Powered by Open Food Facts'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchURL('https://world.openfoodfacts.org'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Made with ❤️ for healthier choices',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showDonationDialog() {
    if (!_isIAPInitialized || !_iapService.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('In-app purchases are not available at the moment'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final products = _iapService.products;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading donation options...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text('Support Us'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you for considering a donation! Your support helps us keep this app free and ad-supported.',
            ),
            const SizedBox(height: 16),
            ...products.map((product) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Text(
                  product.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _processDonation(product);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
        ],
      ),
    );
  }

  Future<void> _processDonation(ProductDetails product) async {
    if (_iapService.isPurchasePending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A purchase is already in progress'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await _iapService.buyProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your support! ❤️'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Donation failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'NutriLens Pro',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const Text(
          'NutriLens Pro helps you make informed food choices by providing detailed nutrition information through barcode scanning.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Scan. Know. Choose Better.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
