import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/get_productbooking.dart';
import 'package:gomed_user/providers/getproduct_provider.dart';
import 'product_ordertracking.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(getproductProvider.notifier).getuserproduct());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final bookingState = ref.watch(getproductProvider); // Watching provider
    final bookingData = bookingState.data; // Extracting actual data

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
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
        child: _buildBody(bookingData, screenWidth, screenHeight),
      ),
    );
  }

  /// Handles different states: Loading, No Data, and Displaying Bookings
  Widget _buildBody(List<Data>? bookingData, double screenWidth, double screenHeight) {
    if (bookingData == null) {
      return const Center(child: CircularProgressIndicator()); // Show loader while fetching
    } else if (bookingData.isEmpty) {
      return const Center(child: Text('No bookings found.', style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: bookingData.length,
      itemBuilder: (context, index) {
        final booking = bookingData[index];
        return _buildBookingCard(context, screenWidth, screenHeight, booking);
      },
    );
  }

  /// Builds a single booking card
  Widget _buildBookingCard(BuildContext context, double screenWidth, double screenHeight, Data booking) {
    String productName = booking.productIds != null && booking.productIds!.isNotEmpty
  ? booking.productIds!.map((p) => p.productName ?? 'Unknown').join(', ')
  : 'Unknown Product';

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Booking Date: ${booking.createdAt ?? 'Unknown'}',
              style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.035),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${booking.status ?? 'Pending'}',
                  style: TextStyle(color: Colors.green, fontSize: screenWidth * 0.04),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingPage(
                          currentStep: 2, // You might need to replace this with a dynamic value
                          bookingId: booking.sId ?? 'Unknown',
                          productName: booking.productIds?.isNotEmpty == true ? booking.productIds!.first.productName ?? '' : '',
                          bookingDate: booking.createdAt ?? 'Unknown',
                          status: booking.status ?? 'Pending',
                          price: booking.productIds?.isNotEmpty == true ? booking.productIds!.first.price?.toDouble() ?? 0.0 : 0.0,
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
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showCancelConfirmationDialog(context, booking.sId ?? ''),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
   void _showCancelConfirmationDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _cancelBooking(bookingId);
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    final success = await ref.read(getproductProvider.notifier).cancelBooking(bookingId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking canceled successfully')),
      );
      ref.read(getproductProvider.notifier).getuserproduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel booking')),
      );
    }
  }
}
