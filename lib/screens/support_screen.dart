// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// import '../services/in_app_purchase_service.dart';
//
// class SupportScreen extends StatefulWidget {
//   const SupportScreen({super.key});
//
//   @override
//   State<SupportScreen> createState() =>
//       _SupportScreenState();
// }
//
// class _SupportScreenState extends State<SupportScreen> {
//   final InAppPurchaseService _purchaseService =
//       InAppPurchaseService.instance;
//
//   bool _loading = true;
//   bool _purchasing = false;
//
//   String? _purchasingProductId;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePurchases();
//   }
//
//   Future<void> _initializePurchases() async {
//     await _purchaseService.initialize(
//       onPurchaseCompleted: _purchaseCompleted,
//       onError: _purchaseError,
//     );
//
//     // Reload so the screen always gets the latest
//     // App Store / Google Play product information.
//     await _purchaseService.loadProducts();
//
//     if (!mounted) return;
//
//     setState(() {
//       _loading = false;
//     });
//   }
//
//   void _purchaseCompleted(
//       PurchaseDetails purchase,
//       ) {
//     if (!mounted) return;
//
//     setState(() {
//       _purchasing = false;
//       _purchasingProductId = null;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Thank you for supporting the app! ❤️',
//         ),
//       ),
//     );
//   }
//
//   void _purchaseError(String message) {
//     if (!mounted) return;
//
//     setState(() {
//       _purchasing = false;
//       _purchasingProductId = null;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }
//
//   Future<void> _buy(
//       ProductDetails product,
//       ) async {
//     if (_purchasing) return;
//
//     setState(() {
//       _purchasing = true;
//       _purchasingProductId = product.id;
//     });
//
//     final started =
//     await _purchaseService.buySupport(product);
//
//     if (!started && mounted) {
//       setState(() {
//         _purchasing = false;
//         _purchasingProductId = null;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Unable to start the purchase.',
//           ),
//         ),
//       );
//     }
//   }
//
//   Future<void> _refreshProducts() async {
//     setState(() {
//       _loading = true;
//     });
//
//     await _purchaseService.loadProducts();
//
//     if (!mounted) return;
//
//     setState(() {
//       _loading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: const Text('Support the App'),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         foregroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: _loading
//             ? const Center(
//           child: CircularProgressIndicator(),
//         )
//             : _buildContent(),
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     if (!_purchaseService.storeAvailable) {
//       return _buildUnavailable();
//     }
//
//     if (_purchaseService.products.isEmpty) {
//       return _buildNoProducts();
//     }
//
//     final small = _purchaseService.getProduct(
//       InAppPurchaseService.supportSmall,
//     );
//
//     final medium = _purchaseService.getProduct(
//       InAppPurchaseService.supportMedium,
//     );
//
//     final large = _purchaseService.getProduct(
//       InAppPurchaseService.supportLarge,
//     );
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           const SizedBox(height: 10),
//
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               color: Colors.teal.withOpacity(0.10),
//               shape: BoxShape.circle,
//             ),
//             child: const Center(
//               child: Text(
//                 '❤️',
//                 style: TextStyle(
//                   fontSize: 50,
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 22),
//
//           const Text(
//             'Support the App',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           Text(
//             'If you enjoy using the app, you can '
//                 'support its continued development '
//                 'and maintenance.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 15,
//               height: 1.5,
//               color: Colors.grey.shade700,
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           Text(
//             'Support is completely optional.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade600,
//             ),
//           ),
//
//           const SizedBox(height: 28),
//
//           if (small != null)
//             _supportCard(
//               product: small,
//               title: 'Small Support',
//               icon: '☕',
//             ),
//
//           if (medium != null)
//             _supportCard(
//               product: medium,
//               title: 'Medium Support',
//               icon: '💚',
//             ),
//
//           if (large != null)
//             _supportCard(
//               product: large,
//               title: 'Large Support',
//               icon: '⭐',
//             ),
//
//           const SizedBox(height: 18),
//
//           Text(
//             'Thank you for helping us continue '
//                 'improving the app. ❤️',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13,
//               height: 1.4,
//               color: Colors.grey.shade600,
//             ),
//           ),
//
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _supportCard({
//     required ProductDetails product,
//     required String title,
//     required String icon,
//   }) {
//     final isThisPurchasing =
//         _purchasing &&
//             _purchasingProductId == product.id;
//
//     return Container(
//       margin: const EdgeInsets.only(
//         bottom: 14,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: _purchasing
//               ? null
//               : () => _buy(product),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 18,
//               vertical: 18,
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color:
//                     Colors.teal.withOpacity(0.08),
//                     borderRadius:
//                     BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     icon,
//                     style: const TextStyle(
//                       fontSize: 25,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(width: 14),
//
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//
//                 if (isThisPurchasing)
//                   const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.5,
//                     ),
//                   )
//                 else
//                   Text(
//                     product.price,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUnavailable() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment:
//           MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.store_outlined,
//               size: 65,
//               color: Colors.grey,
//             ),
//
//             const SizedBox(height: 18),
//
//             const Text(
//               'Support is currently unavailable.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 18),
//
//             ElevatedButton.icon(
//               onPressed: _refreshProducts,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoProducts() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment:
//           MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.favorite_border,
//               size: 65,
//               color: Colors.teal,
//             ),
//
//             const SizedBox(height: 18),
//
//             const Text(
//               'Support options are not available '
//                   'right now.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 18),
//
//             ElevatedButton.icon(
//               onPressed: _refreshProducts,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }