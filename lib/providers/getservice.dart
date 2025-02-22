// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_user/model/service.dart';
// import 'package:gomed_user/providers/auth_state.dart';
// import 'package:gomed_user/providers/loader.dart';
// import 'package:gomed_user/utils/gomed_api.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/retry.dart';
// import 'package:shared_preferences/shared_preferences.dart';



// class Serviceprovider extends StateNotifier<ServiceModel>{
//   final Ref ref; // To access other providers
//   Serviceprovider(this.ref) : super((ServiceModel.initial()));

// Future<void> getSevices() async {
//     final loadingState = ref.read(loadingProvider.notifier);
//     try {
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
//       print('Retrieved Token: $token');
//       // Initialize RetryClient for handling retries
//       final client = RetryClient(
//         http.Client(),
//         retries: 3, // Retry up to 3 times
//         when: (response) =>
//             response.statusCode == 401 || response.statusCode == 400,
//         onRetry: (req, res, retryCount) async {
//           if (retryCount == 0 &&
//               (res?.statusCode == 401 || res?.statusCode == 400)) {
//             String? newAccessToken =
//                 await ref.read(userProvider.notifier).restoreAccessToken();
//             req.headers['Authorization'] = 'Bearer $newAccessToken';
//           }
//         },
//       );
//       final response = await client.get(
//         Uri.parse(Bbapi.getservices),
//         headers: {
//           "Authorization": "Bearer $token",
//         },
//       );
//       final responseBody = response.body;
//       print('Get service Status Code: ${response.statusCode}');
//       print('Get service Response Body: $responseBody');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final res = json.decode(responseBody);
//         // Check if the response body contains
//         final serviceData = ServiceModel.fromJson(res);
//         state = serviceData;
//         print("services fetched successfully.${serviceData.messages}");
//       } else {
//         final Map<String, dynamic> errorBody = jsonDecode(responseBody);
//         final errorMessage =
//             errorBody['message'] ?? "Unexpected error occurred.";
//         throw Exception("Error fetching services: $errorMessage");
//       }
//     } catch (e) {
//       print("Failed to fetch services: $e");
//     }
//   }
// }

// // Define productProvider with ref
// final serviceProvider =
//     StateNotifierProvider<Serviceprovider, ServiceModel>((ref) {
//   return Serviceprovider(ref);
// });










import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/service.dart';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/providers/loader.dart';
import 'package:gomed_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceProvider extends StateNotifier<AsyncValue<List<ServiceModel>>> {
  final Ref ref;

  ServiceProvider(this.ref) : super(const AsyncValue.loading()) {
    getServices();
  }

  Future<void> getServices() async {
    final loadingState = ref.read(loadingProvider.notifier);
    loadingState.state = true;

    try {
      final pref = await SharedPreferences.getInstance();
      String? userDataString = pref.getString('userData');

      if (userDataString == null || userDataString.isEmpty) {
        state = AsyncValue.error("User token is missing. Please log in again.", StackTrace.current);
        return;
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

      print('Retrieved Token: $token');

      final client = RetryClient(
        http.Client(),
        retries: 3,
        when: (response) => response.statusCode == 401 || response.statusCode == 400,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 &&
              (res?.statusCode == 401 || res?.statusCode == 400)) {
            String? newAccessToken =
                await ref.read(userProvider.notifier).restoreAccessToken();
            req.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        },
      );

      final response = await client.get(
        Uri.parse(Bbapi.getservices),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print('Get service Status Code: ${response.statusCode}');
      print('Get service Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(response.body);
        final List<ServiceModel> serviceList =
            (res['data'] as List).map((json) => ServiceModel.fromJson(json)).toList();

        state = AsyncValue.data(serviceList);
        print("Services fetched successfully.");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? "Unexpected error occurred.";
        state = AsyncValue.error("Error fetching services: $errorMessage", StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error("Failed to fetch services: $e", StackTrace.current);
    } finally {
      loadingState.state = false;
    }
  }
}

// Corrected Provider Declaration
final serviceProvider = StateNotifierProvider<ServiceProvider, AsyncValue<List<ServiceModel>>>(
  (ref) => ServiceProvider(ref),
);
