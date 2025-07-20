import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
// import 'package:geocoding/geocoding.dart' as geo;
import 'dart:async';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive to prevent rebuilds
  
  bool isEditing = false;
  bool isEditingLocation = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  File? _selectedImage;
  String? _profileImageUrl;
  final double maxImageSize = 5 * 1024 * 1024;

  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  LatLng _currentPosition = const LatLng(17.4065, 78.4772); // Default to Hyderabad (Kukatpally area)
  Set<Marker> _markers = {};
  String _currentAddress = "No location selected";
  double? lat;
  double? lng;
  bool _isMapReady = false;
  bool _isLoadingLocation = false;
  
  // Add debounce timer for search
  Timer? _searchDebounce;
  
  // ImagePicker instance - reuse to prevent buffer issues
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Add post frame callback to ensure proper initialization
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _initializeMap();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    _requestLocationPermission().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeMap(); // Your method that calls get current position
      });
    });
}
Future<void> _requestLocationPermission() async {
  final status = await Permission.location.request();
  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}



  void _initializeMap() {
    // Initialize map-related data here
    if (mounted) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    // Properly dispose of all resources
    _searchDebounce?.cancel();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();

    searchController.dispose();
    
    // Dispose map controller safely
    if (_mapController != null) {
      _mapController!.dispose();
    }
    
    super.dispose();
  }

  void _loadUserData() {
    final userModel = ref.watch(userProvider);
    if (userModel.data != null && userModel.data!.isNotEmpty) {
      final user = userModel.data![0].user;
      if (mounted) {
        setState(() {
          nameController.text = user?.name ?? "";
          emailController.text = user?.email ?? "";
          phoneController.text = user?.mobile ?? "";
          addressController.text = user?.address ?? "";
          _profileImageUrl = user?.profileImage?.isNotEmpty == true 
              ? user?.profileImage![0] 
              : null;
          
          // Load saved location if available
          if (user?.location?.latitude != null && user?.location?.longitude != null) {
            lat = double.tryParse(user?.location?.latitude.toString() ?? '') ?? 0.0;
            lng = double.tryParse(user?.location?.longitude.toString() ?? '') ?? 0.0;
            _currentPosition = LatLng(lat!, lng!);
            _currentAddress = user!.address ?? "Saved location";
            _updateMapMarker();
          }
        });
      }
    }
  }

  void _updateMapMarker() async {
    if (lat != null && lng != null && mounted) {
      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId("selectedLocation"),
          position: LatLng(lat!, lng!),
          infoWindow: InfoWindow(
            title: "Selected Location", 
            snippet: _currentAddress
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });

      // Safely animate camera
      if (_isMapReady && _mapControllerCompleter.isCompleted) {
        try {
          final GoogleMapController controller = await _mapControllerCompleter.future;
          if (mounted) {
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(lat!, lng!), zoom: 16),
              ),
            );
          }
        } catch (e) {
          print("Error animating camera: $e");
        }
      }
    }
  }

  // // Debounced search function to prevent excessive API calls
  // void _onSearchChanged(String query) {
  //   if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
  //   _searchDebounce = Timer(const Duration(milliseconds: 500), () {
  //     if (query.trim().isNotEmpty) {
  //       _searchAndNavigate(query);
  //     }
  //   });
  // }

  // Search and navigate to location - with better error handling
  // Future<void> _searchAndNavigate(String query) async {
  //   if (query.trim().isEmpty || !mounted) return;
    
  //   setState(() {
  //     _isLoadingLocation = true;
  //   });

  //   try {
  //     // Add timeout for geocoding requests
  //     List<geo.Location> locations = await locationFromAddress(query)
  //         .timeout(const Duration(seconds: 10));
          
  //     if (locations.isNotEmpty && mounted) {
  //       final geo.Location location = locations.first;
  //       final latLng = LatLng(location.latitude, location.longitude);

  //       // Get address details with timeout
  //       List<Placemark> placemarks = await placemarkFromCoordinates(
  //         location.latitude,
  //         location.longitude,
  //       ).timeout(const Duration(seconds: 10));

  //       String address = placemarks.isNotEmpty
  //           ? _formatAddress(placemarks.first)
  //           : query;

  //       if (mounted) {
  //         setState(() {
  //           _currentPosition = latLng;
  //           _currentAddress = address;
  //           lat = location.latitude;
  //           lng = location.longitude;
  //           // Update address field if editing location
  //           if (isEditingLocation) {
  //             addressController.text = address;
  //           }
  //         });

  //         _updateMapMarker();
          
  //         // Clear search field after successful search
  //         searchController.clear();
  //       }
  //     } else if (mounted) {
  //       _showErrorSnackBar("Location not found");
  //     }
  //   } on TimeoutException {
  //     if (mounted) {
  //       _showErrorSnackBar("Search timeout. Please check your internet connection.");
  //     }
  //   } catch (e) {
  //     print("Search error: $e");
  //     if (mounted) {
  //       _showErrorSnackBar("Unable to find location. Please try again.");
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingLocation = false;
  //       });
  //     }
  //   }
  // }

  // Helper method to format address
  String _formatAddress(Placemark placemark) {
    List<String?> addressComponents = [
      placemark.name,
      placemark.street,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ].where((component) => component != null && component.isNotEmpty).toList();
    
    return addressComponents.join(', ');
  }

  // Get current location with better error handling
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    final loc.Location location = loc.Location();

    try {
      // Check location service
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled && mounted) {
          _showErrorSnackBar("Location service is disabled");
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      // Check location permission
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted && mounted) {
          _showErrorSnackBar("Location permission denied");
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      // Configure location settings
      await location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 10,
      );
      
      // Get location with timeout
      loc.LocationData locationData = await location.getLocation()
          .timeout(const Duration(seconds: 15));
      
      if (locationData.latitude == null || locationData.longitude == null) {
        if (mounted) {
          _showErrorSnackBar("Unable to get current location");
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      lat = locationData.latitude;
      lng = locationData.longitude;

      // Get address with timeout
      List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lng!)
          .timeout(const Duration(seconds: 10));
          
      if (placemarks.isNotEmpty && mounted) {
        String address = _formatAddress(placemarks.first);

        setState(() {
          _currentPosition = LatLng(lat!, lng!);
          _currentAddress = address;
          searchController.text="";
          // Update address field if editing location
          if (isEditingLocation) {
            addressController.text = address;
          }

        });

        _updateMapMarker();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Current location updated")),
          );
        }
      }
    } on TimeoutException {
      if (mounted) {
        _showErrorSnackBar("Location timeout. Please try again.");
      }
    } catch (e) {
      print("Error getting current location: $e");
      if (mounted) {
        _showErrorSnackBar("Error getting current location. Please check your location settings.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // Map tap handler with better error handling
  void _onMapTap(LatLng position) async {
    if (!isEditingLocation || !mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      ).timeout(const Duration(seconds: 10));
      
      String address = placemarks.isNotEmpty
          ? _formatAddress(placemarks.first)
          : "Selected location";

      if (mounted) {
        setState(() {
          lat = position.latitude;
          lng = position.longitude;
          _currentPosition = position;
          _currentAddress = address;
           searchController.text="";
          if (isEditingLocation) {
            addressController.text = address;
          }
        });

        _updateMapMarker();
      }
    } catch (e) {
      print("Error getting address for tapped location: $e");
      if (mounted) {
        setState(() {
          lat = position.latitude;
          lng = position.longitude;
          _currentPosition = position;
          _currentAddress = "Selected location";
          if (isEditingLocation) {
            addressController.text = "Selected location";
          }
        });
        _updateMapMarker();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Fixed image picker with proper resource management
  Future<void> _pickImage(ImageSource source) async {
    if (!mounted) return;
    
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false, // Reduce memory usage
      );

      if (image != null && mounted) {
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
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        _showErrorSnackBar("Error selecting image");
      }
    }
  }

  void _showSizeError() {
    if (!mounted) return;
    
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1BA4CA),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image and Name
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: isEditing ? () => _showImageSourceActionSheet(context) : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
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
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    nameController.text.isNotEmpty ? nameController.text : "User Name",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Profile Fields
            _buildProfileField("Name", nameController, isEditing, Icons.person),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField("Email", emailController, isEditing, Icons.email),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField("Phone", phoneController, isEditing, Icons.phone),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField("Address", addressController, isEditing && isEditingLocation, Icons.location_on),
            SizedBox(height: screenHeight * 0.04),

            // Location Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Location:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isEditing)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isEditingLocation = !isEditingLocation;
                      });
                    },
                    icon: Icon(isEditingLocation ? Icons.check : Icons.edit_location),
                    label: Text(isEditingLocation ? "Done" : "Edit Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditingLocation ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),

            // Current Address Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: TextStyle(
                        fontSize: 14, 
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isEditingLocation) ...[
              SizedBox(height: screenHeight * 0.02),

              // // Search Bar with debouncing
              // TextField(
              //   controller: searchController,
              //   onChanged: _onSearchChanged, // Use debounced search
              //   onSubmitted: (value) => _searchAndNavigate(value),
              //   decoration: InputDecoration(
              //     hintText: "Search location...",
              //     prefixIcon: const Icon(Icons.search),
              //     suffixIcon: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         if (_isLoadingLocation)
              //           const Padding(
              //             padding: EdgeInsets.all(12.0),
              //             child: SizedBox(
              //               width: 20,
              //               height: 20,
              //               child: CircularProgressIndicator(strokeWidth: 2),
              //             ),
              //           ),
              //         IconButton(
              //           icon: const Icon(Icons.clear),
              //           onPressed: () {
              //             searchController.clear();
              //             _searchDebounce?.cancel();
              //           },
              //         ),
              //       ],
              //     ),
              //     filled: true,
              //     fillColor: Colors.white,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              // ),
             GooglePlaceAutoCompleteTextField(
                  textEditingController: searchController,
                  googleAPIKey: "AIzaSyCMADwyS3eoxJ5dQ_iFiWcDBA_tJwoZosw", // Make sure your key has Places API enabled
                  inputDecoration: InputDecoration(
                    hintText: "Search location...",
                    prefixIcon: const Icon(Icons.search),
                    // suffixIcon: IconButton(
                    //   icon: const Icon(Icons.clear),
                    //   onPressed: () {
                    //     searchController.clear();
                    //   },
                    // ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  debounceTime: 800,
                  isLatLngRequired: true,
                  countries: ["in"],
                  getPlaceDetailWithLatLng: (prediction) {
                    if (prediction.lat != null && prediction.lng != null) {
                    double newLat = double.parse(prediction.lat!);
                    double newLng = double.parse(prediction.lng!);
                      String newAddress = prediction.description ?? "";

                      setState(() {
                        lat = newLat;
                        lng = newLng;
                        _currentPosition = LatLng(newLat, newLng);
                        _currentAddress = newAddress;
                        addressController.text = newAddress;
                      });

                      _updateMapMarker();
                    }
                  },
                itemClick: (prediction) {
                FocusScope.of(context).unfocus();
                searchController.text = prediction.description!;
                searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description!.length),
                );
              },
                ),

              SizedBox(height: screenHeight * 0.02),

              // Location Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Current Location"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              
              Text(
                "Tap on the map to select a location",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            SizedBox(height: screenHeight * 0.02),

            // Google Maps Widget - Improved with better resource management
            Container(
              height: isEditingLocation ? 400 : 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                 BoxShadow(
                    color: Colors.grey.withValues(alpha: 26),
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: !isEditingLocation,
                onTap: isEditingLocation ? _onMapTap : null,
                zoomControlsEnabled: true,
                compassEnabled: true,
                mapToolbarEnabled: false,
                buildingsEnabled: false,
                trafficEnabled: false,
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: true,
                liteModeEnabled: false,
                padding: const EdgeInsets.all(8.0),
                cameraTargetBounds: CameraTargetBounds.unbounded,
                minMaxZoomPreference: const MinMaxZoomPreference(3.0, 20.0),

                // ✅ Replace deprecated setMapStyle with this:
                style: '''
                  [
                    {
                      "featureType": "poi.business",
                      "elementType": "labels",
                      "stylers": [{"visibility": "off"}]
                    },
                    {
                      "featureType": "transit",
                      "elementType": "labels",
                      "stylers": [{"visibility": "off"}]
                    }
                  ]
                ''',

                onMapCreated: (GoogleMapController controller) async {
                  print("🗺️ Map created successfully!");
                  if (!_mapControllerCompleter.isCompleted) {
                    _mapControllerCompleter.complete(controller);
                    _mapController = controller;
                  }

                  if (mounted) {
                    setState(() {
                      _isMapReady = true;
                    });

                    if (lat != null && lng != null) {
                      print("📍 Animating to saved location: $lat, $lng");
                      try {
                        await controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: LatLng(lat!, lng!), zoom: 16),
                          ),
                        );
                      } catch (e) {
                        print("Error animating to saved location: $e");
                      }
                    }
                  }
                },
              ),

              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // Save/Edit Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (isEditing) {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

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
                      
                      // Hide loading indicator
                      if (mounted) {
                        Navigator.of(context).pop();
                        
                        if (results == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile Updated Successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to update profile"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Hide loading indicator
                      if (mounted) {
                        Navigator.of(context).pop();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error updating profile: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                  if (mounted) {
                    setState(() {
                      isEditing = !isEditing;
                      if (!isEditing) {
                        isEditingLocation = false;
                      }
                    });
                  }
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
                  isEditing ? 'Save Profile' : 'Edit Profile',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, bool isEnabled, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: isEnabled,
          keyboardType: label == "Email" ? TextInputType.emailAddress : 
                       label == "Phone" ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isEnabled ? Colors.blue : Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Profile Picture",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text("Take a photo"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text("Choose from gallery"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



