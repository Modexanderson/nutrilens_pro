// lib/widgets/log_food_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../models/daily_log_model.dart';
import '../providers/daily_tracker_provider.dart';

class LogFoodSheet extends ConsumerStatefulWidget {
  final Product product;

  const LogFoodSheet({super.key, required this.product});

  static Future<bool?> show(BuildContext context, Product product) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogFoodSheet(product: product),
    );
  }

  @override
  ConsumerState<LogFoodSheet> createState() => _LogFoodSheetState();
}

class _LogFoodSheetState extends ConsumerState<LogFoodSheet> {
  double _servingSize = 100;
  MealType _selectedMealType = MealType.snack;
  final TextEditingController _customServingController =
      TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _selectedMealType = _getDefaultMealType();
  }

  @override
  void dispose() {
    _customServingController.dispose();
    super.dispose();
  }

  MealType _getDefaultMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 21) return MealType.dinner;
    return MealType.snack;
  }

  void _updateServing(double value) {
    setState(() {
      _servingSize = value;
      _customServingController.text = value.toInt().toString();
    });
  }

  double get _calories =>
      (widget.product.nutriments?.energy ?? 0) * _servingSize / 100;
  double get _protein =>
      (widget.product.nutriments?.proteins ?? 0) * _servingSize / 100;
  double get _carbs =>
      (widget.product.nutriments?.carbohydrates ?? 0) * _servingSize / 100;
  double get _fat =>
      (widget.product.nutriments?.fat ?? 0) * _servingSize / 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Product Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: widget.product.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.shopping_bag_outlined,
                            color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.product.brand != null)
                          Text(
                            widget.product.brand!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Serving Size
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Serving Size',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  // Quick buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildServingButton(50),
                      _buildServingButton(100),
                      _buildServingButton(150),
                      _buildServingButton(200),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Custom input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customServingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Custom amount',
                            suffixText: 'g',
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              setState(() {
                                _servingSize = parsed;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Meal Type
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MealType.values.map((type) {
                      final isSelected = type == _selectedMealType;
                      return ChoiceChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedMealType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Nutrition Preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition for ${_servingSize.toInt()}g',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionItem(
                          'Calories', _calories.toStringAsFixed(0), 'kcal'),
                      _buildNutritionItem(
                          'Protein', _protein.toStringAsFixed(1), 'g'),
                      _buildNutritionItem(
                          'Carbs', _carbs.toStringAsFixed(1), 'g'),
                      _buildNutritionItem('Fat', _fat.toStringAsFixed(1), 'g'),
                    ],
                  ),
                ],
              ),
            ),

            // Log Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _logFood,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Log Food'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingButton(double amount) {
    final isSelected = _servingSize == amount;
    return OutlinedButton(
      onPressed: () => _updateServing(amount),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
        ),
      ),
      child: Text('${amount.toInt()}g'),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Future<void> _logFood() async {
    final selectedDate = ref.read(selectedDateProvider);
    final notifier = ref.read(dailyLogProvider(selectedDate).notifier);

    await notifier.addProduct(
      product: widget.product,
      servingSize: _servingSize,
      mealType: _selectedMealType,
    );

    if (mounted) {
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} logged to ${_selectedMealType.displayName}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
