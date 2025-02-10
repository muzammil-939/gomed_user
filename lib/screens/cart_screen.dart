import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/model/product.dart';
import "package:gomed_user/screens/products_screen.dart";

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends ConsumerState<CartScreen> {
  List<String> cartProductIds = [];
  List<Data> cartProducts = [];
  List<String> selectedProductIds = []; // Track selected products
  Map<String, int> productQuantities = {}; // To track quantity for each product

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartProductIds = prefs.getStringList('cartItems') ?? [];

    final productState = ref.watch(productProvider);
    if (productState.data != null) {
      cartProducts = productState.data!
          .where((product) => cartProductIds.contains(product.productId))
          .toList();
    }

    // Select all available products by default
    selectedProductIds = cartProducts.where((p) => p.spareParts ?? true).map((p) => p.productId!).toList();

    setState(() {});
    

  }

  @override
  Widget build(BuildContext context) {
    double totalMRP = cartProducts
        .where((product) => selectedProductIds.contains(product.productId))
        .fold(0, (sum, product) => sum + (product.price ?? 0));

    double discountMRP = 300; // Static discount
    double platformFee = 20;  // Static platform fee
    double totalAmount = totalMRP - discountMRP + platformFee;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1BA4CA),
        title: const Text("CART"),
      ),
      body: SafeArea(
        child: cartProducts.isEmpty
            ? const Center(
                child: Text(
                  "Your cart is empty!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : Column(
                children: [
                  _buildSavingsBanner(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: cartProducts.map((product) => _buildCartItem(product)).toList(),
                      ),
                    ),
                  ),
                  PriceDetails(
                    totalMRP: totalMRP,
                    discountMRP: discountMRP,
                    platformFee: platformFee,
                    totalAmount: totalAmount,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: selectedProductIds.isNotEmpty
                          ? () {
                              _proceedToBuy();
                            }
                          : null, // Disable if no item is selected
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSavingsBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.green[100],
      child: const Text(
        "You're Saving 33% On This Order",
        style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCartItem(Data product) {
    bool isSelected = selectedProductIds.contains(product.productId!);
    bool isAvailable = product.spareParts ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: isAvailable
                      ? (value) {
                          setState(() {
                            if (value!) {
                              selectedProductIds.add(product.productId!);
                            } else {
                              selectedProductIds.remove(product.productId!);
                            }
                          });
                        }
                      : null,
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: product.productImage != null
                        ? DecorationImage(
                            image: NetworkImage("http://97.74.93.26:3000/${product.productImage}"),
                            fit: BoxFit.cover)
                        : null,
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.productName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(product.productDescription ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                      const Text("Size: mid", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      const Text("Qty: 2", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      Row(
                        children: [
                          const Text("33% ", style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
                          const Text("₹2245", style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.black45)),
                          const SizedBox(width: 5),
                          Text("₹${product.price}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (isAvailable)
                        const Text("✔ Available", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      if (!isAvailable)
                        const Text("❌ Out of Stock", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await _removeFromCart(product.productId!);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.black54),
                  label: const Text("Remove", style: TextStyle(color: Colors.black54)),
                ),
                if (isAvailable)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                    label: const Text("Buy Now", style: TextStyle(color: Colors.blue)),
                  ),
                if (!isAvailable)
                  TextButton(
                    onPressed: () {},
                    child: const Text("Find Similar", style: TextStyle(color: Colors.blue)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFromCart(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartProductIds.remove(productId);
    await prefs.setStringList('cartItems', cartProductIds);
    // Show SnackBar message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Item removed from cart",
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red, // Set background color to red
      ),
    );
    _loadCartItems();
  }

  void _proceedToBuy() {
    List<Data> selectedProducts = cartProducts.where((product) => selectedProductIds.contains(product.productId!)).toList();
    print("Proceeding to buy: ${selectedProducts.map((p) => p.productName).toList()}");
  }
}

class PriceDetails extends StatelessWidget {
  final double totalMRP;
  final double discountMRP;
  final double platformFee;
  final double totalAmount;

  const PriceDetails({required this.totalMRP, required this.discountMRP, required this.platformFee, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildRow("Total MRP:", "₹${totalMRP.toStringAsFixed(2)}"),
            _buildRow("Discount MRP:", "- ₹${discountMRP.toStringAsFixed(2)}"),
            _buildRow("Platform Fee:", "₹${platformFee.toStringAsFixed(2)}"),
            _buildRow("Total Amount:", "₹${totalAmount.toStringAsFixed(2)}", isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool isBold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    ]);
  }
}


















































// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gomed_user/providers/products.dart';
// import 'package:gomed_user/model/product.dart';

// class CartScreen extends ConsumerStatefulWidget {
//   const CartScreen({super.key});

//   @override
//   ConsumerState<CartScreen> createState() => CartScreenState();
// }

// class CartScreenState extends ConsumerState<CartScreen> {
//   List<String> cartProductIds = [];
//   List<Data> cartProducts = [];
//   Map<String, int> productQuantities = {}; // To track quantity for each product

//   @override
//   void initState() {
//     super.initState();
//     _loadCartItems();
//   }

//   Future<void> _loadCartItems() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     cartProductIds = prefs.getStringList('cartItems') ?? [];

//     final productState = ref.watch(productProvider);
//     if (productState.data != null) {
//       cartProducts = productState.data!
//           .where((product) => cartProductIds.contains(product.productId))
//           .toList();
//     }

//     // Set default quantity to 1 for each item
//     for (var product in cartProducts) {
//       productQuantities[product.productId!] = productQuantities[product.productId!] ?? 1;
//     }

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     double totalMRP = cartProducts.fold(0, (sum, product) {
//       int quantity = productQuantities[product.productId!] ?? 1;
//       return sum + (product.price ?? 0) * quantity;
//     });

//     double discountMRP = 860; // Static discount
//     double platformFee = 20;  // Static platform fee
//     double totalAmount = totalMRP - discountMRP + platformFee;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1BA4CA),
//         title: const Text("CART"),
//       ),
//       body: SafeArea(
//         child: cartProducts.isEmpty
//             ? const Center(
//                 child: Text(
//                   "Your cart is empty!",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               )
//             : Column(
//                 children: [
//                   _buildSavingsBanner(),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: cartProducts.map((product) => _buildCartItem(product)).toList(),
//                       ),
//                     ),
//                   ),
//                   PriceDetails(
//                     totalMRP: totalMRP,
//                     discountMRP: discountMRP,
//                     platformFee: platformFee,
//                     totalAmount: totalAmount,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: ElevatedButton(
//                       onPressed: cartProducts.isNotEmpty
//                           ? () {
//                               _proceedToBuy();
//                             }
//                           : null, // Disable if cart is empty
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         minimumSize: const Size(double.infinity, 50),
//                       ),
//                       child: const Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildSavingsBanner() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       color: Colors.green[100],
//       child: const Text(
//         "You're Saving ₹860 On This Order",
//         style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildCartItem(Data product) {
//     int quantity = productQuantities[product.productId!] ?? 1;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     image: product.productImage != null
//                         ? DecorationImage(
//                             image: NetworkImage("http://97.74.93.26:3000/${product.productImage}"),
//                             fit: BoxFit.cover)
//                         : null,
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(product.productName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
//                       Text("Size: 90-100gm", style: const TextStyle(fontSize: 14, color: Colors.black54)),
//                       Row(
//                         children: [
//                           Text("₹${product.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//                           const SizedBox(width: 5),
//                           Text(" x $quantity", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       const SizedBox(height: 5),
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
//                             onPressed: () {
//                               if (quantity > 1) {
//                                 setState(() {
//                                   productQuantities[product.productId!] = quantity - 1;
//                                 });
//                               }
//                             },
//                           ),
//                           Text("$quantity", style: const TextStyle(fontSize: 16)),
//                           IconButton(
//                             icon: const Icon(Icons.add_circle_outline, color: Colors.green),
//                             onPressed: () {
//                               setState(() {
//                                 productQuantities[product.productId!] = quantity + 1;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () async {
//                     await _removeFromCart(product.productId!);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _removeFromCart(String productId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     cartProductIds.remove(productId);
//     await prefs.setStringList('cartItems', cartProductIds);
//     setState(() {
//       cartProducts.removeWhere((product) => product.productId == productId);
//     });

//     // Show SnackBar message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Item removed from cart"),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _proceedToBuy() {
//     print("Proceeding to buy with selected products.");
//   }
// }

// class PriceDetails extends StatelessWidget {
//   final double totalMRP;
//   final double discountMRP;
//   final double platformFee;
//   final double totalAmount;

//   const PriceDetails({
//     required this.totalMRP,
//     required this.discountMRP,
//     required this.platformFee,
//     required this.totalAmount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Padding(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           children: [
//             _buildRow("Total MRP:", "₹$totalMRP"),
//             _buildRow("Discount MRP:", "- ₹$discountMRP"),
//             _buildRow("Platform Fee:", "₹$platformFee"),
//             _buildRow("Total Amount:", "₹$totalAmount", isBold: true),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRow(String title, String value, {bool isBold = false}) {
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//       Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//     ]);
//   }
// }

