// lib/presentation/screen/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/services/storage_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Product>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<Product>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = StorageService.getFavorites();
  }

  Future<void> refresh() async {
    _loadFavorites();
  }

  Future<void> removeItem(String barcode) async {
    await StorageService.removeFromFavorites(barcode);
    state = state.where((p) => p.barcode != barcode).toList();
  }
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(favoritesProvider.notifier).refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final product = favorites[index];
                  return Dismissible(
                    key: Key(product.barcode),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) {
                      ref
                          .read(favoritesProvider.notifier)
                          .removeItem(product.barcode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from favorites'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        ).then((_) =>
                            ref.read(favoritesProvider.notifier).refresh());
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on products to save them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
