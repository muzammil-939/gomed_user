import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gomed_user/main.dart';
import 'package:gomed_user/providers/addbooking_provider.dart';

import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/providers/getproduct_provider.dart';
import 'package:gomed_user/screens/razorpay_payment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/model/product.dart';
import "package:gomed_user/screens/products_screen.dart";
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
  TextEditingController locationSearchController = TextEditingController();

  String? add1;
  String? add2;
  double? latitude;
  double? longitude;
  String? userid;
  String locationAddress = "Fetching location...";

  String bookingOtp = generatebookingOtp();

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
    if (userState != null) {
      final user = userState.data![0].user; // Assuming user data is fetched
      setState(() {
        userid = userState.data![0].user!.sId;
        add1 = user!.address ?? prefs.getString('add1') ?? "No Address";
        latitude = double.tryParse(user.location?.latitude ?? "0.0");
        longitude = double.tryParse(user.location?.longitude ?? "0.0");
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

    for (var product in cartProducts) {
      productSelections[product.productId!] = prefs.getBool('selected_${product.productId}') ?? true;
      productQuantities[product.productId!] = prefs.getInt('quantity_${product.productId}') ?? 1;
    }

    selectedProductIds = productSelections.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    setState(() {});
  }

  int get totalSelectedBookingCount {
    int count = 0;
    for (var productId in productSelections.keys) {
      if (productSelections[productId] == true) {
        count += productQuantities[productId] ?? 1;
      }
    }
    return count;
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
          productSelections[product.productId!] == true)
          .toList();

      if (selectedProducts.isEmpty) {
        print("❌ No products selected for booking.");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ No products selected for booking."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // int bookedCount = selectedProducts.length;
      int bookedCount = selectedProducts.fold(
        0,
            (sum, product) => sum + (productQuantities[product.productId!] ?? 1),
      );

      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User data is missing.");
      }

      // List<String> productIds = selectedProducts.map((p) => p.productId.toString()).toList();
      List<Map<String, dynamic>> productIds = selectedProducts.map((product) {
        String id = product.productId!;
        int quantity = productQuantities[id] ?? 1;
        String distributorid = product.distributorId!;
        int price = product.price!;

        return {
          "productId": id,
          "quantity": quantity,
          "distributor_id": distributorid,
          "price": price
        };
      }).toList();

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
        bookingOtp: bookingOtp,
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
            MaterialPageRoute(builder: (_) => ProductsScreen(selectedCategory: 'ALL')));
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
      if (productSelections[product.productId!] == true) {
        int quantity = productQuantities[product.productId!] ?? 1;
        return sum + ((product.price ?? 0) * quantity);
      }
      return sum;
    });

    double platformFee = totalMRP * 0.025; // 2.5% fee
    double totalAmount = double.parse(((totalMRP * 1.10) + platformFee).toStringAsFixed(2)); // 10% markup + 2.5% platform fee

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1BA4CA),
        title: const Text("CART"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: cartProducts.isEmpty
              ? const Center(
            child: Text(
              "Your cart is empty!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : Column(
            children: [
              // Address Section
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          children: [
                            TextSpan(text: "Deliver To: "),
                            TextSpan(
                              text: add1 != null && add1!.isNotEmpty ? add1! : "No Address",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _changeAddress(context),
                      child: const Text("Change", style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),

              // Location search section
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Search Location:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: locationSearchController,
                      googleAPIKey: "AIzaSyCMADwyS3eoxJ5dQ_iFiWcDBA_tJwoZosw",
                      inputDecoration: InputDecoration(
                        hintText: "Search for location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      debounceTime: 800,
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (prediction) {
                        double lat = double.parse(prediction.lat!);
                        double lng = double.parse(prediction.lng!);
                        setState(() {
                          latitude = lat;
                          longitude = lng;
                        });
                        _getAddressFromCoordinates(lat, lng);
                      },
                      itemClick: (prediction) {
                        FocusScope.of(context).unfocus();
                        locationSearchController.text = prediction.description!;
                        locationSearchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your Location:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      locationAddress,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              // Cart items list
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    children: cartProducts.map((product) => _buildCartItem(product)).toList(),
                  ),
                ),
              ),

              // Price details
              PriceDetails(
                totalMRP: totalMRP,
                platformFee: platformFee,
                totalAmount: totalAmount,
              ),

              // Selected products count
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  " $totalSelectedBookingCount Selected Products for Booking",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),

              // Warning if no products selected
              if (selectedProductIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Select at least one product to continue",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Continue button
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: selectedProductIds.isNotEmpty
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RazorpayPaymentPage(
                          amount: totalAmount,
                          onSuccess: _proceedToBuy,
                          email: '',
                          contact: '',
                        ),
                      ),
                    );
                  }
                      : null,
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
      ),
    );
  }

  Widget _buildCartItem(Data product) {
    int quantity = productQuantities[product.productId!] ?? 1;
    bool isSelected = productSelections[product.productId!] ?? true;
    int maxLimit = product.quantity ?? 1; // Make sure `product.stock` exists in your model

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
                  onChanged: (value) {
                    if (value != null) {
                      _saveSelection(product.productId!, value);
                    }
                  },
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
                      Text(product.productName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(product.productDescription ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey)),
                      const Text("Size: mid",
                          style: TextStyle(fontSize: 14, color: Colors.black54)),
                      Row(
                        children: [
                          const Text("Qty: ",
                              style: TextStyle(fontSize: 14, color: Colors.black54)),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              if (quantity > 1) {
                                _saveQuantity(product.productId!, quantity - 1);
                              }
                            },
                          ),
                          Text("$quantity",
                              style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: quantity < maxLimit
                                ? () {
                              _saveQuantity(product.productId!, quantity + 1);
                            }
                                : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Only $maxLimit available for this product.",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "₹${(product.price! * 1.10).toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 5),
                          Text("₹${product.price}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
}

class PriceDetails extends StatelessWidget {
  final double totalMRP;
  final double totalAmount;
  final double platformFee;

  const PriceDetails({required this.totalMRP, required this.totalAmount, required this.platformFee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildRow("Total MRP:", "₹${totalMRP.toStringAsFixed(2)}"),
            _buildRow("Platform Fee (2.5%):", "+₹${platformFee.toStringAsFixed(2)}"),
            _buildRow("Total Amount:", "₹${totalAmount.toStringAsFixed(2)}", isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}