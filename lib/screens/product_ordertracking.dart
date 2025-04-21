import 'package:flutter/material.dart';

class BookedProduct {
  final String name;
  final double price;
  final int quantity;
  final String bookingStatus;
  final int currentStep;

  BookedProduct({
    required this.name,
    required this.price,
    required this.quantity,
    required this.bookingStatus,
    required this.currentStep,
  });
}

class OrderTrackingPage extends StatelessWidget {
  final String bookingId;
  final String bookingDate;
  final List<BookedProduct> products;

  const OrderTrackingPage({
    super.key,
    required this.bookingId,
    required this.bookingDate,
    required this.products,
  });

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
          'Order Tracking',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $bookingId',
              style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // List of Products with Individual Steppers
            ...products.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product: ${product.name}',
                    style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Price: ₹ ${product.price.toStringAsFixed(2)}'),
                  Text('Quantity: ${product.quantity}'),
                 // Text('Status: ${product.bookingStatus}'),
                  SizedBox(height: 12),
                  
                  // Individual stepper for product
                  Row(
                    children: [
                      _buildStep(screenWidth, screenHeight, 1, "Booked", product.currentStep >= 1),
                      _buildStepDivider(screenWidth, product.currentStep >= 2),
                      _buildStep(screenWidth, screenHeight, 2, "Out of Delivery", product.currentStep >= 2),
                      _buildStepDivider(screenWidth, product.currentStep >= 3),
                      _buildStep(screenWidth, screenHeight, 3, "Completed", product.currentStep >= 3),
                    ],
                  ),

                  Divider(color: Colors.grey[300]),
                ],
              ),
            )),

            const Spacer(),

            Center(
              child: ElevatedButton(
                onPressed: () {},
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
