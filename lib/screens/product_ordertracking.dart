import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/getproduct_provider.dart';

class BookedProduct {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String bookingStatus;
  final int currentStep;

  BookedProduct({
     required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.bookingStatus,
    required this.currentStep,
  });
}

class OrderTrackingPage extends ConsumerStatefulWidget {
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
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
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
            Text('Order ID: ${widget.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Order Date: ${widget.bookingDate}', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount:  widget.products.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return _buildProductStepper(context ,product, screenWidth, screenHeight);
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

  Widget _buildProductStepper(BuildContext context, BookedProduct product, double screenWidth, double screenHeight) {
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
        const SizedBox(height: 10),
        ElevatedButton(
  onPressed: () async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Product Booking"),
        content: const Text("Are you sure you want to cancel this product from the booking?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(getproductProvider.notifier).cancelBooking(widget.bookingId, product.productId); // ← updated
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product booking canceled successfully')),
        );
        Navigator.pop(context); // Optional: trigger a refresh
      }
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red[100],
    foregroundColor: Colors.red[800],
  ),
  child: const Text('Cancel Booking'),
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
