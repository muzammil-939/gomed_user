import 'package:flutter/material.dart';

import 'ordertracking.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  final int status = 2;

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
          'Bookings',
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
        child: ListView.builder(
          itemCount: 5, // Number of bookings
          itemBuilder: (context, index) {
            return _buildBookingCard(context, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(
      BuildContext context, double screenWidth, double screenHeight) {
    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Name',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Booking Date: 2024-11-10', // Sample date
              style: TextStyle(
                  color: Colors.grey[600], fontSize: screenWidth * 0.035),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: Confirmed', // Sample status
                  style: TextStyle(
                      color: Colors.green, fontSize: screenWidth * 0.04),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingPage(
                          currentStep: status,
                        ),
                      ),
                    );
                  },
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
                    'View Details',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
