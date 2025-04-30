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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order Tracking', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: $bookingId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Order Date: $bookingDate', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductStepper(product, screenWidth, screenHeight);
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to review screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.25, vertical: 16),
                ),
                child: const Text('Leave a Review', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductStepper(BookedProduct product, double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product: ${product.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Price: ₹${product.price.toStringAsFixed(2)}'),
        Text('Quantity: ${product.quantity}'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStep(screenWidth, screenHeight, 1, "Booked", product.currentStep >= 1),
            _buildStepDivider(screenWidth, product.currentStep >= 2),
            _buildStep(screenWidth, screenHeight, 2, "Out of Delivery", product.currentStep >= 2),
            _buildStepDivider(screenWidth, product.currentStep >= 3),
            _buildStep(screenWidth, screenHeight, 3, "Completed", product.currentStep >= 3),
          ],
        ),
      ],
    );
  }

  Widget _buildStep(double screenWidth, double screenHeight, int step, String title, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(color: isActive ? Colors.white : Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
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
        height: 2,
        color: isActive ? Colors.blue : Colors.grey[300],
      ),
    );
  }
}
