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
  final double userPrice;

 
  final String distributorid;

  BookedProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.bookingStatus,
    required this.currentStep,
    required this.userPrice,
    required this.distributorid
  });
}

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String bookingId;
  final String bookingDate;
  final double totalPrice;
  final String type;
  final double paidPrice;
  final String otp;
  final List<BookedProduct> products;
   // NEW FIELDS
 

  const OrderTrackingPage({
    super.key,
    required this.bookingId,
    required this.bookingDate,
    required this.totalPrice,
    required this.type,
    required this.paidPrice,
    required this.otp,
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

    // Shared OTP, Total Price, and Paid Price from first product
    final otp = widget.otp;
    final totalPrice = widget.totalPrice;
    final paidPrice = widget.paidPrice;
    final remain=totalPrice - paidPrice;

    final nonCancelledProducts = widget.products
    .where((p) => p.bookingStatus.toLowerCase() == "cancelled")
    .toList();

    final cancelledPrice = nonCancelledProducts.fold(0.0, (sum, p) => sum + p.price);
    print("cancelledpay :$cancelledPrice");
    final remainingPay = remain-cancelledPrice;


    

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
            const SizedBox(height: 12),
            Text('OTP: $otp', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: widget.products.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return _buildProductStepper(context, product, screenWidth, screenHeight);
                },
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Price: ₹${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Paid Price: ₹${paidPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                if (widget.type.toLowerCase() == 'cod') 
                  Text(
                    'Remaining Pay overall: ₹${remainingPay.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
              ]
            ),
            const SizedBox(height: 16),
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
      // Dynamically calculate currentStep from bookingStatus
  int currentStep = 0;
  final status = product.bookingStatus.toLowerCase().trim(); // Normalize

  switch (status) {
    case 'pending':
      currentStep = 0;
      break;
    case 'confirmed':
      currentStep = 1;
      break;
    case 'startdelivery':
      currentStep = 2;
      break;
    case 'completed':
      currentStep = 3;
      break;
    default:
      currentStep = 0;
  }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product: ${product.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Price: ₹${product.userPrice.toStringAsFixed(2)}'),
        Text('Quantity: ${product.quantity}'),
        const SizedBox(height: 1),
        Text('Type: ${widget.type}', style: TextStyle(color: Colors.grey[700])),
        if (product.bookingStatus.toLowerCase() == "cancelled") ...[
              const Text(
                "This product is cancelled. The refund amount will be credited in 2 to 3 working days.",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Text("Remaining Pay product: ₹${widget.type == "cod" ? (product.price * product.quantity).toStringAsFixed(2) : "0"}"),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStep(screenWidth, screenHeight, 1, "Booked", currentStep >= 0),
                  _buildStepDivider(screenWidth, currentStep >= 1),
                  _buildStep(screenWidth, screenHeight, 2, "Confirmed", currentStep >= 1),
                  _buildStepDivider(screenWidth, currentStep >= 2),
                  _buildStep(screenWidth, screenHeight, 3, "Out of Delivery", currentStep >= 2),
                  _buildStepDivider(screenWidth, currentStep >= 3),
                  _buildStep(screenWidth, screenHeight, 4, "Completed", currentStep >= 3),
                ],
              ),
            ],

        
        const SizedBox(height: 10),
        if (product.bookingStatus.toLowerCase() == "pending" || product.bookingStatus.toLowerCase() == "confirmed") ...[
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
                  final success = await ref.read(getproductProvider.notifier).cancelBooking(widget.bookingId, product.productId,product.distributorid);
                  
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product booking canceled successfully')),
                    );
                    Navigator.pop(context); // Optional refresh
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[800],
              ),
              child: const Text('Cancel Booking'),
            ),
          ]else if (product.bookingStatus.toLowerCase() == "startdelivery") ...[
            const Text(
              "You can't cancel this booking because the product was shipped.",
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            ),
          ] else if (product.bookingStatus.toLowerCase() == "completed") ...[
            const Text(
              "Delivery completed.",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ]

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