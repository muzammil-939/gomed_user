import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/providers/addbooking_provider.dart';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/providers/getproduct_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/model/product.dart';
import "package:gomed_user/screens/products_screen.dart";
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';


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
  Map<String, bool> productSelections = {}; // Store selection state for each product
   String? add1 ;
  String? add2 ;
    double? latitude;
  double? longitude;
  String? userid;
  String locationAddress = "Fetching location...";
  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _loadAddress();
  }
 
  Future<void> _loadAddress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Fetch user data from API provider
   var userState = ref.watch(userProvider);

  // ignore: unnecessary_null_comparison
  if ( userState!= null) {
    final user = userState.data![0].user; // Assuming user data is fetched
    setState(() {
      userid = userState.data![0].user!.sId;
      add1 = user!.address ?? prefs.getString('add1') ?? "No Address";
       latitude = double.tryParse(user.location?.latitude ?? "");
        longitude = double.tryParse(user.location?.longitude ?? "");
    });
    print('deatils.....$add1,$latitude,$longitude,$userid');
    

     if (latitude != null && longitude != null) {
        _getAddressFromCoordinates(latitude!, longitude!);
      }
  } else {
    setState(() {
      add1 = prefs.getString('add1') ?? "No Address";
    });
  }
}
 Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          locationAddress = "${place.street}, ${place.locality}, ${place.country}";
          print('location details....${place.street}, ${place.locality}, ${place.country}');
        });
      }
    } catch (e) {
      setState(() {
        locationAddress = "Could not fetch location";
      });
    }
  }


 
Future<void> _changeAddress(BuildContext context) async {
  TextEditingController add1Controller = TextEditingController(text: add1);
  TextEditingController add2Controller = TextEditingController(text: add2);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Change Address"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: add1Controller,
              decoration: InputDecoration(labelText: "Address Line 1"),
            ),
            SizedBox(height: 10),
            GooglePlaceAutoCompleteTextField(
              textEditingController: add2Controller,
              googleAPIKey: "AIzaSyCMADwyS3eoxJ5dQ_iFiWcDBA_tJwoZosw", // Replace with your API Key
              inputDecoration: InputDecoration(labelText: "Search Location"),
              debounceTime: 400,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (prediction) async {
                print("Latitude: ${prediction.lat}, Longitude: ${prediction.lng}");

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('latitude', prediction.lat.toString());
                await prefs.setString('longitude', prediction.lng.toString());

                setState(() {
                  latitude = double.tryParse(prediction.lat.toString());
                  longitude = double.tryParse(prediction.lng.toString());
                  add2 = prediction.description;
                });

                _getAddressFromCoordinates(latitude!, longitude!);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('add1', add1Controller.text.trim());
              await prefs.setString('add2', add2Controller.text.trim());

              setState(() {
                add1 = add1Controller.text.trim();
                add2 = add2Controller.text.trim();
              });

              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}
  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartProductIds = prefs.getStringList('cartItems') ?? [];
print('cart product ids---${cartProductIds.length}');
    final productState = ref.watch(productProvider);
    if (productState.data != null) {
      cartProducts = productState.data!
          .where((product) => cartProductIds.contains(product.productId))
          .toList();
    }
print('product data--${cartProducts.length}');
    
  // Initialize selections and quantities
    for (var product in cartProducts) {
      productSelections[product.productId!] = prefs.getBool('selected_${product.productId}') ?? true; // Load saved selection or default to true
      productQuantities[product.productId!] = prefs.getInt('quantity_${product.productId}') ?? 1; // Load saved quantity or default to 1
    }
selectedProductIds = productSelections.entries
    .where((entry) => entry.value == true)
    .map((entry) => entry.key)
    .toList();

setState(() {});

   // setState(() {});
  // final productState = ref.read(productProvider);

  // productState.when(
  //   data: (List<ProductModel> productModels) {
  //     // Extract the `data` field from each `ProductModel`
  //     List<Data> allProducts = productModels
  //   .expand((model) => model.data != null ? model.data! as List<Data> : <Data>[])
  //   .toList();


  //     // Filter products that exist in the cart
  //     cartProducts = allProducts
  //         .where((product) => cartProductIds.contains(product.productId))
  //         .toList();

  //     // Initialize selections and quantities
  //     for (var product in cartProducts) {
  //       productSelections[product.productId!] = prefs.getBool('selected_${product.productId}') ?? true;
  //       productQuantities[product.productId!] = prefs.getInt('quantity_${product.productId}') ?? 1;
  //     }

  //     setState(() {}); // Update UI after data is loaded
  //   },
  //   loading: () {
  //     print("Loading products...");
  //   },
  //   error: (error, stackTrace) {
  //     print("Error loading products: $error");
  //   },
  // );

  }


  Future<void> _saveSelection(String productId, bool isSelected) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('selected_$productId', isSelected);
    setState(() {
      productSelections[productId] = isSelected;
      // Update the selectedProductIds list
    if (isSelected) {
      if (!selectedProductIds.contains(productId)) {
        selectedProductIds.add(productId);
      }
    } else {
      selectedProductIds.remove(productId);
    }
    });
  }

  Future<void> _saveQuantity(String productId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quantity_$productId', quantity);
    setState(() {
      productQuantities[productId] = quantity;
    });
  }

Future<void> _proceedToBuy() async {
  try {
    List<Data> selectedProducts = cartProducts
        .where((product) => product.productId != null && 
                            productSelections[product.productId!] == true &&
                            (product.spareParts ?? true))
        .toList();

    if (selectedProducts.isEmpty) {
      print("❌ No products selected for booking.");
      return;
    }

    // Count booked products
    int bookedCount = selectedProducts.length;

    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString == null || userDataString.isEmpty) {
      throw Exception("User data is missing.");
    }

    List<String> productIds = selectedProducts.map((p) => p.productId.toString()).toList();

    double? lat = latitude ?? double.tryParse(prefs.getString('latitude') ?? '');
    double? lng = longitude ?? double.tryParse(prefs.getString('longitude') ?? '');

    if (lat == null || lng == null) {
      throw Exception("Location data is missing.");
    }

    String location = "$lat, $lng";

    print("📌 Booking Details:");
    print("👤 User ID: $userid");
    print("📦 Product IDs: $productIds");
    print("📍 Location: $location");
    print("🏠 Address: $add1");
    print("✅ Products Booked: $bookedCount");

    await ref.read(getproductProvider.notifier).createBooking(
      userId: userid,
      productIds: productIds,
      location: location,
      address: add1,
    );

    print("✅ Booking successful!");

    // Remove booked items from cart
    cartProductIds.removeWhere((id) => selectedProductIds.contains(id));
    await prefs.setStringList('cartItems', cartProductIds);

    selectedProductIds.clear(); // Clear selected items

    setState(() {});

    // ✅ Show success message with count
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$bookedCount products booked successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ Navigate to ProductsScreen if cart is empty
    if (cartProductIds.isEmpty) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => ProductsScreen(selectedCategory: 'ALL'))
      );
    } else {
      setState(() {}); // Update UI if cart still has items
    }
  } catch (error) {
    print("❌ Failed to proceed to booking: $error");
  }
}



  @override
  Widget build(BuildContext context) {
    double totalMRP = cartProducts.fold(0, (sum, product) {
      if (productSelections[product.productId!] == true && (product.spareParts ?? true) ) { // Only calculate for selected items
        int quantity = productQuantities[product.productId!] ?? 1;
        return sum + ((product.price ?? 0) * quantity);
      }
      return sum;
    });


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
                 // _buildSavingsBanner(),
                   Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    children: [
                      TextSpan(text: "Deliver To: "),
                      TextSpan(
                        text: add1!.isNotEmpty ? add1 : "No Address",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _changeAddress(context),
                  child: Text("Change", style: TextStyle(color: Colors.blue)),
                ),
                 ],
            ),
          ),
          if (latitude != null && longitude != null)
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Location:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      locationAddress,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
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
                    /// 🔹 Selected Product Count
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Selected Products: ${selectedProductIds.length}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: selectedProductIds.isNotEmpty
                          ? () async {
                             await _proceedToBuy();
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

  // Widget _buildSavingsBanner() {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     color: Colors.green[100],
  //     // child: const Text(
  //     //   "You're Saving 33% On This Order",
  //     //   style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
  //     // ),
  //   );
  // }

  Widget _buildCartItem(Data product) {
          int quantity = productQuantities[product.productId!] ?? 1;
      bool isSelected = productSelections[product.productId!] ?? true;
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
                  if (value != null) {
                    _saveSelection(product.productId!, value);
                  }
                }
              : null,
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: product.productImages != null
                        ? DecorationImage(
                            image: NetworkImage("${product.productImages?.first}"),
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
                      const Text("Size: mid", style: TextStyle(fontSize: 14, color: Colors.black54)),
                      Row(
                        children: [
                          const Text("Qty: ", style: TextStyle(fontSize: 14, color: Colors.black54)),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              if (quantity > 1) {
              _saveQuantity(product.productId!, quantity - 1);
                              }
                            },
                          ),
                          Text("$quantity", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () {
                        _saveQuantity(product.productId!, quantity + 1);
                          }
                            
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("33% ", style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
                          const Text("₹2245", style: TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.black45)),
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

    // Update the cart product list immediately 
    cartProducts.removeWhere((product) => product.productId == productId);

    // Show SnackBar message
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(
        content: const Text(
          "Item removed from cart",
          style: TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );

    setState(() {});
  }

  // void _proceedToBuy() {
  //   List<Data> selectedProducts = cartProducts.where((product) => selectedProductIds.contains(product.productId!)).toList();
  //   print("Proceeding to buy: ${selectedProducts.map((p) => p.productName).toList()}");
  // }
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

