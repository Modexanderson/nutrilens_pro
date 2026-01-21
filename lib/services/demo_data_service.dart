// lib/services/demo_data_service.dart
// Demo data service for App Store screenshots
// DELETE THIS FILE AFTER TAKING SCREENSHOTS

import '../models/product_model.dart';
import '../models/daily_log_model.dart';
import '../models/user_profile_model.dart';
import 'storage_service.dart';

class DemoDataService {
  static bool _isDemoMode = false;
  static bool get isDemoMode => _isDemoMode;

  // Call this to load all demo data
  static Future<void> loadDemoData() async {
    _isDemoMode = true;
    await _loadDemoProducts();
    await _loadDemoTrackerData();
    await _loadDemoUserProfile();
  }

  // Call this to clear all demo data
  static Future<void> clearDemoData() async {
    await StorageService.clearHistory();
    // Clear favorites by removing each one
    final favorites = StorageService.getFavorites();
    for (final fav in favorites) {
      await StorageService.removeFromFavorites(fav.barcode);
    }
    _isDemoMode = false;
  }

  static Future<void> _loadDemoProducts() async {
    // Demo products with realistic nutrition data
    final demoProducts = [
      // Nutella - the star product for scanner demo
      Product(
        barcode: '3017620422003',
        name: 'Nutella',
        brand: 'Ferrero',
        imageUrl: 'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.633.400.jpg',
        nutriscore: 'E',
        nutriments: Nutriments(
          energy: 539,
          proteins: 6.3,
          carbohydrates: 57.5,
          sugars: 56.3,
          fat: 30.9,
          saturatedFat: 10.6,
          fiber: 3.4,
          sodium: 0.041,
          salt: 0.107,
        ),
        ingredients: ['Sugar', 'Palm Oil', 'Hazelnuts (13%)', 'Skimmed Milk Powder (8.7%)', 'Fat-Reduced Cocoa (7.4%)', 'Emulsifier: Lecithins (Soya)', 'Vanillin'],
        allergens: ['milk', 'nuts', 'soybeans'],
        categories: 'Spreads, Sweet spreads, Hazelnut spreads, Chocolate spreads',
        quantity: '750 g',
        scannedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),

      // Coca-Cola
      Product(
        barcode: '5449000000996',
        name: 'Coca-Cola Original Taste',
        brand: 'Coca-Cola',
        imageUrl: 'https://images.openfoodfacts.org/images/products/544/900/000/0996/front_en.1002.400.jpg',
        nutriscore: 'E',
        nutriments: Nutriments(
          energy: 42,
          proteins: 0,
          carbohydrates: 10.6,
          sugars: 10.6,
          fat: 0,
          saturatedFat: 0,
          fiber: 0,
          sodium: 0,
          salt: 0,
        ),
        ingredients: ['Carbonated Water', 'Sugar', 'Colour (Caramel E150d)', 'Phosphoric Acid', 'Natural Flavourings Including Caffeine'],
        allergens: [],
        categories: 'Beverages, Carbonated drinks, Sodas, Colas',
        quantity: '330 ml',
        scannedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),

      // Greek Yogurt - healthy option
      Product(
        barcode: '4056489148739',
        name: 'Creamy Greek Style Yogurt',
        brand: 'Milbona',
        imageUrl: 'https://images.openfoodfacts.org/images/products/405/648/914/8739/front_en.73.400.jpg',
        nutriscore: 'A',
        nutriments: Nutriments(
          energy: 54,
          proteins: 10.3,
          carbohydrates: 4.0,
          sugars: 4.0,
          fat: 0,
          saturatedFat: 0,
          fiber: 0,
          sodium: 0.036,
          salt: 0.09,
        ),
        ingredients: ['Grade A Pasteurized Skimmed Milk', 'Live Active Yogurt Cultures'],
        allergens: ['milk'],
        categories: 'Dairy, Yogurts, Greek yogurts',
        quantity: '170 g',
        scannedAt: DateTime.now().subtract(const Duration(hours: 4)),
        isFavorite: true,
      ),

      // Oatmeal
      Product(
        barcode: '8410376033267',
        name: 'Digestive Oats Sugar-Free',
        brand: 'Gullón',
        imageUrl: 'https://images.openfoodfacts.org/images/products/841/037/603/3267/front_en.127.400.jpg',
        nutriscore: 'A',
        nutriments: Nutriments(
          energy: 379,
          proteins: 13.2,
          carbohydrates: 67.7,
          sugars: 1.0,
          fat: 6.5,
          saturatedFat: 1.2,
          fiber: 10.1,
          sodium: 0,
          salt: 0,
        ),
        ingredients: ['100% Natural Whole Grain Rolled Oats'],
        allergens: ['gluten'],
        categories: 'Cereals, Breakfast cereals, Oatmeal',
        quantity: '510 g',
        scannedAt: DateTime.now().subtract(const Duration(hours: 6)),
        isFavorite: true,
      ),

      // Almond Milk
      Product(
        barcode: '4056489346357',
        name: 'Organic Almond Drink Sugar-free',
        brand: 'Vemondo',
        imageUrl: 'https://images.openfoodfacts.org/images/products/405/648/934/6357/front_en.327.400.jpg',
        nutriscore: 'A',
        nutriments: Nutriments(
          energy: 13,
          proteins: 0.4,
          carbohydrates: 0.2,
          sugars: 0,
          fat: 1.1,
          saturatedFat: 0,
          fiber: 0,
          sodium: 0.07,
          salt: 0.17,
        ),
        ingredients: ['Almond Milk (Filtered Water, Almonds)', 'Calcium Carbonate', 'Sea Salt', 'Potassium Citrate', 'Sunflower Lecithin', 'Gellan Gum', 'Vitamin A Palmitate', 'Vitamin D2', 'D-Alpha-Tocopherol (Natural Vitamin E)'],
        allergens: ['nuts'],
        categories: 'Beverages, Plant-based milk, Almond milk',
        quantity: '946 ml',
        scannedAt: DateTime.now().subtract(const Duration(hours: 8)),
        isFavorite: true,
      ),

      // Barilla Pasta
      Product(
        barcode: '8076800195057',
        name: 'Spaghetti N° 5',
        brand: 'Barilla',
        imageUrl: 'https://images.openfoodfacts.org/images/products/807/680/019/5057/front_en.3704.400.jpg',
        nutriscore: 'A',
        nutriments: Nutriments(
          energy: 359,
          proteins: 12.5,
          carbohydrates: 72.0,
          sugars: 3.0,
          fat: 1.5,
          saturatedFat: 0.3,
          fiber: 3.0,
          sodium: 0.003,
          salt: 0.008,
        ),
        ingredients: ['Durum Wheat Semolina', 'Water'],
        allergens: ['gluten'],
        categories: 'Pasta, Spaghetti',
        quantity: '500 g',
        scannedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // Kind Bar
      Product(
        barcode: '5000159535267',
        name: 'Dark Chocolate Nuts & Sea Salt',
        brand: 'KIND',
        imageUrl: 'https://images.openfoodfacts.org/images/products/500/015/953/5267/front_en.3.400.jpg',
        nutriscore: 'C',
        nutriments: Nutriments(
          energy: 200,
          proteins: 6.0,
          carbohydrates: 16.0,
          sugars: 5.0,
          fat: 15.0,
          saturatedFat: 3.5,
          fiber: 7.0,
          sodium: 0.125,
          salt: 0.31,
        ),
        ingredients: ['Almonds', 'Peanuts', 'Chicory Root Fiber', 'Honey', 'Palm Kernel Oil', 'Sugar', 'Cocoa Powder'],
        allergens: ['nuts', 'peanuts'],
        categories: 'Snacks, Granola bars, Nut bars',
        quantity: '40 g',
        scannedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ),

      // Evian Water
      Product(
        barcode: '3068320014067',
        name: 'Natural Mineral Water',
        brand: 'Evian',
        imageUrl: 'https://images.openfoodfacts.org/images/products/306/832/001/4067/front_en.115.400.jpg',
        nutriscore: 'A',
        nutriments: Nutriments(
          energy: 0,
          proteins: 0,
          carbohydrates: 0,
          sugars: 0,
          fat: 0,
          saturatedFat: 0,
          fiber: 0,
          sodium: 0.005,
          salt: 0.01,
        ),
        ingredients: ['Natural Mineral Water'],
        allergens: [],
        categories: 'Beverages, Waters, Mineral waters',
        quantity: '1.5 L',
        scannedAt: DateTime.now().subtract(const Duration(days: 2)),
        isFavorite: true,
      ),
    ];

    // Save to history
    for (final product in demoProducts) {
      await StorageService.saveToHistory(product);

      // Add favorites
      if (product.isFavorite) {
        await StorageService.addToFavorites(product);
      }
    }
  }

  static Future<void> _loadDemoTrackerData() async {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // Create consumed products for today
    final consumedProducts = [
      ConsumedProduct(
        id: 'demo_1',
        barcode: '8410376033267',
        productName: 'Digestive Oats Sugar-Free',
        servingSize: 60,
        calories: 227,
        protein: 7.9,
        carbs: 40.6,
        fat: 3.9,
        consumedAt: DateTime(today.year, today.month, today.day, 7, 30),
        mealType: MealType.breakfast,
        imageUrl: 'https://images.openfoodfacts.org/images/products/841/037/603/3267/front_en.127.400.jpg',
      ),
      ConsumedProduct(
        id: 'demo_2',
        barcode: '4056489148739',
        productName: 'Creamy Greek Style Yogurt',
        servingSize: 170,
        calories: 92,
        protein: 17.5,
        carbs: 6.8,
        fat: 0,
        consumedAt: DateTime(today.year, today.month, today.day, 7, 45),
        mealType: MealType.breakfast,
        imageUrl: 'https://images.openfoodfacts.org/images/products/405/648/914/8739/front_en.73.400.jpg',
      ),
      ConsumedProduct(
        id: 'demo_3',
        barcode: '8076800195057',
        productName: 'Barilla Spaghetti N° 5',
        servingSize: 100,
        calories: 359,
        protein: 12.5,
        carbs: 72.0,
        fat: 1.5,
        consumedAt: DateTime(today.year, today.month, today.day, 12, 30),
        mealType: MealType.lunch,
        imageUrl: 'https://images.openfoodfacts.org/images/products/807/680/019/5057/front_en.3704.400.jpg',
      ),
      ConsumedProduct(
        id: 'demo_4',
        barcode: '5000159535267',
        productName: 'KIND Dark Chocolate Bar',
        servingSize: 40,
        calories: 200,
        protein: 6.0,
        carbs: 16.0,
        fat: 15.0,
        consumedAt: DateTime(today.year, today.month, today.day, 15, 0),
        mealType: MealType.snack,
        imageUrl: 'https://images.openfoodfacts.org/images/products/500/015/953/5267/front_en.3.400.jpg',
      ),
    ];

    // Create daily log
    final dailyLog = DailyLog(
      id: DailyLog.generateId(todayNormalized),
      date: todayNormalized,
      consumedProducts: consumedProducts,
      waterIntake: 1500, // 1.5L of water
    );

    await StorageService.saveDailyLog(dailyLog);
  }

  static Future<void> _loadDemoUserProfile() async {
    final profile = UserProfile(
      id: 'demo_user',
      name: 'Demo User',
      allergensToAvoid: ['Peanuts', 'Tree Nuts'],
      dietaryRestrictions: ['Low Sugar'],
      nutritionGoals: NutritionGoals(
        dailyCalories: 2000,
        dailyProtein: 50,
        dailyCarbs: 250,
        dailyFat: 65,
        dailyFiber: 25,
        dailySodium: 2300,
      ),
      onboardingCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    await StorageService.saveUserProfile(profile);
  }

  // Get the Nutella product for scanner demo
  static Product getNutellaProduct() {
    return Product(
      barcode: '3017620422003',
      name: 'Nutella',
      brand: 'Ferrero',
      imageUrl: 'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.633.400.jpg',
      nutriscore: 'E',
      nutriments: Nutriments(
        energy: 539,
        proteins: 6.3,
        carbohydrates: 57.5,
        sugars: 56.3,
        fat: 30.9,
        saturatedFat: 10.6,
        fiber: 3.4,
        sodium: 0.041,
        salt: 0.107,
      ),
      ingredients: ['Sugar', 'Palm Oil', 'Hazelnuts (13%)', 'Skimmed Milk Powder (8.7%)', 'Fat-Reduced Cocoa (7.4%)', 'Emulsifier: Lecithins (Soya)', 'Vanillin'],
      allergens: ['milk', 'nuts', 'soybeans'],
      categories: 'Spreads, Sweet spreads, Hazelnut spreads, Chocolate spreads',
      quantity: '750 g',
      scannedAt: DateTime.now(),
    );
  }
}
