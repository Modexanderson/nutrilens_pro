// lib/data/services/iap_services.dart
import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();

  IAPService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // FIXED: Product IDs must match App Store Connect EXACTLY
  static const String smallDonationId =
      'donation_small'; // Matches App Store Connect
  static const String mediumDonationId =
      'donation_medium'; // Matches App Store Connect
  static const String largeDonationId =
      'donation_large'; // Matches App Store Connect

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
      // Check if IAP is available
      _available = await _inAppPurchase.isAvailable();
      print('IAP Available: $_available');

      if (!_available) {
        print('In-App Purchase not available on this device');
        return;
      }

      // Listen to purchase updates BEFORE loading products
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: () {
          print('Purchase stream done');
        },
        onError: (error) {
          print('Purchase Stream Error: $error');
        },
      );

      // Load products
      await loadProducts();

      _isInitialized = true;
      print('IAP initialization complete');
    } catch (e) {
      print('IAP initialization error: $e');
      _available = false;
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
        print('Error loading products: ${response.error!.message}');
        print('Error code: ${response.error!.code}');
        print('Error details: ${response.error!.details}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
        print('Make sure these product IDs are:');
        print('1. Created in App Store Connect');
        print('2. Approved (not in Draft status)');
        print('3. Available in your region');
      }

      if (response.productDetails.isEmpty) {
        print('No products found. Check:');
        print('- Product IDs match App Store Connect exactly');
        print('- Products are approved, not in Draft status');
        print('- Using StoreKit Configuration file for local testing');
        _products = [];
        return;
      }

      _products = response.productDetails;
      print('✓ Successfully loaded ${_products.length} products:');
      for (var product in _products) {
        print('  - ${product.id}: ${product.title} (${product.price})');
      }
    } catch (e) {
      print('Exception loading products: $e');
      _products = [];
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (!_available) {
      print('Cannot purchase: IAP not available');
      throw Exception('In-app purchases are not available');
    }

    if (_purchasePending) {
      print('Cannot purchase: Another purchase is pending');
      throw Exception('Another purchase is in progress');
    }

    _purchasePending = true;
    print('Starting purchase for: ${product.id}');

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!success) {
        print('Purchase initiation failed');
        _purchasePending = false;
        throw Exception('Failed to initiate purchase');
      }

      print('Purchase initiated successfully');
      return true;
    } catch (e) {
      print('Purchase error: $e');
      _purchasePending = false;
      rethrow;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    print('Purchase update received: ${purchaseDetailsList.length} items');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print(
          'Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
        print('Purchase pending...');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print('Purchase error: ${purchaseDetails.error?.message}');
          print('Error code: ${purchaseDetails.error?.code}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print('✓ Purchase successful: ${purchaseDetails.productID}');
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          print('✓ Purchase restored: ${purchaseDetails.productID}');
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          print('Purchase canceled by user');
        }

        if (purchaseDetails.pendingCompletePurchase) {
          print('Completing purchase...');
          _inAppPurchase.completePurchase(purchaseDetails);
        }

        _purchasePending = false;
      }
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) {
      print('Cannot restore: IAP not available');
      return;
    }

    print('Restoring purchases...');
    try {
      await _inAppPurchase.restorePurchases();
      print('Restore purchases completed');
    } catch (e) {
      print('Restore purchases error: $e');
    }
  }

  void dispose() {
    _subscription.cancel();
    _isInitialized = false;
  }
}
