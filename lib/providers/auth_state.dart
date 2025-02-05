import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/auth.dart' ;
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_auth.dart';
import 'loader.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gomed_user/utils/gomed_api.dart';

class PhoneAuthNotifier extends StateNotifier<UserModel> {
  final Ref ref;
  PhoneAuthNotifier(this.ref) : super(UserModel.initial());


 // Profile Update Method
  // Future<void> updateProfile(String? name, String? email, String? phone, File?_selectedImage) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   print('ownerName--$name,  email--$email,  mobile--$phone,  photo--${_selectedImage!.path}');
  //   final userId = prefs.getString('userId'); // Assuming user ID is stored in SharedPreferences
  //   final token = prefs.getString('firebaseToken'); // Assuming Firebase token is stored

  //   if (userId == null || token == null) {
  //     print('User ID or Firebase token is missing.');
  //     return;
  //   }

  //   final apiUrl = "${Bbapi.updateProfile}/$userId"; // Construct the API URL with userId

  //   try {
  //     final response = await http.put(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         "Content-Type": "multipart/form-data",
  //         "Authorization": "Bearer $token", // Send token in Authorization header
  //       },
  //       body: json.encode({
  //         "ownerName": name,
  //         "email": email,
  //         "mobile": phone,

  //       }),
  //     );
       
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       // Successfully updated profile
  //       print("Profile updated successfully.");
  //       final updatedUser = json.decode(response.body);
  //       state = state.copyWith(
  //         data: [Data.fromJson(updatedUser['user'])], // Assuming response contains updated user data
  //       );

  //       // Optionally, update the local storage
  //       await prefs.setString('userData', json.encode(updatedUser));
  //     } else {
  //       print("Failed to update profile. Status code: ${response.statusCode}");
  //       print("Response: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error while updating profile: $e");
  //   }
  // }
  Future<void> updateProfile(
  String? name,
  String? email,
  String? phone,
  File? selectedImage,
  WidgetRef ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  final userModel = ref.read(userProvider); // Retrieve UserModel from the provider
  final userId = userModel.data?[0].user!.sId; // Get user ID, default to empty string if null
  final token = userModel.data?[0].accessToken; // Get token, default to empty string if null
  final loadingState = ref.read(loadingProvider.notifier);


 // final userId = prefs.getString('userId');
 // final token = prefs.getString('firebaseToken');

  print('name--$name, email--$email, mobile--$phone, photo--${selectedImage?.path}');

  if (userId == null || token == null) {
    print('User ID or Firebase token is missing.');
    return;
  }

  final apiUrl = "${Bbapi.updateProfile}/$userId";

  try {
     loadingState.state = true; // Show loading state
       final retryClient = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 404 || response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 404 || res?.statusCode == 401 ) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken = await restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = "Bearer ${accessToken.toString()}";
          }
        },
      );
    final request = http.MultipartRequest('PUT', Uri.parse(apiUrl))
      ..headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      })
      ..fields['ownerName'] = name ?? ''
      ..fields['email'] = email ?? ''
      ..fields['mobile'] = phone ?? '';

    if (selectedImage != null) {
      if (await selectedImage.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          selectedImage.path,
        ));
      } else {
        print("Profile image file does not exist: ${selectedImage.path}");
        throw Exception("Profile image file not found");
      }
    }

    print("Request Fields: ${request.fields}");
    print("Request Headers: ${request.headers}");

    //final response = await request.send();
    //final response = await http.Response.fromStream(response);
    // Send the request using the inner client of RetryClient
    final streamedResponse = await retryClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Profile updated successfully.");
      
      var userDetails = json.decode(response.body);
        UserModel user = UserModel.fromJson(userDetails);
        print("Response: ${response.body}");

        // Debug: Print the user data to check if it's correct
         print("User Data to Save: ${user.toJson()}");

         //state=state.copyWith(messages:userDetails['message'],
        
         //data: [Data.fromJson(userDetails['user'])],); // Assuming userDetails['user'] maps to the Data model
         state = user;
         final userData = json.encode({
        //'accessToken': user.data?[0].accessToken,
        'statusCode':user.statusCode,
        'success':user.success,
        'messages':user.messages,
        'data': user.data?.map((data) => data.toJson()).toList(), // Serialize all Data objects
     });
         // Debug: Print userData before saving
          print("User Data to Save in SharedPreferences: $userData");

         await prefs.setString('userData', userData);

    } else {
      print("Failed to update profile. Status code: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("Error while updating profile: $e");
  } finally {
    loadingState.state = false; // Hide loading state
  }
}


//   Future<bool> tryAutoLogin() async {
//   final prefs = await SharedPreferences.getInstance();

//   // Check if the 'userData' key is present in SharedPreferences
//   if (!prefs.containsKey('userData')) {
//     print('No user data found. tryAutoLogin is set to false.');
//     return false;
//   }

//   try {
//     // Retrieve and decode the user data from SharedPreferences
//     final extractedData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

//     // Ensure the extracted data contains the necessary keys
//     if (extractedData.containsKey('statusCode') &&
//         extractedData.containsKey('success') &&
//         extractedData.containsKey('messages') &&
//         extractedData.containsKey('data')) {
      
//       // Map the JSON data to your UserModel
//       UserModel userModel = UserModel.fromJson(extractedData);

//       // Update the state with the decoded user data
//       state = state.copyWith(
//         statusCode: userModel.statusCode,
//         success: userModel.success,
//         messages: userModel.messages,
//         data: userModel.data,
//       );

//       print('User ID: ${state.data?.user?.sId}');  // Accessing the User ID from the nested Data

//       return true;
//     } else {
//       print('Missing necessary fields in SharedPreferences.');
//       return false;
//     }
//   } catch (e) {
//     print('Error while parsing user data: $e');
//     return false;
//   }
// }

Future<bool> tryAutoLogin() async {
  final prefs = await SharedPreferences.getInstance();

  // Check if the 'userData' key exists in SharedPreferences
  if (!prefs.containsKey('userData')) {
    print('No user data found. tryAutoLogin is set to false.');
    return false;
  }

  try {
    // Retrieve and decode the user data from SharedPreferences
    final extractedData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    print("Extracted data from SharedPreferences: $extractedData");

    // Validate that all necessary keys exist in the extracted data
    if (extractedData.containsKey('statusCode') &&
        extractedData.containsKey('success') &&
        extractedData.containsKey('messages') &&
        extractedData.containsKey('data')) {
      
      // Map the JSON data to the UserModel
      final userModel = UserModel.fromJson(extractedData);
      print("User Model from SharedPreferences: $userModel");

      // Validate nested data structure
      if (userModel.data != null && userModel.data!.isNotEmpty) {
        final firstData = userModel.data![0]; // Access the first element in the list
        if (firstData.user == null || firstData.accessToken == null) {
          print('Invalid user data structure inside SharedPreferences.');
          return false;
        }
      }

      // Update the state with the decoded user data
      state = state.copyWith(
        statusCode: userModel.statusCode,
        success: userModel.success,
        messages: userModel.messages,
        data: userModel.data,
      );

      print('User ID from auto-login: ${state.data?[0].user?.sId}'); // Accessing User ID from the first Data object
      return true;
    } else {
      print('Necessary fields are missing in SharedPreferences.');
      return false;
    }
  } catch (e, stackTrace) {
    // Log the error for debugging purposes
    print('Error while parsing user data: $e');
    print(stackTrace);
    return false;
  }
}

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    WidgetRef ref,
  ) async {
    final auth = ref.read(firebaseAuthProvider);
    var loader = ref.read(loadingProvider.notifier);
    var codeSentNotifier = ref.read(codeSentProvider.notifier);
    //loader.state = true;
    var pref = await SharedPreferences.getInstance();

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // loader.state = false;
          await auth.signInWithCredential(credential);
         
        },
        verificationFailed: (FirebaseAuthException e) {
          // loader.state = false;
          print("Verification failed: ${e.message}");
        
        },
        codeSent: (String verificationId, int? resendToken) {
          // loader.state = false;
          print("Verification code sent: $verificationId");
         // state = PhoneAuthState(verificationId: verificationId);
         pref.setString("verificationid", verificationId);
          codeSentNotifier.state = true; // Update the codeSentProvider
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // loader.state = false;
          print("Auto-retrieval timeout. Verification ID: $verificationId");
       
        },
      );
    } catch (e) {
      loader.state = false;
      print("Error during phone verification: $e");
     
    }
  }

  Future<void> signInWithPhoneNumber(String smsCode, WidgetRef ref) async {
    final authState = ref.watch(firebaseAuthProvider);
    final loadingState = ref.watch(loadingProvider.notifier);
     var pref = await SharedPreferences.getInstance();
     String? verificationid = pref.getString('verificationid');
     print('verificatiomid...$verificationid ');
    
    try {
      loadingState.state = true;

   

      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationid!, smsCode: smsCode);

      await authState.signInWithCredential(credential).then((value) async {
        if (value.user != null) {
          print("Phone verification successful.");

          // Generate a custom UID
          String customUid =
              "#${(100000 + DateTime.now().millisecondsSinceEpoch % 900000)}";
          String? firebaseToken = await value.user?.getIdToken();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firebaseToken', firebaseToken!);


           // Send phone number and role to API
          await sendPhoneNumberAndRoleToAPI(
            phoneNumber: value.user!.phoneNumber!,
            role: "user", // Assign the role as needed
          );

          print("User data stored locally and sent to API.");

        }
      });

      loadingState.state = false;
    } catch (e) {
      loadingState.state = false;
      print("Error during phone verification: $e");
    
    } finally {
      loadingState.state = false;
    }
  }
  Future<void> sendPhoneNumberAndRoleToAPI({
    required String phoneNumber,
    required String role,
  }) async {
    const String apiUrl = Bbapi.login; // Replace with your API URL

    final prefs = await SharedPreferences.getInstance();
     print('phone number$phoneNumber,role$role');
     
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_API_TOKEN", // Add token if needed
        },
        body: json.encode({
          "mobile": phoneNumber.toString(),
          "role": role.toString(),
        }),
      );
      

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Data successfully sent to the API.");
        var userDetails = json.decode(response.body);
        UserModel user = UserModel.fromJson(userDetails);
        print("Response: ${response.body}");

        // Debug: Print the user data to check if it's correct
         print("User Data to Save: ${user.toJson()}");

         //state=state.copyWith(messages:userDetails['message'],
        
         //data: [Data.fromJson(userDetails['user'])],); // Assuming userDetails['user'] maps to the Data model
         state = user;
         final userData = json.encode({
        //'accessToken': user.data?[0].accessToken,
        'statusCode':user.statusCode,
        'success':user.success,
        'messages':user.messages,
        'data': user.data?.map((data) => data.toJson()).toList(), // Serialize all Data objects
     });
         // Debug: Print userData before saving
          print("User Data to Save in SharedPreferences: $userData");

         await prefs.setString('userData', userData);

      } else {
        print("Failed to send data to the API. Status code: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Error while sending data to the API: $e");
    }
  }  
  
  Future<String> generateUniqueUid() async {
    Random random = Random();
    String uniqueUid;

    // Generate a random 6-digit UID
    int randomNumber =
        100000 + random.nextInt(900000); // Range: 100000 to 999999
    uniqueUid = "$randomNumber#";

    return uniqueUid;
  }
  Future<void> deleteAccount(String?userId, String?token) async {
  final String apiUrl = "${Bbapi.deleteAccount}/$userId"; // Replace with your API URL for delete account
  final loadingState = ref.read(loadingProvider.notifier);

  try {
    loadingState.state = true; // Show loading state
final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken = await restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = accessToken.toString();
          }
        },
      );
    final response = await client.delete(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Include the token
      },
    //   body: json.encode({
    //     "userId": userId, // Send the user ID to the API
    //   }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Account successfully deleted.");

      // Optionally, clear local user data (e.g., shared preferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to a different screen (e.g., login or onboarding)
      print("Navigating to login screen after account deletion.");
    } else {
      print("Failed to delete account. Status code: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("Error while deleting account: $e");
  } finally {
    loadingState.state = false; // Hide loading state
  }
}
Future<String> restoreAccessToken() async {
    
    final url =
         Bbapi.refreshToken; 

    final prefs = await SharedPreferences.getInstance();

    try {
      var response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': state.data![0].accessToken!,
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({"refresh_token": state.data![0].accessToken}),
      );

      var userDetails = json.decode(response.body);
      print('restore token response $userDetails');
      switch (response.statusCode) {
        case 401:
          // Handle 401 Unauthorized
          // await logout();
          // await tryAutoLogin();
          print("shared preferance ${prefs.getString('userTokens')}");
      
          break;
       // loading(false); // Update loading state
        case 200:
  print("Refresh access token success");

  // Extract the new access token and refresh token
  final newAccessToken = userDetails['data']['access_token'];
  final newRefreshToken = userDetails['data']['refresh_token'];

  print('New access token: $newAccessToken');
  print('New refresh token: $newRefreshToken');

  // Retrieve existing user data from SharedPreferences
  String? storedUserData = prefs.getString('userData');

  if (storedUserData != null) {
    // Parse the stored user data into a UserModel object
    UserModel user = UserModel.fromJson(json.decode(storedUserData));

    // Update the accessToken and refreshToken in the existing data model
    user = user.copyWith(
      data: [
        user.data![0].copyWith(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        ),
      ],
    );
        // Convert the updated UserModel back to JSON
    final updatedUserData = json.encode({
      'statusCode': user.statusCode,
      'success': user.success,
      'messages': user.messages,
      'data': user.data?.map((data) => data.toJson()).toList(),
    });

    // Debug: Print updated user data before saving
    print("Updated User Data to Save in SharedPreferences: $updatedUserData");

    // Save the updated user data in SharedPreferences
    await prefs.setString('userData', updatedUserData);

    // Debug: Print user data after saving
    print("User Data saved in SharedPreferences: ${prefs.getString('userData')}");
  } else {
    // Handle the case where there is no existing user data in SharedPreferences
    print("No user data found in SharedPreferences.");
  }

        // loading(false); // Update loading state
      }
    } on FormatException catch (formatException) {
      print('Format Exception: ${formatException.message}');
      print('Invalid response format.');
    } on HttpException catch (httpException) {
      print('HTTP Exception: ${httpException.message}');
    } catch (e) {
      print('General Exception: ${e.toString()}');
      if (e is Error) {
        print('Stack Trace: ${e.stackTrace}');
      }
    }
    return state.data![0].accessToken!;
  }
}




final userProvider = StateNotifierProvider<PhoneAuthNotifier, UserModel>((ref) {
  return PhoneAuthNotifier(ref);
});



