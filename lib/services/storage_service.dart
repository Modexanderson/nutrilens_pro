// lib/data/services/storage_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class StorageService {
  static const String _historyBox = 'history';
  static const String _favoritesBox = 'favorites';
  static const String _themeModeKey = 'theme_mode';

  static late Box<Product> _historyBoxInstance;
  static late Box<Product> _favoritesBoxInstance;
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    // Register Hive Adapters
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(NutrimentsAdapter());

    // Open boxes
    _historyBoxInstance = await Hive.openBox<Product>(_historyBox);
    _favoritesBoxInstance = await Hive.openBox<Product>(_favoritesBox);

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
}
