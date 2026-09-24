// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// class InAppPurchaseService {
//   InAppPurchaseService._();
//
//   static final InAppPurchaseService instance =
//   InAppPurchaseService._();
//
//   final InAppPurchase _inAppPurchase =
//       InAppPurchase.instance;
//
//   static const String supportSmall = 'support_small';
//   static const String supportMedium = 'support_medium';
//   static const String supportLarge = 'support_large';
//
//   static const Set<String> productIds = {
//     supportSmall,
//     supportMedium,
//     supportLarge,
//   };
//
//   StreamSubscription<List<PurchaseDetails>>?
//   _purchaseSubscription;
//
//   List<ProductDetails> _products = [];
//
//   List<ProductDetails> get products =>
//       List.unmodifiable(_products);
//
//   bool _storeAvailable = false;
//
//   bool get storeAvailable => _storeAvailable;
//
//   bool _initialized = false;
//
//   Future<void> initialize({
//     void Function(PurchaseDetails purchase)?
//     onPurchaseCompleted,
//     void Function(String message)? onError,
//   }) async {
//     if (_initialized) {
//       return;
//     }
//
//     _initialized = true;
//
//     _purchaseSubscription =
//         _inAppPurchase.purchaseStream.listen(
//               (purchaseDetailsList) {
//             _handlePurchaseUpdates(
//               purchaseDetailsList,
//               onPurchaseCompleted: onPurchaseCompleted,
//               onError: onError,
//             );
//           },
//           onDone: () {
//             _purchaseSubscription?.cancel();
//           },
//           onError: (Object error) {
//             debugPrint(
//               '❌ Purchase stream error: $error',
//             );
//
//             onError?.call(
//               'A purchase error occurred.',
//             );
//           },
//         );
//
//     await loadProducts();
//   }
//
//   Future<void> loadProducts() async {
//     try {
//       _storeAvailable =
//       await _inAppPurchase.isAvailable();
//
//       if (!_storeAvailable) {
//         debugPrint(
//           '❌ In-app purchases are not available.',
//         );
//         _products = [];
//         return;
//       }
//
//       final ProductDetailsResponse response =
//       await _inAppPurchase.queryProductDetails(
//         productIds,
//       );
//
//       if (response.error != null) {
//         debugPrint(
//           '❌ Product query error: '
//               '${response.error}',
//         );
//       }
//
//       if (response.notFoundIDs.isNotEmpty) {
//         debugPrint(
//           '⚠️ Products not found: '
//               '${response.notFoundIDs}',
//         );
//       }
//
//       _products = response.productDetails;
//
//       _products.sort(
//             (a, b) =>
//             a.rawPrice.compareTo(b.rawPrice),
//       );
//
//       for (final product in _products) {
//         debugPrint(
//           '✅ IAP product: '
//               '${product.id} | ${product.price}',
//         );
//       }
//     } catch (e) {
//       debugPrint(
//         '❌ Error loading IAP products: $e',
//       );
//
//       _products = [];
//     }
//   }
//
//   ProductDetails? getProduct(
//       String productId,
//       ) {
//     try {
//       return _products.firstWhere(
//             (product) => product.id == productId,
//       );
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<bool> buySupport(
//       ProductDetails product,
//       ) async {
//     try {
//       final PurchaseParam purchaseParam =
//       PurchaseParam(
//         productDetails: product,
//       );
//
//       // Our support products are consumable.
//       return await _inAppPurchase.buyConsumable(
//         purchaseParam: purchaseParam,
//         autoConsume: true,
//       );
//     } catch (e) {
//       debugPrint(
//         '❌ Error starting purchase: $e',
//       );
//
//       return false;
//     }
//   }
//
//   Future<void> _handlePurchaseUpdates(
//       List<PurchaseDetails> purchases, {
//         void Function(PurchaseDetails purchase)?
//         onPurchaseCompleted,
//         void Function(String message)? onError,
//       }) async {
//     for (final purchase in purchases) {
//       if (purchase.status ==
//           PurchaseStatus.pending) {
//         debugPrint(
//           '⏳ Purchase pending: '
//               '${purchase.productID}',
//         );
//       }
//
//       if (purchase.status ==
//           PurchaseStatus.error) {
//         debugPrint(
//           '❌ Purchase failed: '
//               '${purchase.error}',
//         );
//
//         onError?.call(
//           purchase.error?.message ??
//               'Purchase failed.',
//         );
//       }
//
//       if (purchase.status ==
//           PurchaseStatus.purchased) {
//         debugPrint(
//           '✅ Purchase completed: '
//               '${purchase.productID}',
//         );
//
//         onPurchaseCompleted?.call(
//           purchase,
//         );
//       }
//
//       if (purchase.status ==
//           PurchaseStatus.restored) {
//         debugPrint(
//           '✅ Purchase restored: '
//               '${purchase.productID}',
//         );
//       }
//
//       if (purchase.pendingCompletePurchase) {
//         try {
//           await _inAppPurchase
//               .completePurchase(purchase);
//
//           debugPrint(
//             '✅ Purchase finalized: '
//                 '${purchase.productID}',
//           );
//         } catch (e) {
//           debugPrint(
//             '❌ Could not finalize purchase: $e',
//           );
//         }
//       }
//     }
//   }
//
//   Future<void> dispose() async {
//     await _purchaseSubscription?.cancel();
//     _purchaseSubscription = null;
//     _initialized = false;
//   }
// }