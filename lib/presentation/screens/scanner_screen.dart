// lib/presentation/screens/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/product_model.dart';
import 'product_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
      // Check cache first
      Product? product = StorageService.getCachedProduct(barcode);

      // If not in cache, fetch from API
      if (product == null) {
        product = await _apiService.getProductByBarcode(barcode);
      }

      if (!mounted) return;

      if (product != null) {
        // Save to history
        await StorageService.saveToHistory(product);

        // Navigate to product detail
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
        actions: [
          IconButton(
            icon: Icon(
                _controller.torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: !_hasPermission
          ? _buildPermissionDenied()
          : Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onBarcodeDetected,
                ),
                _buildOverlay(),
                if (_isProcessing) _buildLoadingOverlay(),
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
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        // Semi-transparent black overlay covering entire screen
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        // Transparent center square (cut-out effect)
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        // Corner decorations
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
