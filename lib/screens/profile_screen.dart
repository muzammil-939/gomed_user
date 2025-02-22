import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? _selectedImage;
  final double maxImageSize = 5 * 1024 * 1024; // 5 MB in bytes
  String? _profileImageUrl; // Store the URL from the model

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userModel = ref.watch(userProvider);
    if (userModel.data != null && userModel.data!.isNotEmpty) {
      final user = userModel.data![0].user;
      nameController.text = user?.ownerName ?? "";
      emailController.text = user?.email ?? "";
      phoneController.text = user?.mobile ?? "";
      _profileImageUrl = user?.profileImage?.isNotEmpty == true ? user?.profileImage![0] : null; // Get the UR
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final File imageFile = File(image.path);
      final int imageSize = await imageFile.length();

      if (imageSize <= maxImageSize) {
        setState(() {
          _selectedImage = imageFile;
        });
      } else {
        _showSizeError();
      }
    }
  }

  void _showSizeError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Image Too Large"),
        content: const Text("The selected image exceeds the size limit of 5 MB. Please choose a smaller image."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
       appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1BA4CA), // Custom background color
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : _profileImageUrl != null // Show network image if available
                              ? CachedNetworkImageProvider(_profileImageUrl!) // Use cached network image
                          : null,
                      child: _selectedImage == null && _profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    nameController.text.isNotEmpty ? nameController.text : "User Name",
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
                onPressed: () async {
                  if (isEditing) {
                    try {
                      await ref.read(userProvider.notifier).updateProfile(
                        nameController.text,
                        emailController.text,
                        phoneController.text,
                        _selectedImage,
                        ref,
                      );
                      setState(() {
                        
                      });
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Profile updated successfully!")),
                      // );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error updating profile: $e")),
                      );
                    }
                  }
                  setState(() {
                    isEditing = !isEditing;
                  });
                },  
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.green : Colors.blue,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.015,
                    horizontal: MediaQuery.of(context).size.width * 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save' : 'Edit Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a photo"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
