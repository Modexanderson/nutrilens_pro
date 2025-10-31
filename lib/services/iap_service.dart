// lib/data/services/iap_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class IAPService {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();

  IAPService._();

  // TODO: Replace with your actual RevenueCat API Keys
  // Get them from: https://app.revenuecat.com/
  static const String _revenueCatApiKeyIOS = 'appl_YOUR_IOS_KEY_HERE';
  static const String _revenueCatApiKeyAndroid = 'goog_YOUR_ANDROID_KEY_HERE';

  // Product IDs - must match App Store Connect AND RevenueCat Dashboard
  static const String smallDonationId = 'donation_small';
  static const String mediumDonationId = 'donation_medium';
  static const String largeDonationId = 'donation_large';

  List<StoreProduct> _products = [];
  bool _isInitialized = false;
  bool _isPurchasing = false;

  bool get isInitialized => _isInitialized;
  bool get isPurchasePending => _isPurchasing;
  List<StoreProduct> get products => _products;
  bool get isAvailable => _isInitialized && _products.isNotEmpty;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('RevenueCat already initialized');
      return;
    }

    try {
      print('🚀 Initializing RevenueCat...');

      // Configure RevenueCat
      final configuration = PurchasesConfiguration(
        Platform.isIOS ? _revenueCatApiKeyIOS : _revenueCatApiKeyAndroid,
      );

      await Purchases.configure(configuration);

      // Enable debug logs (remove in production)
      await Purchases.setLogLevel(LogLevel.debug);

      // Load products
      await loadProducts();

      _isInitialized = true;
      print('✅ RevenueCat initialized successfully');
    } catch (e) {
      print('❌ RevenueCat initialization error: $e');
      _isInitialized = false;
    }
  }

  Future<void> loadProducts() async {
    try {
      print('📦 Loading products...');

      // Get offerings from RevenueCat
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        print('⚠️ No current offering found');
        _products = [];
        return;
      }

      // Get all available products from the current offering
      final currentOffering = offerings.current!;
      _products = currentOffering.availablePackages
          .map((package) => package.storeProduct)
          .toList();

      // Alternative: Get specific products by ID
      // Uncomment if you want to fetch specific products only
      /*
      final productIds = [
        smallDonationId,
        mediumDonationId,
        largeDonationId,
      ];
      
      final productList = await Purchases.getProducts(
        productIds,
        productCategory: ProductCategory.nonSubscription,
      );
      _products = productList;
      */

      if (_products.isEmpty) {
        print('⚠️ No products loaded from offering');
      } else {
        print('✅ Loaded ${_products.length} products:');
        for (var product in _products) {
          print(
              '  • ${product.identifier}: ${product.title} (${product.priceString})');
        }
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      _products = [];
    }
  }

  Future<bool> buyProduct(StoreProduct product) async {
    if (_isPurchasing) {
      throw Exception('Another purchase is in progress');
    }

    _isPurchasing = true;
    print('💳 Starting purchase for: ${product.identifier}');

    try {
      // Use the correct constructor name: storeProduct, not product
      final purchaseParams = PurchaseParams.storeProduct(product);
      final purchaseResult = await Purchases.purchase(purchaseParams);

      // Check if purchase was successful
      final customerInfo = purchaseResult.customerInfo;

      print('✅ Purchase successful: ${product.identifier}');
      print('Customer ID: ${customerInfo.originalAppUserId}');

      _isPurchasing = false;
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('🚫 Purchase cancelled by user');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        print('❌ Purchase not allowed');
      } else {
        print('❌ Purchase error: ${e.message}');
      }

      _isPurchasing = false;
      rethrow;
    } catch (e) {
      print('❌ Unexpected purchase error: $e');
      _isPurchasing = false;
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    print('🔄 Restoring purchases...');

    try {
      final customerInfo = await Purchases.restorePurchases();

      // Note: Consumable purchases (like donations) cannot be restored
      // This is expected behavior for consumables
      print('✅ Restore completed');
      print('Customer ID: ${customerInfo.originalAppUserId}');
    } catch (e) {
      print('❌ Restore error: $e');
      rethrow;
    }
  }

  /// Get customer info (optional - for checking purchase history)
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('❌ Error getting customer info: $e');
      rethrow;
    }
  }

  void dispose() {
    _isInitialized = false;
    _products = [];
    print('🧹 RevenueCat service disposed');
  }
}
