// lib/models/daily_log_model.dart

import 'package:hive/hive.dart';

part 'daily_log_model.g.dart';

@HiveType(typeId: 4)
class DailyLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<ConsumedProduct> consumedProducts;

  @HiveField(3)
  final double? waterIntake;

  @HiveField(4)
  final String? notes;

  DailyLog({
    required this.id,
    required this.date,
    List<ConsumedProduct>? consumedProducts,
    this.waterIntake,
    this.notes,
  }) : consumedProducts = consumedProducts ?? [];

  // Get total calories for the day
  double get totalCalories {
    return consumedProducts.fold(0, (sum, product) => sum + product.calories);
  }

  // Get total protein for the day
  double get totalProtein {
    return consumedProducts.fold(0, (sum, product) => sum + product.protein);
  }

  // Get total carbs for the day
  double get totalCarbs {
    return consumedProducts.fold(0, (sum, product) => sum + product.carbs);
  }

  // Get total fat for the day
  double get totalFat {
    return consumedProducts.fold(0, (sum, product) => sum + product.fat);
  }

  // Get products by meal type
  List<ConsumedProduct> getProductsByMealType(MealType mealType) {
    return consumedProducts
        .where((product) => product.mealType == mealType)
        .toList();
  }

  // Create a unique ID for a date
  static String generateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DailyLog copyWith({
    String? id,
    DateTime? date,
    List<ConsumedProduct>? consumedProducts,
    double? waterIntake,
    String? notes,
  }) {
    return DailyLog(
      id: id ?? this.id,
      date: date ?? this.date,
      consumedProducts: consumedProducts ?? this.consumedProducts,
      waterIntake: waterIntake ?? this.waterIntake,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'consumedProducts': consumedProducts.map((p) => p.toJson()).toList(),
      'waterIntake': waterIntake,
      'notes': notes,
    };
  }

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date']),
      consumedProducts: (json['consumedProducts'] as List<dynamic>?)
              ?.map((e) => ConsumedProduct.fromJson(e))
              .toList() ??
          [],
      waterIntake: (json['waterIntake'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
}

@HiveType(typeId: 5)
class ConsumedProduct {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String barcode;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final double servingSize;

  @HiveField(4)
  final double calories;

  @HiveField(5)
  final double protein;

  @HiveField(6)
  final double carbs;

  @HiveField(7)
  final double fat;

  @HiveField(8)
  final DateTime consumedAt;

  @HiveField(9)
  final MealType mealType;

  @HiveField(10)
  final String? imageUrl;

  ConsumedProduct({
    required this.id,
    required this.barcode,
    required this.productName,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.consumedAt,
    required this.mealType,
    this.imageUrl,
  });

  ConsumedProduct copyWith({
    String? id,
    String? barcode,
    String? productName,
    double? servingSize,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? consumedAt,
    MealType? mealType,
    String? imageUrl,
  }) {
    return ConsumedProduct(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      consumedAt: consumedAt ?? this.consumedAt,
      mealType: mealType ?? this.mealType,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'productName': productName,
      'servingSize': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'consumedAt': consumedAt.toIso8601String(),
      'mealType': mealType.index,
      'imageUrl': imageUrl,
    };
  }

  factory ConsumedProduct.fromJson(Map<String, dynamic> json) {
    return ConsumedProduct(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      productName: json['productName'] as String,
      servingSize: (json['servingSize'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      consumedAt: DateTime.parse(json['consumedAt']),
      mealType: MealType.values[json['mealType'] as int],
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

@HiveType(typeId: 6)
enum MealType {
  @HiveField(0)
  breakfast,

  @HiveField(1)
  lunch,

  @HiveField(2)
  dinner,

  @HiveField(3)
  snack,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return 'breakfast_dining';
      case MealType.lunch:
        return 'lunch_dining';
      case MealType.dinner:
        return 'dinner_dining';
      case MealType.snack:
        return 'cookie';
    }
  }
}
