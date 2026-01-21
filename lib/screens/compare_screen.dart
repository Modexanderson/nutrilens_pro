// lib/screens/compare_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../providers/comparison_provider.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(comparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Products'),
        actions: [
          if (products.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(comparisonProvider.notifier).clear();
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: products.isEmpty
          ? _buildEmptyState(context)
          : products.length < 2
              ? _buildNeedMoreProducts(context)
              : _buildComparison(context, ref, products),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Products to Compare',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add products to compare by tapping the compare icon on any product card',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedMoreProducts(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Add More Products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add at least 2 products to compare their nutrition information',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison(
      BuildContext context, WidgetRef ref, List<Product> products) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Product headers
          _buildProductHeaders(context, ref, products),
          const Divider(),

          // Nutriscore row
          _buildComparisonRow(
            context,
            'Nutriscore',
            products.map((p) => p.nutriscore ?? '-').toList(),
            isNutriscore: true,
          ),
          const Divider(),

          // Nutrition rows
          _buildNutritionSection(context, products),
        ],
      ),
    );
  }

  Widget _buildProductHeaders(
      BuildContext context, WidgetRef ref, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: products.map((product) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: product.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.shopping_bag_outlined,
                                color: Colors.grey),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, size: 20),
                          onPressed: () {
                            ref
                                .read(comparisonProvider.notifier)
                                .removeProduct(product.barcode);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionSection(BuildContext context, List<Product> products) {
    final nutritionData = <String, List<double?>>{
      'Energy (kcal)':
          products.map((p) => p.nutriments?.energy).toList(),
      'Protein (g)': products.map((p) => p.nutriments?.proteins).toList(),
      'Carbs (g)':
          products.map((p) => p.nutriments?.carbohydrates).toList(),
      'Sugars (g)': products.map((p) => p.nutriments?.sugars).toList(),
      'Fat (g)': products.map((p) => p.nutriments?.fat).toList(),
      'Saturated Fat (g)':
          products.map((p) => p.nutriments?.saturatedFat).toList(),
      'Fiber (g)': products.map((p) => p.nutriments?.fiber).toList(),
      'Sodium (g)': products.map((p) => p.nutriments?.sodium).toList(),
      'Salt (g)': products.map((p) => p.nutriments?.salt).toList(),
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Facts (per 100g)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...nutritionData.entries.map((entry) {
            return _buildNutritionRow(context, entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    String label,
    List<String> values, {
    bool isNutriscore = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          ...values.map((value) {
            return Expanded(
              flex: 1,
              child: isNutriscore
                  ? Center(child: _buildNutriscoreBadge(context, value))
                  : Text(
                      value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(
      BuildContext context, String label, List<double?> values) {
    // Find the lowest non-null value for highlighting
    final nonNullValues = values.whereType<double>().toList();
    final lowestValue = nonNullValues.isEmpty
        ? null
        : nonNullValues.reduce((a, b) => a < b ? a : b);

    // For calories and macros, lower is often "better" (except protein sometimes)
    final isLowerBetter = !label.contains('Protein') && !label.contains('Fiber');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ...values.map((value) {
            final isLowest = value != null && value == lowestValue;
            final shouldHighlight = isLowest && isLowerBetter && nonNullValues.length > 1;

            return Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: shouldHighlight
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value?.toStringAsFixed(1) ?? '-',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            shouldHighlight ? FontWeight.bold : FontWeight.normal,
                        color: shouldHighlight
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNutriscoreBadge(BuildContext context, String grade) {
    if (grade == '-') {
      return Text(
        '-',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final colors = {
      'A': Colors.green[700]!,
      'B': Colors.lightGreen,
      'C': Colors.yellow[700]!,
      'D': Colors.orange,
      'E': Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors[grade] ?? Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        grade,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
