import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();

  IAPService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs - Configure these in Google Play Console and App Store Connect
  static const String smallDonationId = 'donation_small'; // $0.99
  static const String mediumDonationId = 'donation_medium'; // $2.99
  static const String largeDonationId = 'donation_large'; // $4.99

  static const Set<String> _productIds = {
    smallDonationId,
    mediumDonationId,
    largeDonationId,
  };

  List<ProductDetails> _products = [];
  bool _available = false;
  bool _purchasePending = false;

  bool get isAvailable => _available;
  bool get isPurchasePending => _purchasePending;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    // Check if IAP is available
    _available = await _inAppPurchase.isAvailable();

    if (!_available) {
      print('In-App Purchase not available');
      return;
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Purchase Error: $error'),
    );

    // Load products
    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!_available) return;

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds);

    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return;
    }

    if (response.productDetails.isEmpty) {
      print('No products found');
      return;
    }

    _products = response.productDetails;
    print('Loaded ${_products.length} products');
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (!_available || _purchasePending) return;

    _purchasePending = true;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true, // Auto-consume for donations
      );
    } catch (e) {
      print('Purchase error: $e');
      _purchasePending = false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Donation successful
          print('Donation successful: ${purchaseDetails.productID}');
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }

        _purchasePending = false;
      }
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) return;
    await _inAppPurchase.restorePurchases();
  }

  void dispose() {
    _subscription.cancel();
  }
}
