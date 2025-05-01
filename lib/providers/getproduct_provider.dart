// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_user/model/get_productbooking.dart';
// import 'package:gomed_user/providers/auth_state.dart';
// import 'package:gomed_user/providers/loader.dart';
// import 'package:gomed_user/utils/gomed_api.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/retry.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class GetproductProvider extends StateNotifier<GetproductModel> {
//   final Ref ref;
//   GetproductProvider(this.ref) : super(GetproductModel.initial());

// Future<void> getuserproduct() async {
//   final loadingState = ref.read(loadingProvider.notifier);
//    try {
//       loadingState.state = true;
//       // Retrieve the token from SharedPreferences
//       final pref = await SharedPreferences.getInstance();
//       String? userDataString = pref.getString('userData');
//       if (userDataString == null || userDataString.isEmpty) {
//         throw Exception("User token is missing. Please log in again.");
//       }
//       final Map<String, dynamic> userData = jsonDecode(userDataString);
//       String? token = userData['accessToken'];

//       if (token == null || token.isEmpty) {
//         token = userData['data'] != null &&
//                 (userData['data'] as List).isNotEmpty &&
//                 userData['data'][0]['access_token'] != null
//             ? userData['data'][0]['access_token']
//             : null;
//       }

//     print('Retrieved .......... Token: $token');
    

//     final client = RetryClient(
//       http.Client(),
//       retries: 3,
//       when: (response) => response.statusCode == 401 || response.statusCode == 400,
//       onRetry: (req, res, retryCount) async {
//         if (retryCount == 0 && (res?.statusCode == 401 || res?.statusCode == 400)) {
//           String? newAccessToken =
//               await ref.read(userProvider.notifier).restoreAccessToken();
//           req.headers['Authorization'] = 'Bearer $newAccessToken';
//         }
//       },
//     );

//     final response = await client.get(
//       Uri.parse(Bbapi.getproductbooking),
//       headers: {
//         "Authorization": "Bearer $token",
//       },
//     );
//     final responseBody = response.body;
//     print('Get booking product Status Code: ${response.statusCode}');
//     print('Get booking product Response Body: $responseBody');

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final res = json.decode(responseBody);

      
//          print("Get booking product successfully: ${response.body}");

//       final productData = GetproductModel.fromJson(res);
//       state = productData;

      
//     } else {
//       final Map<String, dynamic> errorBody = jsonDecode(responseBody);
//       final errorMessage = errorBody['message'] ?? "Unexpected error occurred.";
//       throw Exception("Error fetching products: $errorMessage");
//     }
//   } catch (e) {
//     print("Failed to fetch products: $e");
//   } finally {
//     loadingState.state = false;
//   }
// }
// }

// final getproductProvider = StateNotifierProvider<GetproductProvider, GetproductModel>((ref) {
//   return GetproductProvider(ref);
// });

















import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/auth.dart' hide Data ;
import 'package:gomed_user/model/get_productbooking.dart' ;
import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/providers/loader.dart';
import 'package:gomed_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetproductProvider extends StateNotifier<GetproductModel> {
  final Ref ref;
  GetproductProvider(this.ref) : super(GetproductModel.initial());


Future<void> createBooking({
    required String? userId,
    required List<Map<String, dynamic>> productIds,
    required String location,
    required String? address,
   

  }) async {
print('inside create booking....$userId,$productIds,$location,$address');
    try {
      // Retrieve token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        throw Exception("User token is missing. Please log in again.");
      }

      final Map<String, dynamic> userData = jsonDecode(userDataString);
      String? token = userData['accessToken'];

      if (token == null || token.isEmpty) {
        token = userData['data'] != null &&
                (userData['data'] as List).isNotEmpty &&
                userData['data'][0]['access_token'] != null
            ? userData['data'][0]['access_token']
            : null;
      }

      if (token == null || token.isEmpty) {
        throw Exception("User token is invalid. Please log in again.");
      }

      print('Retrieved Token: $token');
 List<String> extractedProductIds = productIds.map((product) => product['productId'].toString()).toList();
    print('Extracted product IDs: $extractedProductIds');
     List<String> extractedDistributorIds = productIds.map((product) => product['distributor_id'].toString()).toList();
    print('Extracted distributor IDs: $extractedDistributorIds');
         List<String> extractedPrice = productIds.map((product) => product['price'].toString()).toList();
    print('Extracted price: $extractedPrice');
      // Initialize retry logic
      final client = RetryClient(
        http.Client(),
        retries: 3,
        when: (response) => response.statusCode == 400 || response.statusCode == 401,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && (res?.statusCode == 400 || res?.statusCode == 401)) {
            // Token refresh logic
            String? newAccessToken = await ref.read(userProvider.notifier).restoreAccessToken();
            print('Restored Token: $newAccessToken');
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );
       // Prepare request body
      final Map<String, dynamic> requestBody = {
        "userId": userId ?? '',
        "location": location,
        "address": address ?? '',
        "status": "pending",
        "products": productIds,
      };

       // Send POST request with JSON body
      final response = await client.post(
        Uri.parse(Bbapi.createbooking),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

    // Send Request
    // final streamedResponse = await client.send(request);
    // final response = await http.Response.fromStream(streamedResponse);


      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('bookings');
   // Create a new unique key

    for (var product in productIds) {
    final String distributorId = product['distributor_id'].toString();
    final int totalprice = int.tryParse(product['price'].toString()) ?? 0;
    final int quantity = int.tryParse(product['quantity'].toString()) ?? 1;
    final int price = totalprice * quantity;
    final DatabaseReference distributorRef = dbRef.child(distributorId);
    

    final DataSnapshot snapshot = await distributorRef.get();

    if (snapshot.exists) {
      // Add to existing wallet
      final currentData = snapshot.value as Map;
      final int currentWallet = int.tryParse(currentData['wallet'].toString()) ?? 0;
      final int updatedWallet = currentWallet + price;

      await distributorRef.update({
        'wallet': updatedWallet,
      });

      print("Updated wallet for distributor $distributorId: $updatedWallet");
    } else {
      // Create new record
      await distributorRef.set({
        'distributor_id': distributorId,
        'wallet': price,
      });

      print("Created new wallet record for distributor $distributorId: $price");
    }
  }
       // state = GetproductModel.fromJson(responseBody);
       print('booking products.....$responseBody');
        print("Booking created successfully!");

      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unexpected error occurred.';
        throw Exception("Error creating booking: $errorMessage");
      }
    } catch (error) {
      print("Failed to create booking: $error");
      rethrow;
    }
  }  






Future<void> getuserproduct() async {
  final loadingState = ref.read(loadingProvider.notifier);
  try {
    loadingState.state = true;

    // Retrieve user data from SharedPreferences
    final pref = await SharedPreferences.getInstance();
    String? userDataString = pref.getString('userData');

    if (userDataString == null || userDataString.isEmpty) {
      throw Exception("User data is missing. Please log in again.");
    }

    // Decode the user data JSON
    final Map<String, dynamic> userDataJson = jsonDecode(userDataString);
    print("User Data from SharedPreferences: $userDataJson"); // Debugging

    // Convert JSON to UserModel
    UserModel userModel = UserModel.fromJson(userDataJson);

    // Extract the first available user ID
    String? loggedInUserId;
    if (userModel.data != null && userModel.data!.isNotEmpty) {
      loggedInUserId = userModel.data!.first.user?.sId;
    }

    if (loggedInUserId == null || loggedInUserId.isEmpty) {
      throw Exception("User ID not found. Debug: ${userModel.toJson()}");
    }

    String? token = userModel.data?.first.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception("Authentication token missing.");
    }

    print('Retrieved Token: $token');
    print('Logged-in User ID: $loggedInUserId');

    final client = RetryClient(
      http.Client(),
      retries: 3,
      when: (response) => response.statusCode == 401 || response.statusCode == 400,
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && (res?.statusCode == 401 || res?.statusCode == 400)) {
          String? newAccessToken =
              await ref.read(userProvider.notifier).restoreAccessToken();
          req.headers['Authorization'] = 'Bearer $newAccessToken';
        }
      },
    );

    final response = await client.get(
      Uri.parse(Bbapi.getproductbooking),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final responseBody = response.body;
    print('Get booking product Status Code: ${response.statusCode}');
    print('Get booking product Response Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = json.decode(responseBody);
      final productData = GetproductModel.fromJson(res);

      // Ensure `data` is not null before filtering
      final List<Data> userProducts = productData.data
              ?.where((booking) => booking.userId?.sId == loggedInUserId)
              .toList() ??
          [];

      state = GetproductModel(
        statusCode: productData.statusCode,
        success: productData.success,
        messages: productData.messages,
        data: userProducts, // Update state with filtered data
      );

      print("Filtered User Booked Products: ${userProducts.length}");
    } else {
      final Map<String, dynamic> errorBody = jsonDecode(responseBody);
      final errorMessage = errorBody['message'] ?? "Unexpected error occurred.";
      throw Exception("Error fetching booking products: $errorMessage");
    }
  } catch (e) {
    print("Failed to fetch booking products: $e");
  } finally {
    loadingState.state = false;
  }
}






Future<bool> cancelBooking(String? bookingId) async {

  final String apiUrl = "${Bbapi.cancelbooking}/$bookingId"; // Replace with actual API endpoint
  final loadingState = ref.read(loadingProvider.notifier);
  final loginprovider = ref.read(userProvider);
    final token = loginprovider.data?[0].accessToken;

  try {
    loadingState.state = true; // Show loading state
    if (token == null || token.isEmpty) {
      throw Exception("Authentication token missing.");
    }
   final client = RetryClient(
      http.Client(),
      retries: 3,
      when: (response) => response.statusCode == 401 || response.statusCode == 400,
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && (res?.statusCode == 401 || res?.statusCode == 400)) {
          String? newAccessToken =
              await ref.read(userProvider.notifier).restoreAccessToken();
          req.headers['Authorization'] = 'Bearer $newAccessToken';
        }
      },
    );

    final response = await client.delete(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Include token
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Booking successfully canceled.");
       return true;
    } else {
      print("Failed to cancel booking. Status code: ${response.statusCode}");
      print("Response: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error while canceling booking: $e");
    return false;
  } finally {
    loadingState.state = false; // Hide loading state
  }
}


}

final getproductProvider = StateNotifierProvider<GetproductProvider, GetproductModel>((ref) {
  return GetproductProvider(ref);
});
