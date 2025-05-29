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
enum PaymentMethod { cod, online }
class CartScreenState extends ConsumerState<CartScreen> {
  List<String> cartItemKeys = []; // Now stores composite keys
  List<Data> cartProducts = [];
  List<String> selectedCartItemKeys = []; // Track selected cart items by composite key
  Map<String, int> productQuantities = {}; // Key: composite key, Value: quantity
  Map<String, bool> productSelections = {}; // Key: composite key, Value: selection state
  TextEditingController locationSearchController = TextEditingController();
  PaymentMethod selectedMethod = PaymentMethod.online;
  String? add1;
  String? add2;
  double? latitude;
  double? longitude;
  String? userid;
  double?totalAmount;
  double?codAdvance;
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

    if (userState != null) {
      final user = userState.data![0].user;
      setState(() {
        userid = userState.data![0].user!.sId;
        add1 = user!.address ?? prefs.getString('add1') ?? "No Address";
        latitude = double.tryParse(user.location?.latitude ?? "0.0");
        longitude = double.tryParse(user.location?.longitude ?? "0.0");
      });
      print('details.....$add1,$latitude,$longitude,$userid');

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

  // UPDATED: Load cart items with composite key support
  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartItemKeys = prefs.getStringList('cartItems') ?? [];
    print('cart item keys---${cartItemKeys.length}');

    final productState = ref.watch(productProvider);
    if (productState.data != null) {
      cartProducts.clear();
      
      // Parse composite keys and find matching products
      for (String cartItemKey in cartItemKeys) {
        List<String> parts = cartItemKey.split('_');
        if (parts.length == 2) {
          String productId = parts[0];
          String distributorId = parts[1];
          
          // Find the specific product-distributor combination
          Data? matchingProduct = productState.data!.firstWhere(
            (product) => product.productId == productId && product.distributorId == distributorId,
            orElse: () => Data.initial(),
          );
          
          if (matchingProduct != null) {
            cartProducts.add(matchingProduct);
            
            // Initialize selection and quantity using composite key
            productSelections[cartItemKey] = prefs.getBool('selected_$cartItemKey') ?? true;
            productQuantities[cartItemKey] = prefs.getInt('quantity_$cartItemKey') ?? 1;
          }
        }
      }
    }
    print('product data--${cartProducts.length}');

    selectedCartItemKeys = productSelections.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    setState(() {});
  }

  int get totalSelectedBookingCount {
    int count = 0;
    for (var cartItemKey in productSelections.keys) {
      if (productSelections[cartItemKey] == true) {
        count += productQuantities[cartItemKey] ?? 1;
      }
    }
    return count;
  }

  // UPDATED: Save selection using composite key
  Future<void> _saveSelection(String cartItemKey, bool isSelected) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('selected_$cartItemKey', isSelected);
    setState(() {
      productSelections[cartItemKey] = isSelected;
      // Update the selectedCartItemKeys list
      if (isSelected) {
        if (!selectedCartItemKeys.contains(cartItemKey)) {
          selectedCartItemKeys.add(cartItemKey);
        }
      } else {
        selectedCartItemKeys.remove(cartItemKey);
      }
    });
  }

  // UPDATED: Save quantity using composite key
  Future<void> _saveQuantity(String cartItemKey, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quantity_$cartItemKey', quantity);
    setState(() {
      productQuantities[cartItemKey] = quantity;
    });
  }

  Future<void> _proceedToBuy() async {
    try {
      List<Data> selectedProducts = [];
      
      // Get selected products using composite keys
      for (String cartItemKey in selectedCartItemKeys) {
        Data? product = cartProducts.firstWhere(
          (p) => "${p.productId}_${p.distributorId}" == cartItemKey,
          orElse: () => Data.initial(),
        );
        if (product != null) {
          selectedProducts.add(product);
        }
      }

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

      int bookedCount = selectedProducts.fold(
        0,
        (sum, product) {
          String cartItemKey = "${product.productId}_${product.distributorId}";
          return sum + (productQuantities[cartItemKey] ?? 1);
        },
      );

      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User data is missing.");
      }

      List<Map<String, dynamic>> productIds = selectedProducts.map((product) {
        String cartItemKey = "${product.productId}_${product.distributorId}";
        int quantity = productQuantities[cartItemKey] ?? 1;
        String distributorid = product.distributorId!;
         double userPrice = product.price! + (product.price! * 0.10); // 10% markup

        return {
          "productId": product.productId!,
          "distributorId": distributorid,
          "quantity": quantity,
          "bookingStatus": "pending",     // ✅ Required
          "userPrice": double.parse(userPrice.toStringAsFixed(2)) // Optional: precision
         

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
      print("✅ booking otp: $bookingOtp");
      print("✅ Products Booked: $selectedMethod");
      print("✅ Products Booked: $codAdvance");
      print("✅ Products Booked: $totalAmount");

      String paymentMethodString = selectedMethod == PaymentMethod.cod? "cod"
    : "onlinepayment";

      await ref.read(getproductProvider.notifier).createBooking(
        userId: userid,
        productIds: productIds,
        location: location,
        address: add1,
        bookingOtp: bookingOtp,
        paymentmethod:paymentMethodString,
        codAdvance:codAdvance,
        totalPrice:totalAmount,

      );

      print("✅ Booking successful!");

      // Remove booked items from cart using composite keys
      cartItemKeys.removeWhere((key) => selectedCartItemKeys.contains(key));
      await prefs.setStringList('cartItems', cartItemKeys);

      selectedCartItemKeys.clear();

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$bookedCount products booked successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      if (cartItemKeys.isEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProductsScreen(selectedCategory: 'ALL')));
      } else {
        setState(() {});
      }
    } catch (error) {
      print("❌ Failed to proceed to booking: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // double totalMRP = 0;
     double totalBase = 0;
    int totalSelectedBookingCount = 0;

    
    // Calculate total using composite keys
    for (Data product in cartProducts) {
      String cartItemKey = "${product.productId}_${product.distributorId}";
      if (productSelections[cartItemKey] == true) {
        int quantity = productQuantities[cartItemKey] ?? 1;
        // totalMRP += (product.price ?? 0) * quantity;
        totalBase += (product.price ?? 0) * quantity;
        totalSelectedBookingCount++;
      }
    }

    // double platformFee = totalMRP * 0.025; // 2.5% fee
    // double totalAmount = double.parse(((totalMRP * 1.10) + platformFee).toStringAsFixed(2));

    double totalAdded = totalBase * 0.10; // 10% of base
    double userPrice = totalBase + totalAdded;
    double platformFee = userPrice * 0.025; // 2.5% of userPrice
    double totalAmount = userPrice + platformFee;
    double codAdvance = totalAdded + platformFee;
    print("10% of original price:$totalAdded");
    print("userPrice:$userPrice");
    print("platformfee:$platformFee");
    print("totalAmount:$totalAmount");
    print("paidPrice:$codAdvance");
    print("original price:$totalBase");
    print("paymenttype:$selectedMethod");
    

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
                totalMRP: userPrice,
                platformFee: platformFee,
                totalAmount: totalAmount,
              ),
              const SizedBox(height: 20),
                      const Text("Select Payment Method"),
                      Row(
                        children: [
                          Radio<PaymentMethod>(
                            value: PaymentMethod.cod,
                            groupValue: selectedMethod,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedMethod = value;
                                });
                              }
                            },
                          ),
                          const Text("Cash on Delivery"),
                          Radio<PaymentMethod>(
                            value: PaymentMethod.online,
                            groupValue: selectedMethod,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedMethod = value;
                                });
                              }
                            },
                          ),
                          const Text("Online Payment"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedMethod == PaymentMethod.online
                            ? "Full Amount to Pay: ₹${totalAmount.toStringAsFixed(2)}"
                            : "Advance to Pay: ₹${codAdvance.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
              if (selectedCartItemKeys.isEmpty)
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
                  onPressed: selectedCartItemKeys.isNotEmpty
                      ? () {
                    double payAmount = selectedMethod == PaymentMethod.online
                                    ? totalAmount
                                    : codAdvance;    
                    print("Razorpay Amount:$payAmount");                
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RazorpayPaymentPage(
                          amount: payAmount,
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

  // UPDATED: Build cart item using composite key
  Widget _buildCartItem(Data product) {
    String cartItemKey = "${product.productId}_${product.distributorId}";
    int quantity = productQuantities[cartItemKey] ?? 1;
    bool isSelected = productSelections[cartItemKey] ?? true;
    int maxLimit = product.quantity ?? 1;

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
                      _saveSelection(cartItemKey, value);
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
                    Text("AvlQty:${product.quantity}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                      Row(
                        children: [
                          const Text("Qty: ",
                              style: TextStyle(fontSize: 14, color: Colors.black54)),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              if (quantity > 1) {
                                _saveQuantity(cartItemKey, quantity - 1);
                              }
                            },
                          ),
                          Text("$quantity",
                              style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: quantity < maxLimit
                                ? () {
                              _saveQuantity(cartItemKey, quantity + 1);
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
                    await _removeFromCart(cartItemKey);
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

  // UPDATED: Remove from cart using composite key
  Future<void> _removeFromCart(String cartItemKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartItemKeys.remove(cartItemKey);
    await prefs.setStringList('cartItems', cartItemKeys);

    // Remove from local lists
    cartProducts.removeWhere((product) => "${product.productId}_${product.distributorId}" == cartItemKey);
    productSelections.remove(cartItemKey);
    productQuantities.remove(cartItemKey);
    selectedCartItemKeys.remove(cartItemKey);

    // Clean up SharedPreferences
    await prefs.remove('selected_$cartItemKey');
    await prefs.remove('quantity_$cartItemKey');

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