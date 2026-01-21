// lib/screens/demo_scanner_screen.dart
// Demo scanner screen for App Store screenshots
// DELETE THIS FILE AFTER TAKING SCREENSHOTS

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/demo_data_service.dart';
import 'product_detail_screen.dart';

class DemoScannerScreen extends StatefulWidget {
  const DemoScannerScreen({super.key});

  @override
  State<DemoScannerScreen> createState() => _DemoScannerScreenState();
}

class _DemoScannerScreenState extends State<DemoScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  bool _showProductCard = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 280.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = DemoDataService.getNutellaProduct();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fake camera background - dark gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f0f23),
                ],
              ),
            ),
          ),

          // Full screen product image (simulating camera view of product)
          Positioned.fill(
            top: 0,
            bottom: _showProductCard ? 220 : 0,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: const Color(0xFF1a1a2e),
              ),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF1a1a2e),
              ),
            ),
          ),

          // Semi-transparent overlay for scanner effect
          Positioned.fill(
            top: 0,
            bottom: _showProductCard ? 220 : 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Scanner frame overlay
          Center(
            child: Container(
              width: 280,
              height: 280,
              margin: const EdgeInsets.only(bottom: 100),
              child: Stack(
                children: [
                  // Corner decorations
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(primaryColor, topLeft: true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCorner(primaryColor, topRight: true),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCorner(primaryColor, bottomLeft: true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCorner(primaryColor, bottomRight: true),
                  ),

                  // Scanning line animation
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanAnimation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                primaryColor.withOpacity(0.8),
                                primaryColor,
                                primaryColor.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Instruction text
          Positioned(
            bottom: _showProductCard ? 260 : 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Product detected!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product preview card at bottom
          if (_showProductCard)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              product.brand ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildNutriscoreBadge(product.nutriscore ?? 'E'),
                                const SizedBox(width: 8),
                                Text(
                                  '${product.nutriments?.energy?.toInt() ?? 0} kcal/100g',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBarcodeDisplay() {
    final product = DemoDataService.getNutellaProduct();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: product.imageUrl!,
        width: 220,
        height: 220,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 60),
        ),
      ),
    );
  }

  List<Widget> _buildBarcodeBars() {
    // Realistic barcode pattern
    final pattern = [2, 1, 1, 2, 3, 1, 2, 1, 1, 3, 2, 1, 2, 1, 3, 1, 1, 2, 1, 2, 3, 1, 2, 1, 1, 2, 1, 3, 2, 1];
    return pattern.map((width) {
      return Container(
        width: width.toDouble() * 1.5,
        height: 45,
        color: Colors.black,
        margin: const EdgeInsets.only(right: 1),
      );
    }).toList();
  }

  Widget _buildCorner(Color color,
      {bool topLeft = false,
      bool topRight = false,
      bool bottomLeft = false,
      bool bottomRight = false}) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        border: Border(
          top: topLeft || topRight
              ? BorderSide(color: color, width: 4)
              : BorderSide.none,
          bottom: bottomLeft || bottomRight
              ? BorderSide(color: color, width: 4)
              : BorderSide.none,
          left: topLeft || bottomLeft
              ? BorderSide(color: color, width: 4)
              : BorderSide.none,
          right: topRight || bottomRight
              ? BorderSide(color: color, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildNutriscoreBadge(String grade) {
    final colors = {
      'A': Colors.green[700]!,
      'B': Colors.lightGreen,
      'C': Colors.yellow[700]!,
      'D': Colors.orange,
      'E': Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors[grade] ?? Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Nutri-Score $grade',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
