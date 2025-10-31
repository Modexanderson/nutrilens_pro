// lib/data/services/iap_service.dart
import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class IAPService {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();

  IAPService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs - must match App Store Connect EXACTLY
  static const String smallDonationId = 'donation_small';
  static const String mediumDonationId = 'donation_medium';
  static const String largeDonationId = 'donation_large';

  static const Set<String> _productIds = {
    smallDonationId,
    mediumDonationId,
    largeDonationId,
  };

  List<ProductDetails> _products = [];
  bool _available = false;
  bool _purchasePending = false;
  bool _isInitialized = false;

  bool get isAvailable => _available;
  bool get isPurchasePending => _purchasePending;
  List<ProductDetails> get products => _products;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('IAP already initialized');
      return;
    }

    try {
      // iOS-specific: Enable pending purchase handling
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosAddition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      // Check if IAP is available
      _available = await _inAppPurchase.isAvailable();
      print('IAP Available: $_available');

      if (!_available) {
        print('In-App Purchase not available on this device');
        _isInitialized = true;
        return;
      }

      // Listen to purchase updates BEFORE loading products
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => print('Purchase stream done'),
        onError: (error) => print('Purchase Stream Error: $error'),
      );

      // Load products
      await loadProducts();

      _isInitialized = true;
      print('✓ IAP initialization complete');
    } catch (e) {
      print('❌ IAP initialization error: $e');
      _available = false;
      _isInitialized = true;
    }
  }

  Future<void> loadProducts() async {
    if (!_available) {
      print('Cannot load products: IAP not available');
      return;
    }

    try {
      print('Querying products: $_productIds');

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        print('❌ Error loading products: ${response.error!.message}');
        print('Error code: ${response.error!.code}');
        _products = [];
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ Products not found: ${response.notFoundIDs}');
      }

      if (response.productDetails.isEmpty) {
        print('⚠️ No products loaded');
        _products = [];
        return;
      }

      _products = response.productDetails;
      print('✓ Loaded ${_products.length} products:');
      for (var product in _products) {
        print('  • ${product.id}: ${product.title} (${product.price})');
      }
    } catch (e) {
      print('❌ Exception loading products: $e');
      _products = [];
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (!_available) {
      throw Exception('In-app purchases are not available');
    }

    if (_purchasePending) {
      throw Exception('Another purchase is in progress');
    }

    _purchasePending = true;
    print('Starting purchase for: ${product.id}');

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      // CRITICAL: Use buyConsumable with autoConsume for donations
      // This means Apple handles everything - no server validation needed
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true, // AUTO-CONSUME = No server needed!
      );

      if (!success) {
        _purchasePending = false;
        throw Exception('Failed to initiate purchase');
      }

      print('✓ Purchase initiated successfully');
      return true;
    } catch (e) {
      print('❌ Purchase error: $e');
      _purchasePending = false;
      rethrow;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    print('📱 Purchase update: ${purchaseDetailsList.length} items');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print(
          'Status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          print('⏳ Purchase pending...');
          break;

        case PurchaseStatus.purchased:
          print('✓ Purchase successful: ${purchaseDetails.productID}');
          // For consumables with autoConsume=true, just mark as completed
          _purchasePending = false;
          break;

        case PurchaseStatus.restored:
          print('✓ Purchase restored: ${purchaseDetails.productID}');
          _purchasePending = false;
          break;

        case PurchaseStatus.error:
          print('❌ Purchase error: ${purchaseDetails.error?.message}');
          print('Error code: ${purchaseDetails.error?.code}');
          _purchasePending = false;
          break;

        case PurchaseStatus.canceled:
          print('🚫 Purchase canceled by user');
          _purchasePending = false;
          break;
      }

      // CRITICAL: Always complete the purchase
      // This tells Apple we've handled the transaction
      if (purchaseDetails.pendingCompletePurchase) {
        print('Completing purchase transaction...');
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) {
      throw Exception('In-app purchases are not available');
    }

    print('Restoring purchases...');
    try {
      await _inAppPurchase.restorePurchases();
      print('✓ Restore completed');
      // Note: Consumable donations cannot be restored
    } catch (e) {
      print('❌ Restore error: $e');
      rethrow;
    }
  }

  void dispose() {
    _subscription.cancel();
    _isInitialized = false;
  }
}

// Payment Queue Delegate for iOS
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

// REVENUE CAT FLOW

// // lib/data/services/iap_service.dart
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// class IAPService {
//   static IAPService? _instance;
//   static IAPService get instance => _instance ??= IAPService._();

//   IAPService._();

//   // TODO: Replace with your actual RevenueCat API Keys
//   // Get them from: https://app.revenuecat.com/
//   static const String _revenueCatApiKeyIOS = 'appl_ZJipwEgzfKCIPkWBLWRvLNhHVNE';
//   static const String _revenueCatApiKeyAndroid = 'goog_YOUR_ANDROID_KEY_HERE';

//   // Product IDs - must match App Store Connect AND RevenueCat Dashboard
//   static const String smallDonationId = 'donation_small';
//   static const String mediumDonationId = 'donation_medium';
//   static const String largeDonationId = 'donation_large';

//   List<StoreProduct> _products = [];
//   bool _isInitialized = false;
//   bool _isPurchasing = false;

//   bool get isInitialized => _isInitialized;
//   bool get isPurchasePending => _isPurchasing;
//   List<StoreProduct> get products => _products;
//   bool get isAvailable => _isInitialized && _products.isNotEmpty;

//   Future<void> initialize() async {
//     if (_isInitialized) {
//       print('RevenueCat already initialized');
//       return;
//     }

//     try {
//       print('🚀 Initializing RevenueCat...');

//       // Configure RevenueCat
//       final configuration = PurchasesConfiguration(
//         Platform.isIOS ? _revenueCatApiKeyIOS : _revenueCatApiKeyAndroid,
//       );

//       await Purchases.configure(configuration);

//       // Enable debug logs (remove in production)
//       await Purchases.setLogLevel(LogLevel.debug);

//       // Load products
//       await loadProducts();

//       _isInitialized = true;
//       print('✅ RevenueCat initialized successfully');
//     } catch (e) {
//       print('❌ RevenueCat initialization error: $e');
//       _isInitialized = false;
//     }
//   }

//   Future<void> loadProducts() async {
//     try {
//       print('📦 Loading products...');

//       // Get offerings from RevenueCat
//       final offerings = await Purchases.getOfferings();

//       if (offerings.current == null) {
//         print('⚠️ No current offering found');
//         _products = [];
//         return;
//       }

//       // Get all available products from the current offering
//       final currentOffering = offerings.current!;
//       _products = currentOffering.availablePackages
//           .map((package) => package.storeProduct)
//           .toList();

//       // Alternative: Get specific products by ID
//       // Uncomment if you want to fetch specific products only
//       /*
//       final productIds = [
//         smallDonationId,
//         mediumDonationId,
//         largeDonationId,
//       ];

//       final productList = await Purchases.getProducts(
//         productIds,
//         productCategory: ProductCategory.nonSubscription,
//       );
//       _products = productList;
//       */

//       if (_products.isEmpty) {
//         print('⚠️ No products loaded from offering');
//       } else {
//         print('✅ Loaded ${_products.length} products:');
//         for (var product in _products) {
//           print(
//               '  • ${product.identifier}: ${product.title} (${product.priceString})');
//         }
//       }
//     } catch (e) {
//       print('❌ Error loading products: $e');
//       _products = [];
//     }
//   }

//   Future<bool> buyProduct(StoreProduct product) async {
//     if (_isPurchasing) {
//       throw Exception('Another purchase is in progress');
//     }

//     _isPurchasing = true;
//     print('💳 Starting purchase for: ${product.identifier}');

//     try {
//       // Use the correct constructor name: storeProduct, not product
//       final purchaseParams = PurchaseParams.storeProduct(product);
//       final purchaseResult = await Purchases.purchase(purchaseParams);

//       // Check if purchase was successful
//       final customerInfo = purchaseResult.customerInfo;

//       print('✅ Purchase successful: ${product.identifier}');
//       print('Customer ID: ${customerInfo.originalAppUserId}');

//       _isPurchasing = false;
//       return true;
//     } on PlatformException catch (e) {
//       final errorCode = PurchasesErrorHelper.getErrorCode(e);

//       if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
//         print('🚫 Purchase cancelled by user');
//       } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
//         print('❌ Purchase not allowed');
//       } else {
//         print('❌ Purchase error: ${e.message}');
//       }

//       _isPurchasing = false;
//       rethrow;
//     } catch (e) {
//       print('❌ Unexpected purchase error: $e');
//       _isPurchasing = false;
//       rethrow;
//     }
//   }

//   Future<void> restorePurchases() async {
//     print('🔄 Restoring purchases...');

//     try {
//       final customerInfo = await Purchases.restorePurchases();

//       // Note: Consumable purchases (like donations) cannot be restored
//       // This is expected behavior for consumables
//       print('✅ Restore completed');
//       print('Customer ID: ${customerInfo.originalAppUserId}');
//     } catch (e) {
//       print('❌ Restore error: $e');
//       rethrow;
//     }
//   }

//   /// Get customer info (optional - for checking purchase history)
//   Future<CustomerInfo> getCustomerInfo() async {
//     try {
//       return await Purchases.getCustomerInfo();
//     } catch (e) {
//       print('❌ Error getting customer info: $e');
//       rethrow;
//     }
//   }

//   void dispose() {
//     _isInitialized = false;
//     _products = [];
//     print('🧹 RevenueCat service disposed');
//   }
// }
