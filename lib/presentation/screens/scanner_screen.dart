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

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  bool _isCheckingPermission = true;
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndInitializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndInitializeCamera();
    }
  }

  Future<void> _checkAndInitializeCamera() async {
    setState(() => _isCheckingPermission = true);

    final status = await Permission.camera.status;

    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _isCheckingPermission = false;
      });

      // Initialize controller only if permission is granted
      if (status.isGranted && _controller == null) {
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        );
        setState(() {}); // Rebuild to show camera
      }
    }
  }

  Future<void> _handlePermissionRequest() async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      // First time asking or previously denied but can ask again
      final result = await Permission.camera.request();
      if (mounted) {
        setState(() => _permissionStatus = result);
        if (result.isGranted) {
          _checkAndInitializeCamera();
        }
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      // Permission permanently denied, must open settings
      _showSettingsDialog();
    } else if (status.isGranted) {
      _checkAndInitializeCamera();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Access Required'),
        content: const Text(
          'Camera permission is required to scan barcodes.\n\n'
          'Please enable camera access in Settings:\n'
          '1. Tap "Open Settings"\n'
          '2. Scroll down and tap "Camera"\n'
          '3. Toggle it ON',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
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
    final hasPermission = _permissionStatus?.isGranted ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: hasPermission && _controller != null
            ? [
                IconButton(
                  icon: Icon(_controller!.torchEnabled
                      ? Icons.flash_on
                      : Icons.flash_off),
                  onPressed: () => _controller!.toggleTorch(),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios),
                  onPressed: () => _controller!.switchCamera(),
                ),
              ]
            : null,
      ),
      body: _isCheckingPermission
          ? _buildLoadingState()
          : !hasPermission
              ? _buildPermissionDenied()
              : _controller == null
                  ? _buildLoadingState()
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _permissionStatus?.isPermanentlyDenied ?? false
                  ? 'Camera permission was denied. Please enable it in Settings to scan barcodes.'
                  : 'This app needs camera access to scan product barcodes.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handlePermissionRequest,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                _permissionStatus?.isPermanentlyDenied ?? false
                    ? 'Open Settings'
                    : 'Grant Permission',
              ),
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
