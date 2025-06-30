// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:gomed_user/main.dart';
// import 'package:gomed_user/providers/auth_state.dart';
// import 'package:gomed_user/providers/servicebooking_provider.dart';
// import 'package:gomed_user/screens/razorpay_payment_page.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'mybookedservices.dart';

// class BookingStagePage extends ConsumerStatefulWidget {
//     final String serviceId; 
//      final String productId;

//   const BookingStagePage({super.key,required this.serviceId,required this.productId, });

//   @override
//   _BookingStagePageState createState() => _BookingStagePageState();
  
  
// }

// class _BookingStagePageState extends ConsumerState<BookingStagePage> {
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//  // final String serviceId = widget.serviceId; // ✅ Get serviceId
//  String startOtp = generateOtp();
//   String endOtp = generateOtp();

//     @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

// Future<void> _loadUserData() async {
//   final userState = ref.read(userProvider);
  
//   if (userState.data != null && userState.data!.isNotEmpty) {
//     final user = userState.data!.first.user!;
//     _addressController.text = user.address ?? 'No Address';

//     // Fetch landmark (human-readable address from lat/lng)
//     if (user.location != null && user.location!.latitude!.isNotEmpty) {
//       try {
//         double latitude = double.parse(user.location!.latitude!);
//         double longitude = double.parse(user.location!.longitude!);

//         List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
//         if (placemarks.isNotEmpty) {
//           Placemark place = placemarks.first;
//           setState(() {
//             _landmarkController.text =
//            "${place.street ?? 'Unknown Street'}, ${place.locality ?? 'Unknown City'}, ${place.country ?? 'Unknown Country'}";
//            print('location details....${place.street}, ${place.locality}, ${place.country}');
//           });
//         }
//       } catch (e) {
//         print("Error fetching landmark: $e");
//       }
//     }
//   }
// }

//   Future<void> _changeAddress() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? newAddress = await _showAddressDialog();
//     if (newAddress != null && newAddress.isNotEmpty) {
//       await prefs.setString('user_address', newAddress);
//       setState(() {
//         _addressController.text = newAddress;
//       });
//     }
//   }

//   Future<String?> _showAddressDialog() async {
//     TextEditingController addressInput = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Change Address'),
//           content: TextField(
//             controller: addressInput,
//             decoration: InputDecoration(hintText: 'Enter new address'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, null),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, addressInput.text),
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to pick date
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (pickedDate != null && pickedDate != _selectedDate) {
//       setState(() {
//         _selectedDate = pickedDate;
//       });
//     }
//   }

//   // Function to pick time
//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (pickedTime != null && pickedTime != _selectedTime) {
//       setState(() {
//         _selectedTime = pickedTime;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.grey[100],
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Booking',
//           style: TextStyle(color: Colors.black),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications, color: Colors.black),
//             onPressed: () {
//               // Notification functionality
//             },
//           ),
//         ],
//       ),
//       resizeToAvoidBottomInset: true, // important
//       body: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.05),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Address Field
//             TextField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 labelText: 'User Address',
//                 hintText: 'Enter your address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 filled: true,
//                 fillColor: const Color.fromARGB(255, 213, 221, 231),
//               ),
//             ),
//              SizedBox(height: screenHeight * 0.01),

//             // Change Address Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: _changeAddress,
//                 child: Text('Change Address'),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),

//             // Landmark Field
//             TextField(
//               controller: _landmarkController,
//               decoration: InputDecoration(
//                 labelText: 'Landmark',
//                 hintText: 'Enter nearby landmark',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 filled: true,
//                 fillColor: const Color.fromARGB(255, 213, 221, 231),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.04),

//             // Date Picker
//             Row(
              
//               children: [
//                 Expanded(
//                   child: Text(
//                     _selectedDate == null
//                         ? 'Select Date'
//                         : 'Selected Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.045,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _selectDate(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[100],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       vertical: screenHeight * 0.015,
//                       horizontal: screenWidth * 0.05,
//                     ),
//                   ),
//                   child: Text(
//                     'Select Date',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: screenWidth * 0.04,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.03),

//             // Time Picker
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     _selectedTime == null
//                         ? 'Select Time'
//                         : 'Selected Time: ${_selectedTime!.format(context)}',
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.045,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _selectTime(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[100],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       vertical: screenHeight * 0.015,
//                       horizontal: screenWidth * 0.05,
//                     ),
//                   ),
//                   child: Text(
//                     'Select Time',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: screenWidth * 0.04,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.04),

//             // Proceed to Payment Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   if (_selectedDate != null &&
//                       _selectedTime != null &&
//                       _addressController.text.isNotEmpty) {
//                     final userState = ref.read(userProvider);

//                     if (userState.data != null && userState.data!.isNotEmpty) {
//                       final user = userState.data!.first.user;
//                       final userId = user?.sId;
//                       final address = _addressController.text;
//                       final contact =  '+9391696616';

//                       final email = user?.email ?? 'Gocodedesigners@gmail.com';

//                       String location = '';
//                       if (user?.location != null) {
//                         location = '${user!.location!.latitude},${user.location!.longitude}';
//                       }

//                       if (widget.serviceId.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please select at least one service')),
//                         );
//                         return;
//                       }

//                       String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
//                       String formattedTime = _selectedTime!.format(context);

//                       // 🔹 Go to Razorpay page first
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => RazorpayPaymentPage(
//                             amount: 1, // change this dynamically if needed
//                             contact: contact,
//                             email: email,
//                             onSuccess: () async {
//                               try {
//                                 await ref.read(getserviceProvider.notifier).addServices(
//                                   userId: userId,
//                                   serviceId: [widget.serviceId],
//                                   productId: widget.productId,
//                                   location: location,
//                                   address: address,
//                                   date: formattedDate,
//                                   time: formattedTime,
//                                   startOtp: startOtp,
//                                   endOtp: endOtp,
//                                 );

//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Booking successful!')),
//                                 );

//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(builder: (_) => MyServicesPage()),
//                                 );
//                               } catch (error) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Failed to book service: $error')),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       );
//                     }
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please complete all fields before proceeding.'),
//                       ),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[100],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     vertical: screenHeight * 0.02,
//                     horizontal: screenWidth * 0.2,
//                   ),
//                 ),
//                 child: Text(
//                   'BOOK SERVICE',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: screenWidth * 0.045,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }









import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gomed_user/main.dart';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/providers/servicebooking_provider.dart';
import 'package:gomed_user/screens/razorpay_payment_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mybookedservices.dart';

class BookingStagePage extends ConsumerStatefulWidget {
  final String serviceId; 
  final String productId;
  final int? serviceAmount;

  const BookingStagePage({super.key, required this.serviceId, required this.productId,required this.serviceAmount});

  @override
  _BookingStagePageState createState() => _BookingStagePageState();
}

class _BookingStagePageState extends ConsumerState<BookingStagePage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String startOtp = generateOtp();
  String endOtp = generateOtp();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final userState = ref.read(userProvider);
    
    if (userState.data != null && userState.data!.isNotEmpty) {
      final user = userState.data!.first.user!;
      _addressController.text = user.address ?? 'No Address';

      // Fetch landmark (human-readable address from lat/lng)
      if (user.location != null && user.location!.latitude!.isNotEmpty) {
        try {
          double latitude = double.parse(user.location!.latitude!);
          double longitude = double.parse(user.location!.longitude!);

          List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            setState(() {
              _landmarkController.text =
              "${place.street ?? 'Unknown Street'}, ${place.locality ?? 'Unknown City'}, ${place.country ?? 'Unknown Country'}";
              print('location details....${place.street}, ${place.locality}, ${place.country}');
            });
          }
        } catch (e) {
          print("Error fetching landmark: $e");
        }
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _changeAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newAddress = await _showAddressDialog();
    if (newAddress != null && newAddress.isNotEmpty) {
      await prefs.setString('user_address', newAddress);
      setState(() {
        _addressController.text = newAddress;
      });
    }
  }

  Future<String?> _showAddressDialog() async {
    TextEditingController addressInput = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Change Address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: addressInput,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter new address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, addressInput.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to pick time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Details Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.home_repair_service, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Service Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Service ID: ${widget.serviceId}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Product ID: ${widget.productId}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),

                  // Address Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Service Address',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: _changeAddress,
                                icon: Icon(Icons.edit, size: 16),
                                label: Text('Change'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _addressController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Your Address',
                              hintText: 'Enter your complete address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              prefixIcon: Icon(Icons.home),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _landmarkController,
                            decoration: InputDecoration(
                              labelText: 'Landmark',
                              hintText: 'Enter nearby landmark',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              prefixIcon: Icon(Icons.place),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Date & Time Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Schedule Service',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          // Date Selection
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.calendar_today, color: Colors.blue),
                              title: Text(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
                                style: TextStyle(
                                  fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                                  color: _selectedDate == null ? Colors.grey : Colors.black,
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _selectDate(context),
                            ),
                          ),

                          SizedBox(height: 12),

                          // Time Selection
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.access_time, color: Colors.orange),
                              title: Text(
                                _selectedTime == null
                                    ? 'Select Time'
                                    : _selectedTime!.format(context),
                                style: TextStyle(
                                  fontWeight: _selectedTime == null ? FontWeight.normal : FontWeight.bold,
                                  color: _selectedTime == null ? Colors.grey : Colors.black,
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Book Service Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isBookingValid() ? _bookService : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            color: _isBookingValid() ? Colors.white : Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'BOOK SERVICE',
                            style: TextStyle(
                              color: _isBookingValid() ? Colors.white : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
    );
  }

  bool _isBookingValid() {
    return _selectedDate != null &&
           _selectedTime != null &&
           _addressController.text.isNotEmpty &&
           _landmarkController.text.isNotEmpty;
  }

  Future<void> _bookService() async {
    if (!_isBookingValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields before proceeding.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userState = ref.read(userProvider);

    if (userState.data != null && userState.data!.isNotEmpty) {
      final user = userState.data!.first.user;
      final userId = user?.sId;
      final address = _addressController.text;
      final contact = user?.mobile ??'+919999999999';
      final email = user?.email ?? 'examplemail@gmail.com';

      String location = '';
      if (user?.location != null) {
        location = '${user!.location!.latitude},${user.location!.longitude}';
      }

      if (widget.serviceId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one service'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String formattedTime = _selectedTime!.format(context);

      // Navigate to Razorpay payment page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RazorpayPaymentPage(
            amount: widget.serviceAmount!.toDouble(),
            contact: contact,
            email: email,
            onSuccess: () async {
              try {
                await ref.read(getserviceProvider.notifier).addServices(
                  userId: userId,
                  serviceId: [widget.serviceId],
                  productId: widget.productId,
                  location: location,
                  address: address,
                  date: formattedDate,
                  time: formattedTime,
                  startOtp: startOtp,
                  endOtp: endOtp,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking successful!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MyServicesPage()),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to book service: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }
}