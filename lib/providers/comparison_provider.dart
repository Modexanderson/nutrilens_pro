// lib/providers/comparison_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

// Maximum number of products to compare
const int maxComparisonProducts = 3;

// Comparison List Provider
class ComparisonNotifier extends StateNotifier<List<Product>> {
  ComparisonNotifier() : super([]);

  void addProduct(Product product) {
    // Don't add if already in list
    if (state.any((p) => p.barcode == product.barcode)) return;

    // Don't add if at max capacity
    if (state.length >= maxComparisonProducts) {
      // Remove the first one and add the new one
      state = [...state.sublist(1), product];
    } else {
      state = [...state, product];
    }
  }

  void removeProduct(String barcode) {
    state = state.where((p) => p.barcode != barcode).toList();
  }

  void clear() {
    state = [];
  }

  bool isInComparison(String barcode) {
    return state.any((p) => p.barcode == barcode);
  }

  void toggleProduct(Product product) {
    if (isInComparison(product.barcode)) {
      removeProduct(product.barcode);
    } else {
      addProduct(product);
    }
  }
}

final comparisonProvider =
    StateNotifierProvider<ComparisonNotifier, List<Product>>(
  (ref) => ComparisonNotifier(),
);

// Convenience provider to check count
final comparisonCountProvider = Provider<int>((ref) {
  return ref.watch(comparisonProvider).length;
});

// Convenience provider to check if comparison is ready (at least 2 products)
final canCompareProvider = Provider<bool>((ref) {
  return ref.watch(comparisonProvider).length >= 2;
});
