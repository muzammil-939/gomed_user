import 'dart:async'; // Import to use Timer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/providers/auth_state.dart';
import '../providers/firebase_auth.dart';
import '../providers/loader.dart';
import 'home_page.dart';
import 'package:gomed_user/model/auth.dart'; // Import the UserModel
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController phoneController = TextEditingController(text: "+91");
  final TextEditingController otpController = TextEditingController();
  bool isKeyboardVisible = false;
  bool isLoading = false; // To control loading state
  int countdown = 0; // Countdown timer for OTP
  late Timer _timer; // Timer object

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel(); // Cancel the timer when the screen is disposed
    }
    super.dispose();
  }

  void startOtpCountdown() {
    setState(() {
      countdown = 60; // Start countdown at 60 seconds
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

 

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(loadingProvider);
    final authNotifier = ref.read(userProvider.notifier);

    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/kiitm_final_out.jpg', // Replace with your asset path
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.8, // Adjust width as needed
                ),
              ),
              const SizedBox(height: 100),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F7F2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(200),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Phone Number'),
                        _buildTextField(
                          hintText: 'Enter your phone number',
                          controller: phoneController,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('OTP'),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                hintText: 'Enter OTP',
                                controller: otpController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Consumer(
                              builder: (context, ref, child) {
                                final phoneAuthNotifier = ref.watch(userProvider.notifier);
                               // final loader = ref.watch(loadingProvider);

                                return ElevatedButton(
                                  onPressed: countdown > 0
                                      ? null
                                      : () async {
                                          String phoneNumber = phoneController.text.trim();
                                          bool isValid = phoneNumber.startsWith("+91") &&
                                              phoneNumber.length == 13 &&
                                              RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber.substring(3));

                                          if (isValid) {
                                            // Attempt to send the OTP
                                            await phoneAuthNotifier.verifyPhoneNumber(phoneNumber, ref);
                                            startOtpCountdown(); // Start the countdown
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please enter a valid 10-digit phone number.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF82CDD8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                     child: //isLoading
                                      //? //const CircularProgressIndicator(color: Colors.white):
                                      Text(
                                          countdown > 0 ? '$countdown sec' : 'Send OTP',
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // OTP Verification Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              String smsCode = otpController.text.trim();
                              if (smsCode.isNotEmpty) {
                                try {
                                   setState(() {
                                      isLoading = true; // Start loading
                                   });
                                  // Verify the OTP
                                  await ref.read(userProvider.notifier).signInWithPhoneNumber(smsCode, ref);


                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("OTP Verified Successfully!")),
                                  );

                                  // Navigate to HomePage
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => const HomePage()),
                                  // );
                                } catch (e) {
                                   setState(() {
                                      isLoading = false; // Stop loading if there was an error
                                   });
                                  // Show error message if OTP verification fails
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed to verify OTP: $e")),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter the OTP.")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F9548),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Stack(
                               alignment: Alignment.center,
                               children: [
                                 const Text(
                                   'Verify',
                                   style: TextStyle(
                                     color: Colors.white,
                                     fontSize: 16,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 if (isLoading) 
                                   const CircularProgressIndicator(color: Colors.white),
                               ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (!value.startsWith("+91")) {
          phoneController.text = "+91";
          phoneController.selection = TextSelection.fromPosition(
            TextPosition(offset: phoneController.text.length),
          );
        }
      },
    );
  }
}
