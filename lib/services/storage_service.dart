// lib/data/services/storage_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/user_profile_model.dart';
import '../models/daily_log_model.dart';

class StorageService {
  static const String _historyBox = 'history';
  static const String _favoritesBox = 'favorites';
  static const String _userProfileBox = 'user_profile';
  static const String _dailyLogsBox = 'daily_logs';
  static const String _themeModeKey = 'theme_mode';
  static const String _userProfileKey = 'current_user';

  static late Box<Product> _historyBoxInstance;
  static late Box<Product> _favoritesBoxInstance;
  static late Box<UserProfile> _userProfileBoxInstance;
  static late Box<DailyLog> _dailyLogsBoxInstance;
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    // Register Hive Adapters - Product models
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(NutrimentsAdapter());

    // Register Hive Adapters - User Profile models
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(NutritionGoalsAdapter());

    // Register Hive Adapters - Daily Log models
    Hive.registerAdapter(DailyLogAdapter());
    Hive.registerAdapter(ConsumedProductAdapter());
    Hive.registerAdapter(MealTypeAdapter());

    // Open boxes
    _historyBoxInstance = await Hive.openBox<Product>(_historyBox);
    _favoritesBoxInstance = await Hive.openBox<Product>(_favoritesBox);
    _userProfileBoxInstance = await Hive.openBox<UserProfile>(_userProfileBox);
    _dailyLogsBoxInstance = await Hive.openBox<DailyLog>(_dailyLogsBox);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // History Management
  static Future<void> saveToHistory(Product product) async {
    await _historyBoxInstance.put(product.barcode, product);
  }

  static List<Product> getHistory() {
    return _historyBoxInstance.values.toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  static Future<void> clearHistory() async {
    await _historyBoxInstance.clear();
  }

  static Future<void> deleteFromHistory(String barcode) async {
    await _historyBoxInstance.delete(barcode);
  }

  // Favorites Management
  static Future<void> addToFavorites(Product product) async {
    final favProduct = product.copyWith(isFavorite: true);
    await _favoritesBoxInstance.put(product.barcode, favProduct);
  }

  static Future<void> removeFromFavorites(String barcode) async {
    await _favoritesBoxInstance.delete(barcode);
  }

  static List<Product> getFavorites() {
    return _favoritesBoxInstance.values.toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  static bool isFavorite(String barcode) {
    return _favoritesBoxInstance.containsKey(barcode);
  }

  static Future<void> toggleFavorite(Product product) async {
    if (isFavorite(product.barcode)) {
      await removeFromFavorites(product.barcode);
    } else {
      await addToFavorites(product);
    }
  }

  // Theme Management
  static Future<void> setThemeMode(bool isDark) async {
    await _prefs.setBool(_themeModeKey, isDark);
  }

  static Future<bool> getThemeMode() async {
    return _prefs.getBool(_themeModeKey) ?? false;
  }

  // Cache Management
  static Product? getCachedProduct(String barcode) {
    return _historyBoxInstance.get(barcode) ??
        _favoritesBoxInstance.get(barcode);
  }

  // User Profile Management
  static Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBoxInstance.put(_userProfileKey, profile);
  }

  static UserProfile? getUserProfile() {
    return _userProfileBoxInstance.get(_userProfileKey);
  }

  static bool isOnboardingCompleted() {
    final profile = getUserProfile();
    return profile?.onboardingCompleted ?? false;
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
    await _userProfileBoxInstance.put(_userProfileKey, updatedProfile);
  }

  static Future<void> addAllergenToAvoid(String allergen) async {
    final profile = getUserProfile();
    if (profile != null) {
      final allergens = List<String>.from(profile.allergensToAvoid);
      if (!allergens.contains(allergen)) {
        allergens.add(allergen);
        await updateUserProfile(profile.copyWith(allergensToAvoid: allergens));
      }
    }
  }

  static Future<void> removeAllergenToAvoid(String allergen) async {
    final profile = getUserProfile();
    if (profile != null) {
      final allergens = List<String>.from(profile.allergensToAvoid);
      allergens.remove(allergen);
      await updateUserProfile(profile.copyWith(allergensToAvoid: allergens));
    }
  }

  static Future<void> setNutritionGoals(NutritionGoals goals) async {
    final profile = getUserProfile();
    if (profile != null) {
      await updateUserProfile(profile.copyWith(nutritionGoals: goals));
    }
  }

  // Daily Log Management
  static Future<void> saveDailyLog(DailyLog log) async {
    await _dailyLogsBoxInstance.put(log.id, log);
  }

  static DailyLog? getDailyLog(DateTime date) {
    final id = DailyLog.generateId(date);
    return _dailyLogsBoxInstance.get(id);
  }

  static DailyLog getOrCreateDailyLog(DateTime date) {
    final id = DailyLog.generateId(date);
    var log = _dailyLogsBoxInstance.get(id);
    if (log == null) {
      log = DailyLog(
        id: id,
        date: DateTime(date.year, date.month, date.day),
      );
    }
    return log;
  }

  static Future<void> addConsumedProduct(
      DateTime date, ConsumedProduct product) async {
    final log = getOrCreateDailyLog(date);
    final products = List<ConsumedProduct>.from(log.consumedProducts);
    products.add(product);
    final updatedLog = log.copyWith(consumedProducts: products);
    await saveDailyLog(updatedLog);
  }

  static Future<void> removeConsumedProduct(
      DateTime date, String productId) async {
    final log = getDailyLog(date);
    if (log != null) {
      final products = List<ConsumedProduct>.from(log.consumedProducts);
      products.removeWhere((p) => p.id == productId);
      final updatedLog = log.copyWith(consumedProducts: products);
      await saveDailyLog(updatedLog);
    }
  }

  static Future<void> updateWaterIntake(DateTime date, double amount) async {
    final log = getOrCreateDailyLog(date);
    final updatedLog = log.copyWith(waterIntake: amount);
    await saveDailyLog(updatedLog);
  }

  static List<DailyLog> getAllDailyLogs() {
    return _dailyLogsBoxInstance.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<DailyLog> getDailyLogsInRange(DateTime start, DateTime end) {
    return _dailyLogsBoxInstance.values
        .where((log) =>
            log.date.isAfter(start.subtract(const Duration(days: 1))) &&
            log.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
