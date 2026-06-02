// lib/presentation/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/log_food_sheet.dart';
import '../providers/user_profile_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late bool _isFavorite;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = StorageService.isFavorite(widget.product.barcode);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    await StorageService.toggleFavorite(widget.product);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareProduct() {
    final text = '''
${widget.product.name}
${widget.product.brand != null ? 'Brand: ${widget.product.brand}' : ''}
Barcode: ${widget.product.barcode}

Scanned with NutriLens Pro
''';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    // Check for allergen warnings
    final matchingAllergens = ref
        .watch(userProfileProvider.notifier)
        .checkProductAllergens(widget.product.allergens);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          // Allergen warning banner
          if (matchingAllergens.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildAllergenWarningBanner(matchingAllergens),
            ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(),
                const Divider(height: 32),
                _buildNutritionInfo(),
                // In-content ad placement
                if (_isBannerLoaded && _bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 250,
                    child: AdWidget(ad: _bannerAd!),
                  ),
                const Divider(height: 32),
                _buildIngredients(),
                if (widget.product.allergens != null &&
                    widget.product.allergens!.isNotEmpty) ...[
                  const Divider(height: 32),
                  _buildAllergens(),
                ],
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LogFoodSheet.show(context, widget.product),
        icon: const Icon(Icons.add),
        label: const Text('Log This'),
      ),
    );
  }

  Widget _buildAllergenWarningBanner(List<String> matchingAllergens) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allergen Warning',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This product contains allergens you\'re avoiding:',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: matchingAllergens.map((allergen) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        allergen,
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.product.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.product.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: _toggleFavorite,
          color: _isFavorite ? Colors.red : null,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareProduct,
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (widget.product.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.product.brand!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.product.nutriscore != null)
                _buildNutriscoreBadge(widget.product.nutriscore!),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.product.quantity != null)
                Chip(
                  label: Text(widget.product.quantity!),
                  avatar: const Icon(Icons.scale, size: 18),
                ),
              Chip(
                label: Text(widget.product.barcode),
                avatar: const Icon(Icons.qr_code, size: 18),
              ),
            ],
          ),
          if (widget.product.categories != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.product.categories!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors[grade] ?? Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Nutri-Score: $grade',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNutritionInfo() {
    final nutriments = widget.product.nutriments;
    if (nutriments == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Nutrition information not available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Facts (per 100g)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildNutrientRow('Energy', nutriments.energy, 'kcal'),
          _buildNutrientRow('Proteins', nutriments.proteins, 'g'),
          _buildNutrientRow('Carbohydrates', nutriments.carbohydrates, 'g'),
          _buildNutrientRow('  - Sugars', nutriments.sugars, 'g', indent: true),
          _buildNutrientRow('Fat', nutriments.fat, 'g'),
          _buildNutrientRow('  - Saturated', nutriments.saturatedFat, 'g',
              indent: true),
          _buildNutrientRow('Fiber', nutriments.fiber, 'g'),
          _buildNutrientRow('Sodium', nutriments.sodium, 'g'),
          _buildNutrientRow('Salt', nutriments.salt, 'g'),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String name, double? value, String unit,
      {bool indent = false}) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 12, left: indent ? 16 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: indent ? FontWeight.normal : FontWeight.w500,
                ),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    final ingredients = widget.product.ingredients;
    if (ingredients == null || ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            ingredients.join(', '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergens() {
    final allergens = widget.product.allergens!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Text(
                'Allergens',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergens.map((allergen) {
              return Chip(
                label: Text(allergen),
                backgroundColor: Colors.red[50],
                labelStyle: const TextStyle(color: AppTheme.errorColor),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
