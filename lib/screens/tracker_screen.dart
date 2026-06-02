// lib/screens/tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/daily_log_model.dart';
import '../providers/daily_tracker_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/nutrition_progress.dart';
import 'search_screen.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  late PageController _datePageController;

  @override
  void initState() {
    super.initState();
    _datePageController = PageController(initialPage: 1000, viewportFraction: 0.3);
  }

  @override
  void dispose() {
    _datePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final logState = ref.watch(dailyLogProvider(selectedDate));
    final nutritionGoals = ref.watch(nutritionGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: logState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(dailyLogProvider(selectedDate).notifier).refresh();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Date Selector
                    _buildDateSelector(selectedDate),

                    // Calorie Progress
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressWithLabel(
                        current: logState.log?.totalCalories ?? 0,
                        goal: nutritionGoals.dailyCalories,
                        label: 'kcal',
                      ),
                    ),

                    // Macro Progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              MacroProgressBar(
                                label: 'Protein',
                                current: logState.log?.totalProtein ?? 0,
                                goal: nutritionGoals.dailyProtein,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              MacroProgressBar(
                                label: 'Carbs',
                                current: logState.log?.totalCarbs ?? 0,
                                goal: nutritionGoals.dailyCarbs,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              MacroProgressBar(
                                label: 'Fat',
                                current: logState.log?.totalFat ?? 0,
                                goal: nutritionGoals.dailyFat,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Water Intake
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: WaterIntakeWidget(
                        current: logState.log?.waterIntake ?? 0,
                        goal: nutritionGoals.dailyCalories >= 2500 ? 2500 : 2000, // Scale with calorie goal
                        onAdd: () {
                          final current = logState.log?.waterIntake ?? 0;
                          ref
                              .read(dailyLogProvider(selectedDate).notifier)
                              .updateWaterIntake(current + 250);
                        },
                        onRemove: () {
                          final current = logState.log?.waterIntake ?? 0;
                          if (current >= 250) {
                            ref
                                .read(dailyLogProvider(selectedDate).notifier)
                                .updateWaterIntake(current - 250);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Meal Sections
                    ...MealType.values.map((mealType) {
                      final products =
                          logState.log?.getProductsByMealType(mealType) ?? [];
                      return _buildMealSection(
                          context, mealType, products, selectedDate);
                    }),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
    );
  }

  Widget _buildDateSelector(DateTime selectedDate) {
    final today = DateTime.now();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemBuilder: (context, index) {
          // Show 3 days before and 3 days after today
          final date = today.subtract(Duration(days: 3 - index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, today);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                        child: isToday
                            ? Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    MealType mealType,
    List<ConsumedProduct> products,
    DateTime selectedDate,
  ) {
    final mealCalories =
        products.fold<double>(0, (sum, p) => sum + p.calories);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _getMealIcon(mealType),
                      const SizedBox(width: 12),
                      Text(
                        mealType.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Text(
                    '${mealCalories.toInt()} kcal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Products
            if (products.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text(
                  'No food logged',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              )
            else
              ...products.map((product) => _buildProductItem(
                  context, product, selectedDate)),

            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    ConsumedProduct product,
    DateTime selectedDate,
  ) {
    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref
            .read(dailyLogProvider(selectedDate).notifier)
            .removeProduct(product.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
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
              : const Icon(Icons.fastfood, color: Colors.grey),
        ),
        title: Text(
          product.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${product.servingSize.toInt()}g',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.calories.toInt()} kcal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              'P:${product.protein.toInt()} C:${product.carbs.toInt()} F:${product.fat.toInt()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMealIcon(MealType mealType) {
    final color = Theme.of(context).colorScheme.primary;
    switch (mealType) {
      case MealType.breakfast:
        return Icon(Icons.breakfast_dining, color: color);
      case MealType.lunch:
        return Icon(Icons.lunch_dining, color: color);
      case MealType.dinner:
        return Icon(Icons.dinner_dining, color: color);
      case MealType.snack:
        return Icon(Icons.cookie, color: color);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = ref.read(selectedDateProvider);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      ref.read(selectedDateProvider.notifier).state = pickedDate;
    }
  }
}
