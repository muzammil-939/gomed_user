import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/Login_screen.dart';

class LogoutNotifier extends StateNotifier<void> {
  LogoutNotifier() : super(null);

  Future<void> logout(BuildContext context) async {
    final shouldLogout = await _showLogoutDialog(context);
    if (shouldLogout) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data
      // Navigate to the LoginScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss dialog and return false
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Dismiss dialog and return true
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    ) ?? false; // Default to false if dialog is dismissed without selection
  }
}

final logoutProvider = StateNotifierProvider<LogoutNotifier, void>(
  (ref) => LogoutNotifier(),
);
