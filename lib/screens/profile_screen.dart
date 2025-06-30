import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc ;
import 'package:geocoding/geocoding.dart' ;// Import geocoding package
import 'package:geocoding/geocoding.dart' as geo;


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
  final TextEditingController addressController = TextEditingController();
    final TextEditingController searchController = TextEditingController();

  File? _selectedImage;
  String? _profileImageUrl;
  final double maxImageSize = 5 * 1024 * 1024;

  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(37.7749, -122.4194);
  Set<Marker> _markers = {};
  String _currentAddress = "Fetching location..."; // Holds user's address
  double? lat;
  double? lng;
  bool _isMapReady = false;
  bool _isLoadingLocation = true;


  
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }
  @override
void initState() {
  super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    }); // Keep location fetch here, it's fine
}


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    searchController.dispose(); // <-- Dispose search controller
    super.dispose();
  }

  // 🆕 Search Method
  Future<void> _searchAndNavigate(String query) async {
    try {
      List<geo.Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final geo.Location location = locations.first;

        final latLng = LatLng(location.latitude, location.longitude);

        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        String address = placemarks.isNotEmpty
            ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}"
            : "Unknown location";

        setState(() {
          _currentPosition = latLng;
         _currentAddress = address;
        //  addressController.text = address; // <-- Optional: autofill address field
          lat = location.latitude;
          lng = location.longitude;

          _markers.clear();
          _markers.add(Marker(
            markerId: const MarkerId("searchLocation"),
            position: latLng,
            infoWindow: InfoWindow(title: "Searched Location", snippet: address),
          ));
        });

       if (_isMapReady) {
  _mapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat!, lng!), zoom: 18),
    ),
  );
}

      }
    } catch (e) {
      print("Search error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to find location")),
      );
    }
  }
 

  void _loadUserData() {
    final userModel = ref.watch(userProvider);
    if (userModel.data != null && userModel.data!.isNotEmpty) {
      final user = userModel.data![0].user;
      setState(() {
        nameController.text = user?.name ?? "";
        emailController.text = user?.email ?? "";
        phoneController.text = user?.mobile ?? "";
        addressController.text = user?.address ?? "";
        _profileImageUrl = user?.profileImage?.isNotEmpty == true ? user?.profileImage![0] : null;
      });
    }
  }

    Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final File imageFile = File(image.path);
      final int imageSize = await imageFile.length();

      if (imageSize <= maxImageSize) {
        //  await Future.delayed(const Duration(milliseconds: 200)); // ✅ short delay to avoid GPU overload
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

Future<void> getCurrentLocation() async {
  print("📍 Entered getCurrentLocation");

  final loc.Location location = loc.Location();

  try {
    bool serviceEnabled = await location.serviceEnabled();
    print("🔧 Location service enabled: $serviceEnabled");

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      print("🛠️ Requested service enable: $serviceEnabled");
      if (!serviceEnabled) {
        print("❌ User denied enabling location service.");
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    print("🔐 Initial permission status: $permissionGranted");

    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      print("📤 Requested permission: $permissionGranted");
      if (permissionGranted != loc.PermissionStatus.granted) {
        print("❌ Location permission not granted");
        return;
      }
    }

    print("✅ Permissions and service are fine. Fetching location...");
    await location.changeSettings(accuracy: loc.LocationAccuracy.high);

    loc.LocationData locationData = await location.getLocation();
    lat = locationData.latitude;
    lng = locationData.longitude;

    print("📍 Got coordinates: lat=$lat, lng=$lng");

    if (lat == null || lng == null) {
      print("⚠️ Location returned null values.");
      return;
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lng!);
    Placemark place = placemarks.first;

    String address = "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    print("📬 Reverse geocoded address: $address");

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(lat!, lng!);
        _currentAddress = address;
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId("currentLocation"),
          position: LatLng(lat!, lng!),
          infoWindow: InfoWindow(title: "Your Location", snippet: address),
        ));
      });
    }

    if (_isMapReady) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat!, lng!), zoom: 18),
        ),
      );
    }
  } catch (e) {
    print("❗ Error in getCurrentLocation: $e");
  }
}




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1BA4CA),
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
                          : _profileImageUrl != null
                              ? CachedNetworkImageProvider(_profileImageUrl!)
                              : null,
                      child: _selectedImage == null && _profileImageUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
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
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField("Address", addressController, isEditing),
            SizedBox(height: screenHeight * 0.04),
            
            // 🆕 Search Bar
            TextField(
              controller: searchController,
              onSubmitted: (value) => _searchAndNavigate(value),
              decoration: InputDecoration(
                hintText: "Search location...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Show Address
            const Text(
              "Location:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentAddress,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Google Maps Widget
            SizedBox(
              height: 300,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  setState(() {
                 _isMapReady = true;
                 });
                },
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
               
              ),
            ),

            SizedBox(height: screenHeight * 0.04),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (isEditing) {
                    try {
                     final results = await ref.read(userProvider.notifier).updateProfile(
                        nameController.text,
                        emailController.text,
                        phoneController.text,
                        addressController.text,
                        lat,
                        lng,
                        _selectedImage,
                        ref,
                      );
                     // setState(() {}); 
                     if (results == true ){
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile Updated Successfull!")),
                      );
                     }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to updating profile:")),
                      );
                     }
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
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.3,
                  ),
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
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
