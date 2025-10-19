// lib/data/models/product_model.dart

import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String barcode;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? brand;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final Nutriments? nutriments;

  @HiveField(5)
  final List<String>? ingredients;

  @HiveField(6)
  final List<String>? allergens;

  @HiveField(7)
  final String? nutriscore;

  @HiveField(8)
  final String? categories;

  @HiveField(9)
  final String? quantity;

  @HiveField(10)
  final DateTime scannedAt;

  @HiveField(11)
  bool isFavorite;

  Product({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.nutriments,
    this.ingredients,
    this.allergens,
    this.nutriscore,
    this.categories,
    this.quantity,
    DateTime? scannedAt,
    this.isFavorite = false,
  }) : scannedAt = scannedAt ?? DateTime.now();

  factory Product.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? json;

    return Product(
      barcode: product['code']?.toString() ?? product['_id']?.toString() ?? '',
      name: product['product_name'] ??
          product['product_name_en'] ??
          'Unknown Product',
      brand: product['brands'],
      imageUrl: product['image_url'] ?? product['image_front_url'],
      nutriments: product['nutriments'] != null
          ? Nutriments.fromJson(product['nutriments'])
          : null,
      ingredients: _parseIngredients(product['ingredients_text']),
      allergens: _parseAllergens(product['allergens_tags']),
      nutriscore: product['nutriscore_grade']?.toString().toUpperCase(),
      categories: product['categories'],
      quantity: product['quantity'],
    );
  }

  static List<String>? _parseIngredients(dynamic ingredientsText) {
    if (ingredientsText == null) return null;
    if (ingredientsText is String && ingredientsText.isNotEmpty) {
      return ingredientsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return null;
  }

  static List<String>? _parseAllergens(dynamic allergensTags) {
    if (allergensTags == null) return null;
    if (allergensTags is List) {
      return allergensTags
          .map((e) => e.toString().replaceAll('en:', '').replaceAll('-', ' '))
          .toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'nutriments': nutriments?.toJson(),
      'ingredients': ingredients,
      'allergens': allergens,
      'nutriscore': nutriscore,
      'categories': categories,
      'quantity': quantity,
      'scannedAt': scannedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  Product copyWith({
    String? barcode,
    String? name,
    String? brand,
    String? imageUrl,
    Nutriments? nutriments,
    List<String>? ingredients,
    List<String>? allergens,
    String? nutriscore,
    String? categories,
    String? quantity,
    DateTime? scannedAt,
    bool? isFavorite,
  }) {
    return Product(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      nutriments: nutriments ?? this.nutriments,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      nutriscore: nutriscore ?? this.nutriscore,
      categories: categories ?? this.categories,
      quantity: quantity ?? this.quantity,
      scannedAt: scannedAt ?? this.scannedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

@HiveType(typeId: 1)
class Nutriments {
  @HiveField(0)
  final double? energy;

  @HiveField(1)
  final double? proteins;

  @HiveField(2)
  final double? carbohydrates;

  @HiveField(3)
  final double? sugars;

  @HiveField(4)
  final double? fat;

  @HiveField(5)
  final double? saturatedFat;

  @HiveField(6)
  final double? fiber;

  @HiveField(7)
  final double? sodium;

  @HiveField(8)
  final double? salt;

  Nutriments({
    this.energy,
    this.proteins,
    this.carbohydrates,
    this.sugars,
    this.fat,
    this.saturatedFat,
    this.fiber,
    this.sodium,
    this.salt,
  });

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    return Nutriments(
      energy: _parseDouble(json['energy-kcal_100g'] ?? json['energy_100g']),
      proteins: _parseDouble(json['proteins_100g']),
      carbohydrates: _parseDouble(json['carbohydrates_100g']),
      sugars: _parseDouble(json['sugars_100g']),
      fat: _parseDouble(json['fat_100g']),
      saturatedFat: _parseDouble(json['saturated-fat_100g']),
      fiber: _parseDouble(json['fiber_100g']),
      sodium: _parseDouble(json['sodium_100g']),
      salt: _parseDouble(json['salt_100g']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'energy': energy,
      'proteins': proteins,
      'carbohydrates': carbohydrates,
      'sugars': sugars,
      'fat': fat,
      'saturatedFat': saturatedFat,
      'fiber': fiber,
      'sodium': sodium,
      'salt': salt,
    };
  }
}
