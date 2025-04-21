import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/service_engineer_model.dart';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/providers/loader.dart';
import 'package:gomed_user/utils/gomed_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";

class ServiceEngineerNotifier extends StateNotifier<ServiceEngineerModel> {
  final Ref ref;
  ServiceEngineerNotifier(this.ref) : super(ServiceEngineerModel.initial());
   
   Future<void> getServiceengineers() async {
    final loadingState = ref.read(loadingProvider.notifier);
    try {
      loadingState.state = true;
      print('get serviceenginerrs');

      // Retrieve the token from SharedPreferences
      final pref = await SharedPreferences.getInstance();
      String? userDataString = pref.getString('userData');
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
      print('Retrieved Token: $token');

      final response = await http.get(
        Uri.parse(Bbapi.getServiceengineers),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print('Get serviceengineers Status Code: ${response.statusCode}');
      print('Get serviceengineers Response Body: ${response.body}');

      if (response.statusCode == 401) {
        print("Token expired, attempting refresh...");
        String? newAccessToken =
            await ref.read(userProvider.notifier).restoreAccessToken();

        if (newAccessToken!.isNotEmpty) {
          userData['accessToken'] = newAccessToken;
          pref.setString('userData', jsonEncode(userData));

          final retryResponse = await http.get(
            Uri.parse(Bbapi.getServiceengineers),
            headers: {
              "Authorization": "Bearer $newAccessToken",
            },
          );

          print('Retry Get serviceengineers Status Code: ${retryResponse.statusCode}');
          print('Retry Get serviceengineers Response Body: ${retryResponse.body}');

          if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
            final res = json.decode(retryResponse.body);
            final serviceengineerData = ServiceEngineerModel.fromJson(res);
            state = serviceengineerData;
            print("serviceengineers fetched successfully.${serviceengineerData.messages}");
            return;
          }
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(response.body);
        final serviceengineerData = ServiceEngineerModel.fromJson(res);
        state = serviceengineerData;
        print("serviceengineers fetched successfully.${serviceengineerData.messages}");
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? "Unexpected error occurred.";
        throw Exception("Error fetching serviceengineers: $errorMessage");
      }
    } catch (e) {
      print("Failed to fetch serviceengineers: $e");
    }
  }}

  final serviceEngineer =
    StateNotifierProvider<ServiceEngineerNotifier, ServiceEngineerModel>((ref) {
  return ServiceEngineerNotifier(ref);
});
