// lib/models/user_profile_model.dart

import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 2)
class UserProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> allergensToAvoid;

  @HiveField(3)
  final List<String> dietaryRestrictions;

  @HiveField(4)
  final NutritionGoals nutritionGoals;

  @HiveField(5)
  final bool onboardingCompleted;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.name = '',
    List<String>? allergensToAvoid,
    List<String>? dietaryRestrictions,
    NutritionGoals? nutritionGoals,
    this.onboardingCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : allergensToAvoid = allergensToAvoid ?? [],
        dietaryRestrictions = dietaryRestrictions ?? [],
        nutritionGoals = nutritionGoals ?? NutritionGoals(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? name,
    List<String>? allergensToAvoid,
    List<String>? dietaryRestrictions,
    NutritionGoals? nutritionGoals,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      allergensToAvoid: allergensToAvoid ?? this.allergensToAvoid,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'allergensToAvoid': allergensToAvoid,
      'dietaryRestrictions': dietaryRestrictions,
      'nutritionGoals': nutritionGoals.toJson(),
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      allergensToAvoid: (json['allergensToAvoid'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      nutritionGoals: json['nutritionGoals'] != null
          ? NutritionGoals.fromJson(json['nutritionGoals'])
          : NutritionGoals(),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

@HiveType(typeId: 3)
class NutritionGoals {
  @HiveField(0)
  final double dailyCalories;

  @HiveField(1)
  final double dailyProtein;

  @HiveField(2)
  final double dailyCarbs;

  @HiveField(3)
  final double dailyFat;

  @HiveField(4)
  final double dailyFiber;

  @HiveField(5)
  final double dailySodium;

  NutritionGoals({
    this.dailyCalories = 2000,
    this.dailyProtein = 50,
    this.dailyCarbs = 250,
    this.dailyFat = 65,
    this.dailyFiber = 25,
    this.dailySodium = 2300,
  });

  NutritionGoals copyWith({
    double? dailyCalories,
    double? dailyProtein,
    double? dailyCarbs,
    double? dailyFat,
    double? dailyFiber,
    double? dailySodium,
  }) {
    return NutritionGoals(
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProtein: dailyProtein ?? this.dailyProtein,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      dailyFat: dailyFat ?? this.dailyFat,
      dailyFiber: dailyFiber ?? this.dailyFiber,
      dailySodium: dailySodium ?? this.dailySodium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyCalories': dailyCalories,
      'dailyProtein': dailyProtein,
      'dailyCarbs': dailyCarbs,
      'dailyFat': dailyFat,
      'dailyFiber': dailyFiber,
      'dailySodium': dailySodium,
    };
  }

  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      dailyCalories: (json['dailyCalories'] as num?)?.toDouble() ?? 2000,
      dailyProtein: (json['dailyProtein'] as num?)?.toDouble() ?? 50,
      dailyCarbs: (json['dailyCarbs'] as num?)?.toDouble() ?? 250,
      dailyFat: (json['dailyFat'] as num?)?.toDouble() ?? 65,
      dailyFiber: (json['dailyFiber'] as num?)?.toDouble() ?? 25,
      dailySodium: (json['dailySodium'] as num?)?.toDouble() ?? 2300,
    );
  }
}

// Common allergens list for convenience
class CommonAllergens {
  static const List<String> all = [
    'Milk',
    'Eggs',
    'Fish',
    'Shellfish',
    'Tree nuts',
    'Peanuts',
    'Wheat',
    'Soybeans',
    'Sesame',
    'Gluten',
    'Mustard',
    'Celery',
    'Lupin',
    'Molluscs',
    'Sulphites',
  ];
}

// Common dietary restrictions
class DietaryRestrictions {
  static const List<String> all = [
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'Keto',
    'Paleo',
    'Low-carb',
    'Low-fat',
    'Low-sodium',
    'Gluten-free',
    'Dairy-free',
    'Halal',
    'Kosher',
  ];
}
