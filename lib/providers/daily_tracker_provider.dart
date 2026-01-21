// lib/providers/daily_tracker_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/daily_log_model.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';

// Selected Date Provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Daily Log State
class DailyLogState {
  final DailyLog? log;
  final bool isLoading;
  final String? error;

  const DailyLogState({
    this.log,
    this.isLoading = false,
    this.error,
  });

  DailyLogState copyWith({
    DailyLog? log,
    bool? isLoading,
    String? error,
  }) {
    return DailyLogState(
      log: log ?? this.log,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Daily Log Notifier
class DailyLogNotifier extends StateNotifier<DailyLogState> {
  final DateTime date;

  DailyLogNotifier(this.date) : super(const DailyLogState()) {
    _loadLog();
  }

  void _loadLog() {
    state = state.copyWith(isLoading: true);
    try {
      final log = StorageService.getOrCreateDailyLog(date);
      state = state.copyWith(log: log, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addProduct({
    required Product product,
    required double servingSize,
    required MealType mealType,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final nutriments = product.nutriments;
      final multiplier = servingSize / 100; // Nutrients are per 100g

      final consumedProduct = ConsumedProduct(
        id: const Uuid().v4(),
        barcode: product.barcode,
        productName: product.name,
        servingSize: servingSize,
        calories: (nutriments?.energy ?? 0) * multiplier,
        protein: (nutriments?.proteins ?? 0) * multiplier,
        carbs: (nutriments?.carbohydrates ?? 0) * multiplier,
        fat: (nutriments?.fat ?? 0) * multiplier,
        consumedAt: DateTime.now(),
        mealType: mealType,
        imageUrl: product.imageUrl,
      );

      await StorageService.addConsumedProduct(date, consumedProduct);

      // Reload the log
      final updatedLog = StorageService.getOrCreateDailyLog(date);
      state = state.copyWith(log: updatedLog, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> removeProduct(String productId) async {
    state = state.copyWith(isLoading: true);
    try {
      await StorageService.removeConsumedProduct(date, productId);

      // Reload the log
      final updatedLog = StorageService.getOrCreateDailyLog(date);
      state = state.copyWith(log: updatedLog, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateWaterIntake(double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      await StorageService.updateWaterIntake(date, amount);

      // Reload the log
      final updatedLog = StorageService.getOrCreateDailyLog(date);
      state = state.copyWith(log: updatedLog, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void refresh() {
    _loadLog();
  }
}

// Daily Log Provider (depends on selected date)
final dailyLogProvider =
    StateNotifierProvider.family<DailyLogNotifier, DailyLogState, DateTime>(
  (ref, date) => DailyLogNotifier(date),
);

// Current Day Log Provider (convenience)
final currentDayLogProvider = Provider<DailyLogState>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  return ref.watch(dailyLogProvider(selectedDate));
});

// Total Calories Provider
final totalCaloriesProvider = Provider<double>((ref) {
  final logState = ref.watch(currentDayLogProvider);
  return logState.log?.totalCalories ?? 0;
});

// Total Protein Provider
final totalProteinProvider = Provider<double>((ref) {
  final logState = ref.watch(currentDayLogProvider);
  return logState.log?.totalProtein ?? 0;
});

// Total Carbs Provider
final totalCarbsProvider = Provider<double>((ref) {
  final logState = ref.watch(currentDayLogProvider);
  return logState.log?.totalCarbs ?? 0;
});

// Total Fat Provider
final totalFatProvider = Provider<double>((ref) {
  final logState = ref.watch(currentDayLogProvider);
  return logState.log?.totalFat ?? 0;
});

// Water Intake Provider
final waterIntakeProvider = Provider<double>((ref) {
  final logState = ref.watch(currentDayLogProvider);
  return logState.log?.waterIntake ?? 0;
});

// Products by Meal Type Provider
final productsByMealTypeProvider =
    Provider.family<List<ConsumedProduct>, MealType>((ref, mealType) {
  final logState = ref.watch(currentDayLogProvider);
  return logState.log?.getProductsByMealType(mealType) ?? [];
});
