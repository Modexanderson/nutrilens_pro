// lib/services/iap_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
    if (_isInitialized) return;

    try {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosAddition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      _available = await _inAppPurchase.isAvailable();

      if (!_available) {
        _isInitialized = true;
        return;
      }

      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => debugPrint('Purchase stream done'),
        onError: (error) {
          FirebaseCrashlytics.instance.log('Purchase stream error: $error');
        },
      );

      await loadProducts();
      _isInitialized = true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'IAP initialization failed',
      );
      _available = false;
      _isInitialized = true;
    }
  }

  Future<void> loadProducts() async {
    if (!_available) return;

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        FirebaseCrashlytics.instance.log(
          'IAP product load error: ${response.error!.message}',
        );
        _products = [];
        return;
      }

      if (response.productDetails.isEmpty) {
        _products = [];
        return;
      }

      _products = response.productDetails;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'Failed to load IAP products',
      );
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

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!success) {
        _purchasePending = false;
        throw Exception('Failed to initiate purchase');
      }

      return true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'Purchase failed for: ${product.id}',
      );
      _purchasePending = false;
      rethrow;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          break;

        case PurchaseStatus.purchased:
          _purchasePending = false;
          break;

        case PurchaseStatus.restored:
          _purchasePending = false;
          break;

        case PurchaseStatus.error:
          FirebaseCrashlytics.instance.log(
            'Purchase error: ${purchaseDetails.error?.message}',
          );
          _purchasePending = false;
          break;

        case PurchaseStatus.canceled:
          _purchasePending = false;
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) {
      throw Exception('In-app purchases are not available');
    }

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'Restore purchases failed',
      );
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
