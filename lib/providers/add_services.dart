// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_user/providers/auth_state.dart';
// import 'package:gomed_user/utils/gomed_api.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/retry.dart';
// import '../model/addservices.dart';

// class AddServicesProvider extends StateNotifier<AddservicesModel> {
//   final Ref ref;

//   AddServicesProvider(this.ref) : super(AddservicesModel.initial());

//   Future<void> addServices({
//     required String? userId,
//     required List<String> serviceId,
//     required String location,
//     required String? address,
//     required String date,
//     required String time,
//   }) async {
//     print('inside create booking....$userId,$serviceId,$location,$address');
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? userDataString = prefs.getString('userData');

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

//       if (token == null || token.isEmpty) {
//         throw Exception("User token is invalid. Please log in again.");
//       }

//       print('Retrieved Token: $token');

//       final client = RetryClient(
//         http.Client(),
//         retries: 3,
//         when: (response) => response.statusCode == 400 || response.statusCode == 401,
//         onRetry: (req, res, retryCount) async {
//           if (retryCount == 0 && (res?.statusCode == 400 || res?.statusCode == 401)) {
//             String? newAccessToken = await ref.read(userProvider.notifier).restoreAccessToken();
//             print('Restored Token: $newAccessToken');
//             req.headers['Authorization'] = 'Bearer $newAccessToken';
//           }
//         },
//       );

//       final Map<String, dynamic> requestBody = {
//         "userId": userId ?? '',
//         "serviceIds": serviceId,
//         "location": location,
//         "address": address ?? '',
//         "date": date,
//         "time": time,
//         "status": "pending",
//       };

//       final response = await client.post(
//         Uri.parse(Bbapi.servicebooking),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(requestBody),
//       );

//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final Map<String, dynamic> responseBody = jsonDecode(response.body);
//         //state = AddservicesModel.fromJson(responseBody);
//         print('booked services....$responseBody');
//         print("Booking services created successfully!");
//       } else {
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['message'] ?? 'Unexpected error occurred.';
//         throw Exception("Error creating service booking: $errorMessage");
//       }
//     } catch (error) {
//       print("Failed to create service booking: $error");
//       rethrow;
//     }
//   }
// }

// final addServicesProvider = StateNotifierProvider<AddServicesProvider, AddservicesModel>((ref) {
//   return AddServicesProvider(ref);
// });
