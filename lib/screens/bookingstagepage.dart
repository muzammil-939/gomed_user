import 'package:flutter/material.dart';
import 'package:gomed_user/screens/payment.dart';
import 'package:intl/intl.dart';

class BookingStagePage extends StatefulWidget {
  const BookingStagePage({super.key});

  @override
  _BookingStagePageState createState() => _BookingStagePageState();
}

class _BookingStagePageState extends State<BookingStagePage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
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
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Booking',
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
            // Address Field
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'User Address',
                hintText: 'Enter your address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 213, 221, 231),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Landmark Field
            TextField(
              controller: _landmarkController,
              decoration: InputDecoration(
                labelText: 'Landmark',
                hintText: 'Enter nearby landmark',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 213, 221, 231),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Date Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Selected Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.05,
                    ),
                  ),
                  child: Text(
                    'Select Date',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            // Time Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'Select Time'
                        : 'Selected Time: ${_selectedTime!.format(context)}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.05,
                    ),
                  ),
                  child: Text(
                    'Select Time',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),

            // Proceed to Payment Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedDate != null &&
                      _selectedTime != null &&
                      _addressController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          address: _addressController.text,
                          selectedDate: _selectedDate!,
                          selectedTime: _selectedTime!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please complete all fields before proceeding.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.2,
                  ),
                ),
                child: Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.045,
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
}
