import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static final InAppPurchase _iap = InAppPurchase.instance;

  static const Set<String> _productIds = {
    'donate_099',
    'donate_199',
    'donate_499',
  };

  static Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);

    if (response.error != null) {
      throw Exception("Error loading products");
    }

    return response.productDetails;
  }

  static Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);

    await _iap.buyConsumable(purchaseParam: purchaseParam);
  }
}