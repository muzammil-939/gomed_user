import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController(text: "John Doe");
  final TextEditingController emailController = TextEditingController(text: "johndoe@example.com");
  final TextEditingController phoneController = TextEditingController(text: "1234567890");

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/user_profile.png'), // Replace with actual profile image
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "John Doe",  // Replace with actual user name
                    style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            _buildProfileField("Name", nameController, isEditing),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField("Email", emailController, isEditing),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField("Phone", phoneController, isEditing),
            SizedBox(height: screenHeight * 0.04),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isEditing) {
                      // Save action (could be saving to database or updating state)
                      print("Saved changes: ${nameController.text}, ${emailController.text}, ${phoneController.text}");
                    }
                    isEditing = !isEditing;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.green : Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015, horizontal: screenWidth * 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save' : 'Edit Profile',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: isEditing,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey[200],
          ),
        ),
      ],
    );
  }
}
