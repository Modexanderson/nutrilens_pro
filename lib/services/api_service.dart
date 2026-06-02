// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/product_model.dart';
import 'connectivity_service.dart';

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

  /// Check connectivity before making a request.
  /// Throws [NetworkException] if offline.
  Future<void> _ensureConnected() async {
    final connected = await ConnectivityService.instance.isConnected;
    if (!connected) {
      throw NetworkException('No internet connection. Please check your network settings.');
    }
  }

  /// Fetch product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    await _ensureConnected();

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
    } on DioException catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'API getProductByBarcode failed for barcode: $barcode',
      );
      throw NetworkException(_friendlyDioError(e));
    } catch (e, stack) {
      if (e is NetworkException) rethrow;
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Unexpected error in getProductByBarcode',
      );
      throw NetworkException('Something went wrong. Please try again.');
    }
  }

  /// Search products by name or category
  Future<List<Product>> searchProducts(String query, {int page = 1}) async {
    await _ensureConnected();

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
                // Skip malformed products silently
                return null;
              }
            })
            .whereType<Product>()
            .toList();
      }
      return [];
    } on DioException catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Search failed for query: $query, page: $page',
      );
      throw NetworkException(_friendlyDioError(e));
    } catch (e, stack) {
      if (e is NetworkException) rethrow;
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Unexpected search error',
      );
      throw NetworkException('Search failed. Please try again.');
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category,
      {int page = 1}) async {
    await _ensureConnected();

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
    } on DioException catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Category search failed: $category',
      );
      throw NetworkException(_friendlyDioError(e));
    } catch (e, stack) {
      if (e is NetworkException) rethrow;
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Unexpected category error',
      );
      throw NetworkException('Failed to load category. Please try again.');
    }
  }

  String _friendlyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet and try again.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Custom exception for network-related errors with user-friendly messages.
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}
