// lib/data/services/api_services.dart

import 'package:dio/dio.dart';
import '../models/product_model.dart';

/// Open Food Facts API Service
/// Free, open-source food database with millions of products
/// API Documentation: https://world.openfoodfacts.org/data
class ApiService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String searchUrl =
      'https://world.openfoodfacts.org/cgi/search.pl';

  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'User-Agent': 'NutriLens Pro - Flutter App',
              'Content-Type': 'application/json',
            },
          ),
        );

  /// Fetch product by barcode
  /// Example: GET /api/v2/product/3017620422003
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        '$baseUrl/product/$barcode',
        queryParameters: {
          'fields': [
            'code',
            'product_name',
            'product_name_en',
            'brands',
            'image_url',
            'image_front_url',
            'nutriments',
            'ingredients_text',
            'allergens_tags',
            'nutriscore_grade',
            'categories',
            'quantity',
          ].join(','),
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        return Product.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected Error: $e');
      return null;
    }
  }

  /// Search products by name or category
  /// Example: GET /cgi/search.pl?search_terms=pizza&json=true
  Future<List<Product>> searchProducts(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        searchUrl,
        queryParameters: {
          'search_terms': query,
          'page': page,
          'page_size': 20,
          'json': true,
          'fields': [
            'code',
            'product_name',
            'brands',
            'image_url',
            'nutriments',
            'nutriscore_grade',
          ].join(','),
        },
      );

      if (response.statusCode == 200 && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson
            .map((json) {
              try {
                return Product.fromJson(json);
              } catch (e) {
                print('Error parsing product: $e');
                return null;
              }
            })
            .whereType<Product>()
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Search Error: ${e.message}');
      return [];
    } catch (e) {
      print('Unexpected Search Error: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category,
      {int page = 1}) async {
    try {
      final response = await _dio.get(
        searchUrl,
        queryParameters: {
          'tagtype_0': 'categories',
          'tag_contains_0': 'contains',
          'tag_0': category,
          'page': page,
          'page_size': 20,
          'json': true,
          'fields': [
            'code',
            'product_name',
            'brands',
            'image_url',
            'nutriments',
            'nutriscore_grade',
          ].join(','),
        },
      );

      if (response.statusCode == 200 && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson
            .map((json) {
              try {
                return Product.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<Product>()
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Category Error: ${e.message}');
      return [];
    } catch (e) {
      print('Unexpected Category Error: $e');
      return [];
    }
  }
}
