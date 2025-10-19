// // lib/presentation/screens/scanner_screen.dart
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../data/services/api_service.dart';
// import '../../data/services/storage_service.dart';
// import '../../data/models/product_model.dart';
// import 'product_detail_screen.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen>
//     with WidgetsBindingObserver {
//   final MobileScannerController _controller = MobileScannerController(
//     detectionSpeed: DetectionSpeed.normal,
//     facing: CameraFacing.back,
//   );

//   final ApiService _apiService = ApiService();
//   bool _isProcessing = false;
//   bool _hasPermission = false;
//   bool _isCheckingPermission = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _checkCameraPermission();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Recheck permission when app comes to foreground
//     if (state == AppLifecycleState.resumed) {
//       _checkCameraPermission();
//     }
//   }

//   Future<void> _checkCameraPermission() async {
//     setState(() => _isCheckingPermission = true);

//     final status = await Permission.camera.status;

//     if (mounted) {
//       setState(() {
//         _hasPermission = status.isGranted;
//         _isCheckingPermission = false;
//       });
//     }
//   }

//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();

//     if (mounted) {
//       setState(() {
//         _hasPermission = status.isGranted;
//       });

//       // If still denied, show dialog to open settings
//       if (status.isDenied || status.isPermanentlyDenied) {
//         _showPermissionDialog();
//       }
//     }
//   }

//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Camera Permission Required'),
//         content: const Text(
//           'This app needs camera access to scan barcodes. Please grant camera permission in Settings.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await openAppSettings();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
//     if (_isProcessing) return;

//     final List<Barcode> barcodes = capture.barcodes;
//     if (barcodes.isEmpty) return;

//     final String? barcode = barcodes.first.rawValue;
//     if (barcode == null || barcode.isEmpty) return;

//     setState(() => _isProcessing = true);

//     try {
//       // Check cache first
//       Product? product = StorageService.getCachedProduct(barcode);

//       // If not in cache, fetch from API
//       if (product == null) {
//         product = await _apiService.getProductByBarcode(barcode);
//       }

//       if (!mounted) return;

//       if (product != null) {
//         // Save to history
//         await StorageService.saveToHistory(product);

//         // Navigate to product detail
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductDetailScreen(product: product!),
//           ),
//         );
//       } else {
//         _showErrorSnackBar('Product not found. Try another barcode.');
//       }
//     } catch (e) {
//       if (mounted) {
//         _showErrorSnackBar('Error scanning barcode: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Product'),
//         actions: _hasPermission
//             ? [
//                 IconButton(
//                   icon: Icon(_controller.torchEnabled
//                       ? Icons.flash_on
//                       : Icons.flash_off),
//                   onPressed: () => _controller.toggleTorch(),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.flip_camera_ios),
//                   onPressed: () => _controller.switchCamera(),
//                 ),
//               ]
//             : null,
//       ),
//       body: _isCheckingPermission
//           ? _buildLoadingState()
//           : !_hasPermission
//               ? _buildPermissionDenied()
//               : Stack(
//                   children: [
//                     MobileScanner(
//                       controller: _controller,
//                       onDetect: _onBarcodeDetected,
//                     ),
//                     _buildOverlay(),
//                     if (_isProcessing) _buildLoadingOverlay(),
//                   ],
//                 ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }

//   Widget _buildPermissionDenied() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.camera_alt_outlined,
//               size: 80,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Camera Permission Required',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'Please grant camera permission to scan barcodes',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _requestCameraPermission,
//               child: const Text('Grant Permission'),
//             ),
//             const SizedBox(height: 12),
//             TextButton(
//               onPressed: () async {
//                 await openAppSettings();
//               },
//               child: const Text('Open Settings'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         // Semi-transparent black overlay covering entire screen
//         Container(
//           color: Colors.black.withOpacity(0.5),
//         ),
//         // Transparent center square (cut-out effect)
//         Center(
//           child: Container(
//             width: 250,
//             height: 250,
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: Colors.white,
//                 width: 3,
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(17),
//               child: Container(
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//         ),
//         // Corner decorations
//         Center(
//           child: SizedBox(
//             width: 250,
//             height: 250,
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   child: Container(
//                     width: 30,
//                     height: 30,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         top: BorderSide(color: Colors.green, width: 5),
//                         left: BorderSide(color: Colors.green, width: 5),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: Container(
//                     width: 30,
//                     height: 30,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         top: BorderSide(color: Colors.green, width: 5),
//                         right: BorderSide(color: Colors.green, width: 5),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   child: Container(
//                     width: 30,
//                     height: 30,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(color: Colors.green, width: 5),
//                         left: BorderSide(color: Colors.green, width: 5),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     width: 30,
//                     height: 30,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(color: Colors.green, width: 5),
//                         right: BorderSide(color: Colors.green, width: 5),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 100,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: const Text(
//               'Align barcode within the frame',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 shadows: [
//                   Shadow(
//                     blurRadius: 10,
//                     color: Colors.black,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingOverlay() {
//     return Container(
//       color: Colors.black54,
//       child: const Center(
//         child: Card(
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text(
//                   'Fetching product info...',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/product_model.dart';
import 'product_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  bool _permissionGranted = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Reinitialize when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _initializeScanner();
    }
  }

  Future<void> _initializeScanner() async {
    setState(() => _isInitializing = true);

    try {
      // Dispose existing controller if any (no await needed)
      _controller?.dispose();

      // Create new controller - mobile_scanner handles permissions internally
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );

      // Start the scanner
      await _controller!.start();

      if (mounted) {
        setState(() {
          _permissionGranted = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Scanner initialization error: $e');
      if (mounted) {
        setState(() {
          _permissionGranted = false;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose(); // No await here
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? barcode = barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      Product? product = StorageService.getCachedProduct(barcode);

      if (product == null) {
        product = await _apiService.getProductByBarcode(barcode);
      }

      if (!mounted) return;

      if (product != null) {
        await StorageService.saveToHistory(product);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product!),
          ),
        );
      } else {
        _showErrorSnackBar('Product not found. Try another barcode.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error scanning barcode: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: _permissionGranted && _controller != null
            ? [
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: _controller!.torchState,
                    builder: (context, state, child) {
                      return Icon(
                        state == TorchState.off
                            ? Icons.flash_off
                            : Icons.flash_on,
                      );
                    },
                  ),
                  onPressed: () => _controller!.toggleTorch(),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios),
                  onPressed: () => _controller!.switchCamera(),
                ),
              ]
            : null,
      ),
      body: _isInitializing
          ? _buildLoadingState()
          : !_permissionGranted
              ? _buildPermissionDenied()
              : Stack(
                  children: [
                    MobileScanner(
                      controller: _controller!,
                      onDetect: _onBarcodeDetected,
                    ),
                    _buildOverlay(),
                    if (_isProcessing) _buildLoadingOverlay(),
                  ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing camera...'),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please grant camera permission to scan barcodes',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeScanner,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.green, width: 5),
                        left: BorderSide(color: Colors.green, width: 5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.green, width: 5),
                        right: BorderSide(color: Colors.green, width: 5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.green, width: 5),
                        left: BorderSide(color: Colors.green, width: 5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.green, width: 5),
                        right: BorderSide(color: Colors.green, width: 5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Align barcode within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Fetching product info...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
