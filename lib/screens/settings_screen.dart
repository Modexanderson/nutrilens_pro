// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
import '../main.dart';
// import '../services/iap_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // final IAPService _iapService = IAPService.instance;
  // bool _isIAPInitialized = false;
  // bool _isLoadingIAP = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeIAP();
  // }

  // Future<void> _initializeIAP() async {
  //   setState(() {
  //     _isLoadingIAP = true;
  //   });

  //   try {
  //     await _iapService.initialize();

  //     // Wait a bit for products to load
  //     await Future.delayed(const Duration(milliseconds: 500));

  //     if (mounted) {
  //       setState(() {
  //         _isIAPInitialized = _iapService.isInitialized;
  //         _isLoadingIAP = false;
  //       });

  //       // Debug output
  //       print('IAP Initialized: $_isIAPInitialized');
  //       print('IAP Available: ${_iapService.isAvailable}');
  //       print('Products loaded: ${_iapService.products.length}');
  //     }
  //   } catch (e) {
  //     print('IAP initialization failed: $e');
  //     if (mounted) {
  //       setState(() {
  //         _isIAPInitialized = false;
  //         _isLoadingIAP = false;
  //       });
  //     }
  //   }
  // }

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
          // _buildSection(
          //   'Support Development',
          //   [
          //     ListTile(
          //       leading: const Icon(Icons.favorite, color: Colors.red),
          //       title: const Text('Support with a Donation'),
          //       subtitle: _isLoadingIAP
          //           ? const Text('Loading donation options...')
          //           : !_isIAPInitialized || !_iapService.isAvailable
          //               ? const Text('In-app purchases not available')
          //               : _iapService.products.isEmpty
          //                   ? const Text('No donation options available')
          //                   : const Text('Help us keep this app free'),
          //       trailing: _isLoadingIAP
          //           ? const SizedBox(
          //               width: 16,
          //               height: 16,
          //               child: CircularProgressIndicator(strokeWidth: 2),
          //             )
          //           : const Icon(Icons.arrow_forward_ios, size: 16),
          //       onTap: _isLoadingIAP ? null : _showDonationDialog,
          //     ),
          //   ],
          // ),
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
                onTap: () => _launchURL('https://nutrilenspro.web.app/privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchURL('https://nutrilenspro.web.app/terms'),
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

  // void _showDonationDialog() {
  //   // Check if still loading
  //   if (_isLoadingIAP) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please wait, loading donation options...'),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //     return;
  //   }

  //   // Check availability
  //   if (!_isIAPInitialized || !_iapService.isAvailable) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Row(
  //           children: [
  //             Icon(Icons.info_outline,
  //                 color: Theme.of(context).brightness == Brightness.dark
  //                     ? Colors.orange.shade300
  //                     : Colors.orange),
  //             const SizedBox(width: 8),
  //             Text('Not Available',
  //                 style: Theme.of(context).textTheme.titleLarge),
  //           ],
  //         ),
  //         content: Text(
  //           'In-app purchases are not available at the moment.\n\n'
  //           'This could be because:\n'
  //           '• Your device doesn\'t support in-app purchases\n'
  //           '• You\'re using a simulator/emulator\n'
  //           '• The products haven\'t been approved yet\n'
  //           '• Network connectivity issues',
  //           style: Theme.of(context).textTheme.bodyMedium,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _initializeIAP(); // Retry
  //             },
  //             child: const Text('Retry'),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //     return;
  //   }

  //   // Check products
  //   final products = _iapService.products;
  //   if (products.isEmpty) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Row(
  //           children: [
  //             Icon(Icons.warning_amber,
  //                 color: Theme.of(context).brightness == Brightness.dark
  //                     ? Colors.orange.shade300
  //                     : Colors.orange),
  //             const SizedBox(width: 8),
  //             Text('No Products Available',
  //                 style: Theme.of(context).textTheme.titleLarge),
  //           ],
  //         ),
  //         content: Text(
  //           'No donation options are currently available.\n\n'
  //           'Please make sure the in-app purchases are:\n'
  //           '• Approved in App Store Connect (not in Draft status)\n'
  //           '• Available in your region\n'
  //           '• Configured with correct Product IDs',
  //           style: Theme.of(context).textTheme.bodyMedium,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _initializeIAP(); // Retry
  //             },
  //             child: const Text('Retry'),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //     return;
  //   }

  //   // Show donation dialog
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Icon(Icons.favorite,
  //               color: Theme.of(context).brightness == Brightness.dark
  //                   ? Colors.red.shade300
  //                   : Colors.red),
  //           const SizedBox(width: 8),
  //           Text('Support Us', style: Theme.of(context).textTheme.titleLarge),
  //         ],
  //       ),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Thank you for considering a donation! Your support helps us keep this app free and ad-supported.',
  //               style: Theme.of(context).textTheme.bodyMedium,
  //             ),
  //             const SizedBox(height: 16),
  //             ...products.map((product) {
  //               return Card(
  //                 margin: const EdgeInsets.only(bottom: 8),
  //                 child: ListTile(
  //                   contentPadding: const EdgeInsets.symmetric(
  //                     horizontal: 12,
  //                     vertical: 4,
  //                   ),
  //                   title: Text(
  //                     product.title.split('(').first.trim(),
  //                     style: Theme.of(context).textTheme.titleMedium,
  //                   ),
  //                   subtitle: Text(
  //                     product.description,
  //                     style: Theme.of(context).textTheme.bodySmall,
  //                   ),
  //                   trailing: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       Text(
  //                         product.price,
  //                         style: Theme.of(context)
  //                             .textTheme
  //                             .titleLarge
  //                             ?.copyWith(
  //                               fontWeight: FontWeight.bold,
  //                               color: Theme.of(context).colorScheme.primary,
  //                             ),
  //                       ),
  //                     ],
  //                   ),
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     _processDonation(product);
  //                   },
  //                 ),
  //               );
  //             }),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Maybe Later'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _processDonation(ProductDetails product) async {
  //   if (_iapService.isPurchasePending) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('A purchase is already in progress'),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //     return;
  //   }

  //   // Show loading indicator
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Center(
  //       child: Card(
  //         child: Padding(
  //           padding: const EdgeInsets.all(24.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               CircularProgressIndicator(
  //                 color: Theme.of(context).colorScheme.primary,
  //               ),
  //               const SizedBox(height: 16),
  //               Text(
  //                 'Processing donation...',
  //                 style: Theme.of(context).textTheme.bodyLarge,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   try {
  //     await _iapService.buyProduct(product);

  //     if (mounted) {
  //       Navigator.pop(context); // Close loading dialog

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               SizedBox(width: 12),
  //               Expanded(
  //                 child: Text('Thank you for your support! ❤️'),
  //               ),
  //             ],
  //           ),
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: Colors.green,
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       Navigator.pop(context); // Close loading dialog

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               const Icon(Icons.error_outline, color: Colors.white),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text('Donation failed: ${e.toString()}'),
  //               ),
  //             ],
  //           ),
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 4),
  //         ),
  //       );
  //     }
  //   }
  // }

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

// USING REVENUECAT
// // lib/presentation/screens/settings_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import '../main.dart';
// import '../services/iap_service.dart';

// class SettingsScreen extends ConsumerStatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends ConsumerState<SettingsScreen> {
//   final IAPService _iapService = IAPService.instance;
//   bool _isIAPInitialized = false;
//   bool _isLoadingIAP = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeIAP();
//   }

//   Future<void> _initializeIAP() async {
//     setState(() {
//       _isLoadingIAP = true;
//     });

//     try {
//       await _iapService.initialize();

//       // Wait a bit for products to load
//       await Future.delayed(const Duration(milliseconds: 500));

//       if (mounted) {
//         setState(() {
//           _isIAPInitialized = _iapService.isInitialized;
//           _isLoadingIAP = false;
//         });

//         // Debug output
//         print('IAP Initialized: $_isIAPInitialized');
//         print('IAP Available: ${_iapService.isAvailable}');
//         print('Products loaded: ${_iapService.products.length}');
//       }
//     } catch (e) {
//       print('IAP initialization failed: $e');
//       if (mounted) {
//         setState(() {
//           _isIAPInitialized = false;
//           _isLoadingIAP = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeMode = ref.watch(themeModeProvider);
//     final isDark = themeMode == ThemeMode.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: ListView(
//         children: [
//           _buildSection(
//             'Appearance',
//             [
//               SwitchListTile(
//                 title: const Text('Dark Mode'),
//                 subtitle: const Text('Switch between light and dark theme'),
//                 value: isDark,
//                 onChanged: (_) {
//                   ref.read(themeModeProvider.notifier).toggleTheme();
//                 },
//                 secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
//               ),
//             ],
//           ),
//           _buildSection(
//             'Support Development',
//             [
//               ListTile(
//                 leading: const Icon(Icons.favorite, color: Colors.red),
//                 title: const Text('Support with a Donation'),
//                 subtitle: _isLoadingIAP
//                     ? const Text('Loading donation options...')
//                     : !_isIAPInitialized || !_iapService.isAvailable
//                         ? const Text('In-app purchases not available')
//                         : _iapService.products.isEmpty
//                             ? const Text('No donation options available')
//                             : const Text('Help us keep this app free'),
//                 trailing: _isLoadingIAP
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: _isLoadingIAP ? null : _showDonationDialog,
//               ),
//             ],
//           ),
//           _buildSection(
//             'About',
//             [
//               ListTile(
//                 leading: const Icon(Icons.info_outline),
//                 title: const Text('About NutriLens Pro'),
//                 subtitle: const Text('Version 1.0.0'),
//                 onTap: _showAboutDialog,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.privacy_tip_outlined),
//                 title: const Text('Privacy Policy'),
//                 trailing: const Icon(Icons.open_in_new, size: 16),
//                 onTap: () => _launchURL('https://nutrilenspro.web.app/privacy'),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.description_outlined),
//                 title: const Text('Terms of Service'),
//                 trailing: const Icon(Icons.open_in_new, size: 16),
//                 onTap: () => _launchURL('https://nutrilenspro.web.app/terms'),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.code),
//                 title: const Text('Open Source Licenses'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   showLicensePage(
//                     context: context,
//                     applicationName: 'NutriLens Pro',
//                     applicationVersion: '1.0.0',
//                     applicationIcon: const FlutterLogo(size: 48),
//                   );
//                 },
//               ),
//             ],
//           ),
//           _buildSection(
//             'Data',
//             [
//               ListTile(
//                 leading: const Icon(Icons.storage),
//                 title: const Text('Data Source'),
//                 subtitle: const Text('Powered by Open Food Facts'),
//                 trailing: const Icon(Icons.open_in_new, size: 16),
//                 onTap: () => _launchURL('https://world.openfoodfacts.org'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           Center(
//             child: Text(
//               'Made with ❤️ for healthier choices',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.grey,
//                   ),
//             ),
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Text(
//             title,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   color: Theme.of(context).colorScheme.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//         ),
//         Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(children: children),
//         ),
//       ],
//     );
//   }

//   void _showDonationDialog() {
//     // Check if still loading
//     if (_isLoadingIAP) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please wait, loading donation options...'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     // Check availability
//     if (!_isIAPInitialized || !_iapService.isAvailable) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.info_outline,
//                   color: Theme.of(context).brightness == Brightness.dark
//                       ? Colors.orange.shade300
//                       : Colors.orange),
//               const SizedBox(width: 8),
//               Text('Not Available',
//                   style: Theme.of(context).textTheme.titleLarge),
//             ],
//           ),
//           content: Text(
//             'In-app purchases are not available at the moment.\n\n'
//             'This could be because:\n'
//             '• Your device doesn\'t support in-app purchases\n'
//             '• You\'re using a simulator/emulator\n'
//             '• The products haven\'t been configured in RevenueCat\n'
//             '• Network connectivity issues',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _initializeIAP(); // Retry
//               },
//               child: const Text('Retry'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     // Check products
//     final products = _iapService.products;
//     if (products.isEmpty) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.warning_amber,
//                   color: Theme.of(context).brightness == Brightness.dark
//                       ? Colors.orange.shade300
//                       : Colors.orange),
//               const SizedBox(width: 8),
//               Text('No Products Available',
//                   style: Theme.of(context).textTheme.titleLarge),
//             ],
//           ),
//           content: Text(
//             'No donation options are currently available.\n\n'
//             'Please make sure:\n'
//             '• Products are configured in RevenueCat Dashboard\n'
//             '• Products are added to an Offering\n'
//             '• Products are approved in App Store Connect\n'
//             '• Products are available in your region',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _initializeIAP(); // Retry
//               },
//               child: const Text('Retry'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     // Show donation dialog
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.favorite,
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.red.shade300
//                     : Colors.red),
//             const SizedBox(width: 8),
//             Text('Support Us', style: Theme.of(context).textTheme.titleLarge),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Thank you for considering a donation! Your support helps us keep this app free and ad-supported.',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 16),
//               ...products.map((product) {
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     title: Text(
//                       product.title.split('(').first.trim(),
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     subtitle: Text(
//                       product.description,
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                     trailing: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           product.priceString,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleLarge
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       _processDonation(product);
//                     },
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Maybe Later'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _processDonation(StoreProduct product) async {
//     if (_iapService.isPurchasePending) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('A purchase is already in progress'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Center(
//         child: Card(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Processing donation...',
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     try {
//       final success = await _iapService.buyProduct(product);

//       if (mounted) {
//         Navigator.pop(context); // Close loading dialog

//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Row(
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.white),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text('Thank you for your support! ❤️'),
//                   ),
//                 ],
//               ),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Purchase completed but could not be verified'),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       }
//     } on PlatformException catch (e) {
//       if (mounted) {
//         Navigator.pop(context); // Close loading dialog

//         final errorCode = PurchasesErrorHelper.getErrorCode(e);
//         String message = 'Donation failed';

//         if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
//           message = 'Purchase cancelled';
//         } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
//           message = 'Purchase not allowed on this device';
//         } else {
//           message = 'Donation failed: ${e.message ?? 'Unknown error'}';
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 12),
//                 Expanded(child: Text(message)),
//               ],
//             ),
//             behavior: SnackBarBehavior.floating,
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.pop(context); // Close loading dialog

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text('Donation failed: ${e.toString()}'),
//                 ),
//               ],
//             ),
//             behavior: SnackBarBehavior.floating,
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     }
//   }

//   void _showAboutDialog() {
//     showAboutDialog(
//       context: context,
//       applicationName: 'NutriLens Pro',
//       applicationVersion: '1.0.0',
//       applicationIcon: const FlutterLogo(size: 48),
//       children: [
//         const Text(
//           'NutriLens Pro helps you make informed food choices by providing detailed nutrition information through barcode scanning.',
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Scan. Know. Choose Better.',
//           style: TextStyle(fontStyle: FontStyle.italic),
//         ),
//       ],
//     );
//   }

//   Future<void> _launchURL(String url) async {
//     final uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not open link'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
// }
