// lib/presentation/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              _buildProductImage(),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.brand!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (product.nutriscore != null)
                          _buildNutriscoreBadge(product.nutriscore!),
                        const Spacer(),
                        Text(
                          _formatDate(product.scannedAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
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
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey,
                ),
              ),
            )
          : const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.grey,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[grade] ?? Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        grade,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat.Hm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
}
