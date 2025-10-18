// lib/presentation/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/services/storage_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Product>>(
  (ref) => HistoryNotifier(),
);

class HistoryNotifier extends StateNotifier<List<Product>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    state = StorageService.getHistory();
  }

  Future<void> refresh() async {
    _loadHistory();
  }

  Future<void> clearAll() async {
    await StorageService.clearHistory();
    state = [];
  }

  Future<void> deleteItem(String barcode) async {
    await StorageService.deleteFromHistory(barcode);
    state = state.where((p) => p.barcode != barcode).toList();
  }
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearDialog(context, ref),
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(historyProvider.notifier).refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final product = history[index];
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
                          .read(historyProvider.notifier)
                          .deleteItem(product.barcode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item removed from history'),
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
                            ref.read(historyProvider.notifier).refresh());
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
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No scan history yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning products to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all scan history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
