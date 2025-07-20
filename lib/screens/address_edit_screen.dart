import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';

class AddressEditScreen extends StatefulWidget {
  final String? currentAddress;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentLocationAddress;

  const AddressEditScreen({
    Key? key,
    this.currentAddress,
    this.currentLatitude,
    this.currentLongitude,
    this.currentLocationAddress,
  }) : super(key: key);

  @override
  _AddressEditScreenState createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  late TextEditingController addressController;
  late TextEditingController locationSearchController;
  
  // Focus nodes to control focus explicitly
  final FocusNode addressFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  
  String? updatedAddress;
  double? updatedLatitude;
  double? updatedLongitude;
  String locationAddress = "";
  
  bool hasAddressChanged = false;
  bool hasLocationChanged = false;
  
  // Flag to prevent address updates when location is being changed
  bool isUpdatingLocation = false;
  
  // Current location loading state
  bool isGettingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current values
    addressController = TextEditingController(text: widget.currentAddress ?? "");
    locationSearchController = TextEditingController();
    
    // Set initial values
    updatedAddress = widget.currentAddress;
    updatedLatitude = widget.currentLatitude;
    updatedLongitude = widget.currentLongitude;
    locationAddress = widget.currentLocationAddress ?? "Location not selected";
    
    // Listen for address changes - only when user is typing
    addressController.addListener(() {
      if (!isUpdatingLocation && addressController.text != widget.currentAddress) {
        setState(() {
          hasAddressChanged = true;
          updatedAddress = addressController.text;
        });
      }
    });

    // Listen for location search changes
    locationSearchController.addListener(() {
      if (locationSearchController.text.isEmpty) {
        setState(() {
          updatedLatitude = widget.currentLatitude;
          updatedLongitude = widget.currentLongitude;
          locationAddress = widget.currentLocationAddress ?? "Location not selected";
          hasLocationChanged = false;
        });
      }
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    locationSearchController.dispose();
    addressFocusNode.dispose();
    locationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          // Only update locationAddress, not the main address field
          locationAddress = "${place.street}, ${place.locality}, ${place.country}";
          hasLocationChanged = true;
        });
      }
    } catch (e) {
      setState(() {
        locationAddress = "Could not fetch location";
      });
    }
  }

  // // Get current location using GPS
  // Future<void> _getCurrentLocation() async {
  //   print("Getting current location..."); // Debug log
    
  //   setState(() {
  //     isGettingCurrentLocation = true;
  //   });

  //   try {
  //     // Check if location services are enabled
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       print("Location services are disabled");
  //       _showLocationServiceDialog();
  //       setState(() {
  //         isGettingCurrentLocation = false;
  //       });
  //       return;
  //     }

  //     // Check location permissions
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       print("Location permission denied, requesting...");
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         print("Location permission denied after request");
  //         _showLocationPermissionDialog();
  //         setState(() {
  //           isGettingCurrentLocation = false;
  //         });
  //         return;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       print("Location permission denied forever");
  //       _showLocationPermissionDialog();
  //       setState(() {
  //         isGettingCurrentLocation = false;
  //       });
  //       return;
  //     }

  //     print("Getting current position...");
  //     // Get current position
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );

  //     print("Got position: ${position.latitude}, ${position.longitude}");
      
  //     isUpdatingLocation = true;
      
  //     setState(() {
  //       updatedLatitude = position.latitude;
  //       updatedLongitude = position.longitude;
  //     });

  //     await _getAddressFromCoordinates(position.latitude, position.longitude);
      
  //     setState(() {
  //       isGettingCurrentLocation = false;
  //     });
      
  //     isUpdatingLocation = false;

  //     // Show success message
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Current location updated successfully!"),
  //           backgroundColor: Colors.green,
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //     }

  //   } catch (e) {
  //     print("Error getting current location: $e");
  //     setState(() {
  //       isGettingCurrentLocation = false;
  //       locationAddress = "Error getting current location: $e";
  //     });
  //     isUpdatingLocation = false;
      
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Error getting location: $e"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // void _showLocationServiceDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Location Services Disabled"),
  //       content: const Text("Please enable location services to use this feature."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("OK"),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await Geolocator.openLocationSettings();
  //           },
  //           child: const Text("Open Settings"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showLocationPermissionDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Location Permission Required"),
  //       content: const Text("This app needs location permission to get your current location."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await Geolocator.openAppSettings();
  //           },
  //           child: const Text("Open Settings"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _saveChanges() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Save address if changed
      if (hasAddressChanged && updatedAddress != null) {
        await prefs.setString('add1', updatedAddress!);
      }
      
      // Save location if changed
      if (hasLocationChanged && updatedLatitude != null && updatedLongitude != null) {
        await prefs.setString('latitude', updatedLatitude.toString());
        await prefs.setString('longitude', updatedLongitude.toString());
        await prefs.setString('locationAddress', locationAddress);
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Address and location updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return to cart screen with updated data
      Navigator.pop(context, {
        'address': updatedAddress,
        'latitude': updatedLatitude,
        'longitude': updatedLongitude,
        'locationAddress': locationAddress,
        'hasChanges': hasAddressChanged || hasLocationChanged,
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving changes: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetLocation() {
    setState(() {
      updatedLatitude = widget.currentLatitude;
      updatedLongitude = widget.currentLongitude;
      locationAddress = widget.currentLocationAddress ?? "Location not selected";
      locationSearchController.clear();
      hasLocationChanged = false;
    });
  }

  void _resetAddress() {
    setState(() {
      isUpdatingLocation = true; // Prevent listener from triggering
      addressController.text = widget.currentAddress ?? "";
      updatedAddress = widget.currentAddress;
      hasAddressChanged = false;
      isUpdatingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasAnyChanges = hasAddressChanged || hasLocationChanged;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1BA4CA),
        title: const Text("Edit Address & Location"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (hasAnyChanges) {
              _showUnsavedChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: PopScope(
          canPop: !hasAnyChanges,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && hasAnyChanges) {
              _showUnsavedChangesDialog();
            }
          },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Delivery Address",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hasAddressChanged)
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.blue),
                              onPressed: _resetAddress,
                              tooltip: "Reset Address",
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressController,
                        focusNode: addressFocusNode,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Address",
                          hintText: "Enter your delivery address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.home),
                        ),
                      ),
                      if (hasAddressChanged)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Address has been modified",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Location Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hasLocationChanged)
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.blue),
                              onPressed: _resetLocation,
                              tooltip: "Reset Location",
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Google Places Search
                      GooglePlaceAutoCompleteTextField(
                        textEditingController: locationSearchController,
                        focusNode: locationFocusNode,
                        googleAPIKey: "AIzaSyCMADwyS3eoxJ5dQ_iFiWcDBA_tJwoZosw",
                        inputDecoration: InputDecoration(
                          hintText: "Search for a new location",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: locationSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    locationSearchController.clear();
                                  },
                                )
                              : null,
                        ),
                        debounceTime: 800,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (prediction) {
                          isUpdatingLocation = true; // Prevent address listener from triggering
                          
                          double lat = double.parse(prediction.lat!);
                          double lng = double.parse(prediction.lng!);
                          
                          setState(() {
                            updatedLatitude = lat;
                            updatedLongitude = lng;
                          });
                          
                          _getAddressFromCoordinates(lat, lng).then((_) {
                            isUpdatingLocation = false;
                          });
                        },
                        itemClick: (prediction) {
                          // Keep focus on location field, don't let it jump to address
                          locationSearchController.text = prediction.description!;
                          locationSearchController.selection = TextSelection.fromPosition(
                            TextPosition(offset: prediction.description!.length),
                          );
                          
                          // Ensure focus stays on location field
                          Future.delayed(const Duration(milliseconds: 100), () {
                            FocusScope.of(context).requestFocus(locationFocusNode);
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Current Location Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selected Location:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              locationAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            if (updatedLatitude != null && updatedLongitude != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Coordinates: ${updatedLatitude!.toStringAsFixed(6)}, ${updatedLongitude!.toStringAsFixed(6)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      if (hasLocationChanged)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Location has been modified",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: hasAnyChanges ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasAnyChanges ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        hasAnyChanges ? "Save Changes" : "No Changes to Save",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (hasAnyChanges) {
                          _showUnsavedChangesDialog();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unsaved Changes"),
        content: const Text("You have unsaved changes. What would you like to do?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to cart without saving
            },
            child: const Text("Discard Changes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _saveChanges(); // Save and go back
            },
            child: const Text("Save & Exit"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Just close dialog, stay on edit screen
            },
            child: const Text("Continue Editing"),
          ),
        ],
      ),
    );
  }
}



