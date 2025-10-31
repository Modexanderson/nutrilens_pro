// // lib/presentation/screens/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
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

      product ??= await _apiService.getProductByBarcode(barcode);

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

// // lib/presentation/screens/scanner_screen.dart

// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../models/product_model.dart';
// import 'product_detail_screen.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen>
//     with WidgetsBindingObserver, SingleTickerProviderStateMixin {
//   MobileScannerController? _controller;
//   final ApiService _apiService = ApiService();
//   bool _isProcessing = false;
//   bool _permissionGranted = false;
//   bool _isInitializing = true;
//   bool _showMockBarcode = false; // Toggle to show barcode for screenshot

//   // Animation controller for scanning line
//   late AnimationController _animationController;
//   late Animation<double> _scanAnimation;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeScanner();

//     // Initialize scanning animation
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);

//     _scanAnimation = Tween<double>(begin: 0.0, end: 250.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.resumed) {
//       _initializeScanner();
//     }
//   }

//   Future<void> _initializeScanner() async {
//     setState(() => _isInitializing = true);

//     try {
//       _controller?.dispose();

//       _controller = MobileScannerController(
//         detectionSpeed: DetectionSpeed.normal,
//         facing: CameraFacing.back,
//       );

//       await _controller!.start();

//       if (mounted) {
//         setState(() {
//           _permissionGranted = true;
//           _isInitializing = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Scanner initialization error: $e');
//       if (mounted) {
//         setState(() {
//           _permissionGranted = false;
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _animationController.dispose();
//     _controller?.dispose();
//     super.dispose();
//   }

//   Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
//     if (_isProcessing) return;

//     final List<Barcode> barcodes = capture.barcodes;
//     if (barcodes.isEmpty) return;

//     final String? barcode = barcodes.first.rawValue;
//     if (barcode == null || barcode.isEmpty) return;

//     await _processBarcode(barcode);
//   }

//   Future<void> _processBarcode(String barcode) async {
//     if (_isProcessing) return;

//     setState(() => _isProcessing = true);

//     try {
//       Product? product = StorageService.getCachedProduct(barcode);

//       if (product == null) {
//         product = await _apiService.getProductByBarcode(barcode);
//       }

//       if (!mounted) return;

//       if (product != null) {
//         await StorageService.saveToHistory(product);

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
//         _showErrorSnackBar('Error processing barcode: $e');
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

//   void _showManualBarcodeEntry() {
//     final TextEditingController controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Enter Barcode'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 hintText: 'e.g., 3017620422003',
//                 labelText: 'Barcode',
//                 border: OutlineInputBorder(),
//               ),
//               autofocus: true,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Try these popular products:',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 4,
//               runSpacing: 4,
//               children: [
//                 _buildQuickBarcodeChip(context, '3017620422003', 'Nutella'),
//                 _buildQuickBarcodeChip(context, '5449000000996', 'Coca-Cola'),
//                 _buildQuickBarcodeChip(context, '8712100000000', 'Heineken'),
//                 _buildQuickBarcodeChip(context, '7622300441906', 'Milka'),
//                 _buildQuickBarcodeChip(context, '3168930010883', 'Kinder'),
//                 _buildQuickBarcodeChip(context, '8076809513128', 'Barilla'),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Divider(),
//             Row(
//               children: [
//                 Checkbox(
//                   value: _showMockBarcode,
//                   onChanged: (val) {
//                     setState(() {
//                       _showMockBarcode = val ?? false;
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//                 const Expanded(
//                   child: Text(
//                     'Show barcode in scanner for screenshot',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () {
//               Navigator.pop(context);
//               if (controller.text.isNotEmpty) {
//                 _processBarcode(controller.text);
//               }
//             },
//             child: const Text('Scan'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickBarcodeChip(
//       BuildContext context, String barcode, String name) {
//     return ActionChip(
//       label: Text(name, style: const TextStyle(fontSize: 11)),
//       avatar: const Icon(Icons.touch_app, size: 14),
//       onPressed: () {
//         Navigator.pop(context);
//         _processBarcode(barcode);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Product'),
//         actions: _permissionGranted && _controller != null
//             ? [
//                 IconButton(
//                   icon: ValueListenableBuilder(
//                     valueListenable: _controller!.torchState,
//                     builder: (context, state, child) {
//                       return Icon(
//                         state == TorchState.off
//                             ? Icons.flash_off
//                             : Icons.flash_on,
//                       );
//                     },
//                   ),
//                   onPressed: () => _controller!.toggleTorch(),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.flip_camera_ios),
//                   onPressed: () => _controller!.switchCamera(),
//                 ),
//               ]
//             : null,
//       ),
//       floatingActionButton: _permissionGranted
//           ? FloatingActionButton.extended(
//               onPressed: _showManualBarcodeEntry,
//               icon: const Icon(Icons.edit),
//               label: const Text('Manual Entry'),
//             )
//           : null,
//       body: _isInitializing
//           ? _buildLoadingState()
//           : !_permissionGranted
//               ? _buildPermissionDenied()
//               : Stack(
//                   children: [
//                     MobileScanner(
//                       controller: _controller!,
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
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Initializing camera...'),
//         ],
//       ),
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
//               onPressed: _initializeScanner,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         Container(
//           color: Colors.black.withOpacity(0.5),
//         ),
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
//               child: Stack(
//                 children: [
//                   // SHOW BARCODE IMAGE HERE FOR SCREENSHOT
//                   if (_showMockBarcode)
//                     Center(
//                       child: _buildBarcodeImage(),
//                     ),

//                   // Animated scanning line
//                   AnimatedBuilder(
//                     animation: _scanAnimation,
//                     builder: (context, child) {
//                       return Positioned(
//                         top: _scanAnimation.value,
//                         left: 0,
//                         right: 0,
//                         child: Container(
//                           height: 2,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.transparent,
//                                 Colors.green.withOpacity(0.8),
//                                 Colors.green,
//                                 Colors.green.withOpacity(0.8),
//                                 Colors.transparent,
//                               ],
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.green.withOpacity(0.5),
//                                 blurRadius: 8,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
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
//             child: Column(
//               children: [
//                 Text(
//                   _showMockBarcode
//                       ? 'Scanning barcode...'
//                       : 'Align barcode within the frame',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     shadows: [
//                       Shadow(
//                         blurRadius: 10,
//                         color: Colors.black,
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!_showMockBarcode) ...[
//                   const SizedBox(height: 8),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.6),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.info_outline, color: Colors.white, size: 16),
//                         SizedBox(width: 8),
//                         Text(
//                           'Tap "Manual Entry" for testing',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // BUILD A REALISTIC BARCODE IMAGE
//   Widget _buildBarcodeImage() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Barcode bars
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               _buildBar(2, 60),
//               _buildBar(1, 60),
//               _buildBar(3, 60),
//               _buildBar(1, 60),
//               _buildBar(2, 60),
//               _buildBar(1, 60),
//               _buildBar(1, 60),
//               _buildBar(3, 60),
//               _buildBar(2, 60),
//               _buildBar(1, 60),
//               _buildBar(1, 60),
//               _buildBar(2, 60),
//               _buildBar(3, 60),
//               _buildBar(1, 60),
//               _buildBar(2, 60),
//               _buildBar(1, 60),
//               _buildBar(1, 60),
//               _buildBar(2, 60),
//               _buildBar(1, 60),
//               _buildBar(3, 60),
//               _buildBar(2, 60),
//               _buildBar(1, 60),
//               _buildBar(2, 60),
//               _buildBar(3, 60),
//               _buildBar(1, 60),
//               _buildBar(1, 60),
//               _buildBar(2, 60),
//               _buildBar(1, 60),
//               _buildBar(3, 60),
//               _buildBar(1, 60),
//               _buildBar(2, 60),
//             ],
//           ),
//           const SizedBox(height: 4),
//           // Barcode number
//           const Text(
//             '3 017620 422003',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 2,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'NUTELLA',
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBar(int width, double height) {
//     return Container(
//       width: width.toDouble() * 2,
//       height: height,
//       color: Colors.black,
//       margin: const EdgeInsets.only(right: 1),
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
