import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/service_engineer_model.dart';
import 'package:gomed_user/providers/service_engineer.dart';

class ServiceOrdertracing extends ConsumerStatefulWidget {
  final String bookingId;
  final String serviceName;
  final String bookingDate;
  final String status;
  final String servicedescription;
  final double price;
  final String serviceEngineerId;
  final String startOtp;
  final String endOtp;

  const ServiceOrdertracing({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.bookingDate,
    required this.status,
    required this.servicedescription,
    required this.price,
    required this.serviceEngineerId,
    required this.startOtp,
    required this.endOtp
  });

  @override
  _ServiceOrderTrackingPageState createState() =>
      _ServiceOrderTrackingPageState();
}

class _ServiceOrderTrackingPageState extends ConsumerState<ServiceOrdertracing> {
  int currentStep = 1;

 @override
void initState() {
  super.initState();
  _updateOrderStatus();
  Future.microtask(() => ref.read(serviceEngineer.notifier).getServiceengineers());
}

  

  void _updateOrderStatus() {
    setState(() {
      if (widget.status.toLowerCase() == "confirmed") {
        currentStep = 2;
      } else if (widget.status.toLowerCase() == "servicestarted") {
        currentStep = 3;
        } else if (widget.status.toLowerCase() == "servicecompleted") {
        currentStep = 4;
      } else {
        currentStep = 1;
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
            : currentStep==3? "servicestarted": "servicecompleted...";

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service is $orderStatus',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Step Progress Bar
              Row(
                children: [
                  _buildStep(screenWidth, screenHeight, 1, "Booked", currentStep >= 1),
                  _buildStepDivider(screenWidth, currentStep >= 2),
                  _buildStep(screenWidth, screenHeight, 2, "In Progress", currentStep >= 2),
                  _buildStepDivider(screenWidth, currentStep >= 3),
                  _buildStep(screenWidth, screenHeight, 3, "servicestarted", currentStep >= 3),
                   _buildStepDivider(screenWidth, currentStep >= 4),
                  _buildStep(screenWidth, screenHeight, 4, "servicecompleted", currentStep >= 4),
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
                'Service : ${widget.serviceName}',
                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
               Text(
                'Description${widget.servicedescription}',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
              // Text(
              //   'Add-On',
              //   style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.035),
              // ),
              const SizedBox(height: 8),
              Text(
                '₹ ${widget.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Date:${widget.bookingDate}',
                style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
              ),
              const SizedBox(height: 8),
              
              Text('Start OTP: ${widget.startOtp}',
                    style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: screenHeight * 0.015),
              Text('End OTP: ${widget.endOtp}',
                    style: TextStyle(fontWeight: FontWeight.bold),),
             
              SizedBox(height: screenHeight * 0.04),

              // Service Engineer Details as Cards
              const Text(
                'Service Engineer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Using the ServiceEngineerScreen widget to show engineers below the order details
              Consumer(
                builder: (context, ref, child) {
                final engineerState = ref.watch(serviceEngineer);
                final engineers = engineerState.data;

                if (widget.serviceEngineerId.isEmpty) {
                  return const Center(child: Text("Service Engineer will be assigned soon."));
                }

                if (engineers == null || engineers.isEmpty) {
                  return const Center(child: Text("No service engineers available."));
                }

                Data? assignedEngineer;
                try {
                  assignedEngineer = engineers.firstWhere(
                    (engineer) => engineer.sId == widget.serviceEngineerId,
                  );
                } catch (e) {
                  assignedEngineer = null;
                }

                if (assignedEngineer == null) {
                  return const Center(child: Text("Assigned Service Engineer not found."));
                }


                 return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: assignedEngineer.serviceEngineerImage != null &&
                                    assignedEngineer.serviceEngineerImage!.isNotEmpty
                                ? NetworkImage(assignedEngineer.serviceEngineerImage!.first)
                                : const AssetImage('assets/placeholder.png') as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              assignedEngineer.name ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("📱 Mobile: ${assignedEngineer.mobile ?? 'N/A'}"),
                      Text("📧 Email: ${assignedEngineer.email ?? 'N/A'}"),
                      Text("📍 Address: ${assignedEngineer.address ?? 'N/A'}"),
                      Text("🛠️ Experience: ${assignedEngineer.experience ?? 0} yrs"),
                      if (assignedEngineer.description != null &&
                          assignedEngineer.description!.isNotEmpty)
                        Text("📝 Description: ${assignedEngineer.description}"),
                    ],
                  ),
                ),
              );

                },
              ),
            ],
          ),
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
