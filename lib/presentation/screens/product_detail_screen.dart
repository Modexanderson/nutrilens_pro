// lib/presentation/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/product_model.dart';
import '../../data/services/storage_service.dart';
import '../../core/theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = StorageService.isFavorite(widget.product.barcode);
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(),
                const Divider(height: 32),
                _buildNutritionInfo(),
                const Divider(height: 32),
                _buildIngredients(),
                if (widget.product.allergens != null &&
                    widget.product.allergens!.isNotEmpty) ...[
                  const Divider(height: 32),
                  _buildAllergens(),
                ],
                const SizedBox(height: 24),
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
