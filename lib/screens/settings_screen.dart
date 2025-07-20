import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gomed_user/providers/auth_state.dart';

import 'package:gomed_user/providers/logout_notifier.dart';
import 'package:gomed_user/screens/login_screen.dart';
import 'package:gomed_user/screens/profile_screen.dart';


class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
 @override
  ConsumerState<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage>{

  @override
  Widget build(BuildContext context) {
    final logoutNotifier = ref.read(logoutProvider.notifier);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsItem(
              context,
              label: 'Profile settings',
              onTap: () {
                // Navigate to Profile Settings
                Navigator.push(context, MaterialPageRoute(builder:(context) =>ProfilePage()));
              },
            ),
            // _buildSettingsItem(
            //   context,
            //   label: 'Payment history',
            //   onTap: () {
            //     // Navigate to Payment History
            //   },
            // ),
            // _buildSettingsItem(
            //   context,
            //   label: 'Notification settings',
            //   onTap: () {
            //     // Navigate to Notification Settings
            //   },
            // ),
            // _buildSettingsItem(
            //   context,
            //   label: 'Wallet',
            //   onTap: () {
            //     // Navigate to Wallet
            //   },
            // ),
            _buildSettingsItem(
              context,
              label: 'Log out',
              onTap: () {
               logoutNotifier.logout(context); // Log out functionality
              },
            ),
            SizedBox(height: screenWidth * 0.1),
            GestureDetector(
              onTap: () {
                // Navigate to Review Page
              },
              child: const Text(
                'Leave a Review',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
             GestureDetector(
              onTap: () {
                _showDeleteAccountDialog(context,ref);
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(  
                  color: Colors.red,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required String label, required Function() onTap}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }

 void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  final userModel = ref.read(userProvider); // Retrieve UserModel from the provider
  final userId = userModel.data?[0].user!.sId; // Get user ID, default to empty string if null
  final token = userModel.data?[0].accessToken; // Get token, default to empty string if null


  //    if (userId.isEmpty || token.isEmpty) {
  //   print("User ID or token is missing.");
  //   return;
  // }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
               // Close the dialog
           ref.read(userProvider.notifier).deleteAccount(userId,token);
               // Call the delete account method
                _removeAccount(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
 void _removeAccount(BuildContext context) {
    // Add your account deletion logic here (e.g., API call or local storage update)

    // Example: Show a snackbar and navigate back
    Navigator.of(context).pop(); // Close the dialog
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Account deleted successfully')),
    );

    // Navigate to login or onboarding page after account deletion
   // Navigator.of(context).pushReplacementNamed('/loginscreen');
   
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      
  }
}

 