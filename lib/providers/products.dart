// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_user/providers/loader.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/retry.dart';
// import 'package:gomed_user/model/product.dart'; // Import your model file
// import 'package:gomed_user/utils/gomed_api.dart'; // Import Bbapi class
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gomed_user/providers/auth_state.dart';



// class ProductProvider extends StateNotifier<ProductModel> {
//   final Ref ref; // To access other providers
//   ProductProvider(this.ref) : super((ProductModel.initial()));
  


// Future<void> fetchProducts() async {
  
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
// final productProvider =
//     StateNotifierProvider<ProductProvider, ProductModel>((ref) {
//   return ProductProvider(ref);
// });





import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:gomed_user/model/product.dart'; 
import 'package:gomed_user/utils/gomed_api.dart'; 
import 'package:gomed_user/providers/auth_state.dart';

class ProductProvider extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final Ref ref;

  ProductProvider(this.ref) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final loginProvider = ref.read(userProvider);
    final token = loginProvider.data?[0].accessToken;

    if (token == null || token.isEmpty) {
      state = AsyncValue.error('Authorization token is missing', StackTrace.current);
      return;
    }

    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) => response.statusCode == 401,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await ref.watch(userProvider.notifier).restoreAccessToken();
            req.headers['Authorization'] = "Bearer $accessToken";
          }
        },
      );

      final response = await client.get(
        Uri.parse(Bbapi.getProducts),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = json.decode(response.body);
        final List<ProductModel> productList =
            (res['data'] as List).map((json) => ProductModel.fromJson(json)).toList();

        state = AsyncValue.data(productList);
      } else {
        state = AsyncValue.error('Failed to load products: ${response.statusCode}', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error('Error fetching products: $e', StackTrace.current);
    }
  }
}

// Corrected Provider Declaration
final productProvider = StateNotifierProvider<ProductProvider, AsyncValue<List<ProductModel>>>(
  (ref) => ProductProvider(ref),
);
