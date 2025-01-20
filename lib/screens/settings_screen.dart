import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
              },
            ),
            _buildSettingsItem(
              context,
              label: 'Payment history',
              onTap: () {
                // Navigate to Payment History
              },
            ),
            _buildSettingsItem(
              context,
              label: 'Notification settings',
              onTap: () {
                // Navigate to Notification Settings
              },
            ),
            _buildSettingsItem(
              context,
              label: 'Wallet',
              onTap: () {
                // Navigate to Wallet
              },
            ),
            _buildSettingsItem(
              context,
              label: 'Log out',
              onTap: () {
                // Log out functionality
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
                // Delete Account functionality
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
}
