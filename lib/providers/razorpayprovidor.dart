// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_user/providers/loader.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/retry.dart';
// import 'package:gomed_user/model/product.dart'; // Import your model file
// import 'package:gomed_user/utils/gomed_api.dart'; // Import Bbapi class
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gomed_user/providers/auth_state.dart';



// class RazorPayProvider extends StateNotifier<> {
//   final Ref ref; // To access other providers
//   RazorPayProvider(this.ref) : super();
  


// Future<void> razorPayment() async {
  
//   final loadingState = ref.read(loadingProvider.notifier);
//   final loginprovider = ref.read(userProvider);
//     final token = loginprovider.data?[0].accessToken;
//   try {
//     //final prefs = await SharedPreferences.getInstance();
//     //String? token = prefs.getString('accessToken');

//     if (token == null || token.isEmpty) {
//       throw Exception('Authorization token is missing');
//     }
//        loadingState.state = true; // Show loading state
//        final client = RetryClient(
//         http.Client(),
//         retries: 4,
//         when: (response) {
//           return response.statusCode == 401 ? true : false;
//         },
//         onRetry: (req, res, retryCount) async {
//           if (retryCount == 0 && res?.statusCode == 401) {
//             // Here, handle your token restoration logic
//             // You can access other providers using ref.read if needed
//             var accessToken = await ref.watch(userProvider.notifier).restoreAccessToken();

//             //print(accessToken); // Replace with actual token restoration logic
//             req.headers['Authorization'] = "Bearer ${accessToken.toString()}";
//           }
//         },
//       );

//     final response = await client.get(
//       Uri.parse(Bbapi.getProducts),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     print('API Response: ${response.body}');

//     if (response.statusCode == 200) {
//       // Attempt to parse the response body
//       print('inside if condition');
//       final Map<String, dynamic> res = json.decode(response.body);
//       final productData = ProductModel.fromJson(res);
//       state = productData;
//       print("Products fetched successfully: ${productData.toJson()}");
//     } else {
//       throw Exception('Failed to load products: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error fetching products: $e');
//   }finally {
//     loadingState.state = false; // Hide loading state
//   }
// }

// }


// // Define productProvider with ref
// final razorpay =
//     StateNotifierProvider<RazorPayProvider, >((ref) {
//   return RazorPayProvider(ref);
// });




import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayProvider extends StateNotifier<void> {
  final Ref ref;
  late Razorpay _razorpay;

  RazorPayProvider(this.ref) : super(null) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void disposeRazorpay() {
    _razorpay.clear();
  }

  Future<void> startPayment({
    required String amount,
    required String name,
    required String contact,
    required String email,
  }) async {
    var options = {
      'key': 'rzp_test_YourKeyHere',
      'amount': int.parse(amount),
      'name': name,
      'description': 'Payment',
      'prefill': {'contact': contact, 'email': email},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error in Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment successful: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment failed: ${response.code} | ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External wallet selected: ${response.walletName}");
  }
}

final razorpayProvider = StateNotifierProvider<RazorPayProvider, void>((ref) {
  return RazorPayProvider(ref);
});
