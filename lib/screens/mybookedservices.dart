import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/providers/servicebooking_provider.dart';
import 'package:gomed_user/screens/service_ordertracing.dart';

class MyServicesPage extends ConsumerStatefulWidget {
  const MyServicesPage({super.key});

  @override
  ConsumerState<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends ConsumerState<MyServicesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(getserviceProvider.notifier).getUserBookedServices());
  }

  Future<void> _cancelBooking(BuildContext context, String? bookingId) async {
    if (bookingId == null) return;

    final bool confirmCancel = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Booking"),
          content: const Text("Are you sure you want to cancel this service booking?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // Close popup
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // Confirm cancel
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmCancel) {
      final success = await ref.read(getserviceProvider.notifier).cancelUserService(bookingId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Service booking canceled successfully")),
        );
        ref.read(getserviceProvider.notifier).getUserBookedServices(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to cancel service booking")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookedServicesState = ref.watch(getserviceProvider);
     final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: bookedServicesState.data == null
          ? const Center(child: CircularProgressIndicator()) // Show loader if data is null
          : bookedServicesState.data!.isEmpty
              ? const Center(child: Text("No booked services found")) // Show message if empty
              : ListView.builder(
                  itemCount: bookedServicesState.data!.length,
                  itemBuilder: (context, index) {
                    final service = bookedServicesState.data![index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.serviceIds![0].name ?? "Unknown Service"),
                              Text("Price: ₹${service.serviceIds![0].price ?? 'N/A'}"),
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                                builder: (context) => ServiceOrdertracing(                                
                                                                bookingId: service.sId ?? 'Unknown',
                                                                serviceName: service.serviceIds?.isNotEmpty == true ? service.serviceIds!.first.name ?? '' : '',
                                                                bookingDate: service.createdAt ?? 'Unknown',
                                                                status: service.status ?? 'Pending',
                                                                price: service.serviceIds?.isNotEmpty == true ? service.serviceIds!.first.price?.toDouble() ?? 0.0 : 0.0,
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
                                                     onPressed: () => _cancelBooking(context, service.sId ),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                                                      child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
               
                      
                    );
                  },
                ),
    );
  }
}
