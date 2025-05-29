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

  int getCurrentStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 1;
      case 'confirmed':
        return 2;
      case 'startDelivery':
        return 3;
      case 'completed': 
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(getproductProvider);
    final bookingData = bookingState.data;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text('Bookings', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(bookingData),
      ),
    );
  }

  Widget _buildBody(List<Data>? bookingData) {
    if (bookingData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (bookingData.isEmpty) {
      return const Center(child: Text('No bookings found.'));
    }

    return ListView.builder(
      itemCount: bookingData.length,
      itemBuilder: (context, index) {
        final booking = bookingData[index];
        return _buildBookingCard(context, booking);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, Data booking) {
    String productNames = booking.productIds?.map((p) => p.productName ?? 'Unknown').join(', ') ?? 'Unknown Product';
   // String bookingStatus = booking.productIds?.first.bookingStatus ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(productNames, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Booking Date: ${booking.createdAt ?? 'Unknown'}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            // Text(
            //   'Status: $bookingStatus',
            //   style: TextStyle(
            //     color: bookingStatus == 'Completed' ? Colors.green : Colors.orange,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => OrderTrackingPage(
                        bookingId: booking.sId ?? '',
                        bookingDate: booking.createdAt ?? '',
                         // PASSING BOOKING-LEVEL FIELDS TO EACH PRODUCT
                            totalPrice: booking.totalPrice ?? 0.0,
                            type: booking.type ?? '',
                            paidPrice: booking.paidPrice ?? 0,
                            otp: booking.otp ?? '',
                        products: booking.productIds?.map((product) {
                          return BookedProduct(
                            productId: product.sId ?? '',
                            name: product.productName ?? '',
                            price: product.price?.toDouble() ?? 0.0,
                            quantity: product.quantity ?? 0,
                            bookingStatus: product.bookingStatus ?? '',
                            currentStep: getCurrentStep(product.bookingStatus ?? ''),
                            userPrice: product.userPrice ?? 0.0,

                           
                            distributorid :product.distributorId!.sId ?? ""
                            
                          );

                        }).toList() ?? [],
                      ),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Details', style: TextStyle(color: Colors.black)),
                ),

              ],
            ),



          ],
        ),
      ),
    );
  }
} 
      //            if ((booking.productIds?.any((p) => p.bookingStatus?.toLowerCase() == 'pending') ?? false))
      //           ElevatedButton(
      //             onPressed: () => _showCancelConfirmationDialog(context, booking.sId ?? '', booking.productIds!.first.sId ?? ''),
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: Colors.red[100],
      //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //             ),
      //             child: const Text('Cancel', style: TextStyle(color: Colors.red)),
      //           )
      //            else if ((booking.productIds?.any((p) => p.bookingStatus?.toLowerCase() == 'confirmed') ?? false))
      // ElevatedButton(
      //   onPressed: () => _showCancelConfirmationDialog(context, booking.sId ?? '',booking.productIds!.first.sId ?? ''),
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.orange[100],
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //   ),
      //   child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
      // )
      

  // void _showCancelConfirmationDialog(BuildContext context, String bookingId , String productId) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Cancel Booking'),
  //       content: const Text('Are you sure you want to cancel this booking?'),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(ctx);
  //             _cancelBooking(bookingId,productId);
  //           },
  //           child: const Text('Yes', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _cancelBooking(String bookingId ,String productId) async {
  //   final success = await ref.read(getproductProvider.notifier).cancelBooking(bookingId,productId);
  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking canceled successfully')));
  //     ref.read(getproductProvider.notifier).getuserproduct();
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to cancel booking')));
  //   }
  // }

