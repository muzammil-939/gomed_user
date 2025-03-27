import 'package:flutter/material.dart';

class ServiceOrdertracing extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String bookingDate;
  final String status;
  final double price;
  //final int currentStep; // 1 for "Booked", 2 for "In Progress", 3 for "Completed"

  const ServiceOrdertracing({super.key,  required this.bookingId,
    required this.serviceName,
    required this.bookingDate,
    required this.status,
    required this.price});

  @override
  _ServiceOrderTrackingPageState createState() => _ServiceOrderTrackingPageState();
}

class _ServiceOrderTrackingPageState extends State<ServiceOrdertracing> {
  int currentStep = 1;
 
   @override
  void initState() {
    super.initState();
    _updateOrderStatus();
  }

  void _updateOrderStatus() {
    setState(() {
      if (widget.status.toLowerCase() == "confirmed") {
        currentStep = 2; // Order is now "In Progress"
      } else {
        currentStep = 1; // Order is still "Booked"
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

   String orderStatus = currentStep == 1
        ? "Booked..."
        : currentStep == 2
            ? "In Progress..."
            : "Completed...";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Order Tracking',
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
            Text(
              'Order is $orderStatus',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            
            // Step Progress Bar
            Row(
              children: [
                _buildStep(screenWidth, screenHeight, 1, "Booked",currentStep >= 1),
                _buildStepDivider(screenWidth, currentStep >= 2),
                _buildStep(screenWidth, screenHeight, 2, "In Progress", currentStep >= 2),
                _buildStepDivider(screenWidth,currentStep >= 3),
                _buildStep(screenWidth, screenHeight, 3, "Completed",currentStep >= 3),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // Order Details
            Text(
               'Order ID: ${widget.bookingId}',
              style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Product: ${widget.serviceName}',
              style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
            Text(
              'Add-On',
              style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.035),
            ),
            Text(
              'Date Time',
              style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
            ),
            const SizedBox(height: 8),
            Text(
              '₹ ${widget.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Lorem ipsum dolor sit amet consectetur. Fusce dui consectetur aenean pellentesque tincidunt.',
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
            
            const Spacer(),
            
           // Leave a Review Button (Only show if completed)
            if (currentStep == 3)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Leave a review functionality
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
                  'Leave a Review',
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

  Widget _buildStep(double screenWidth, double screenHeight, int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.1,
          height: screenHeight * 0.01,
          color: isActive ? Colors.blue : Colors.grey[300],
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(double screenWidth, bool isActive) {
    return Expanded(
      child: Container(
        height: screenWidth * 0.005,
        color: isActive ? Colors.blue : Colors.grey[300],
      ),
    );
  }
}
