// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_user/model/product.dart';
// import 'package:gomed_user/providers/products.dart';
// import 'package:gomed_user/screens/service_details.dart';
// import 'package:gomed_user/providers/getservice.dart';
// import 'package:gomed_user/model/service.dart';

// class ServicesPage extends ConsumerWidget {
//   const ServicesPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final productState = ref.watch(productProvider);
//     final serviceState = ref.watch(serviceProvider);

//     // Fetch screen dimensions
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.grey[100],
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Services',
//           style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.05),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications, color: Colors.black),
//             onPressed: () {
//               // Notification functionality
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search bar
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search for services',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(screenWidth * 0.03),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: const Color.fromARGB(255, 213, 221, 231),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () {
//                     // Search functionality
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),

//             // Filter options
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildFilterChip('Price', screenWidth: screenWidth),
//                 _buildFilterChip('Ratings', isSelected: true, screenWidth: screenWidth),
//                 _buildFilterChip('Distance', screenWidth: screenWidth),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.02),

//             // Loading and Error Handling
//             // Expanded(
//             //   child: productState.when(
//             //     data: (products) {
//             //       return serviceState.when(
//             //         data: (services) {
//             //           return ListView.builder(
//             //             itemCount: products.length,
//             //             itemBuilder: (context, index) {
//             //               final product = products[index];
//             //               final productServices = services
//             //                   .where((service) => service.productIds?.contains(product.data![0].productId) ?? false)
//             //                   .toList();

//             //               // return ProductCard(
//             //               //   product: product,
//             //               //  // services:productServices,
//             //               //   screenWidth: screenWidth,
//             //               // );
//             //             },
//             //           );
//             //         },
//             //         loading: () => const Center(child: CircularProgressIndicator()),
//             //         error: (err, stack) => Center(child: Text('Error: $err')),
//             //       );
//             //     },
//             //     loading: () => const Center(child: CircularProgressIndicator()),
//             //     error: (err, stack) => Center(child: Text('Error: $err')),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, {bool isSelected = false, required double screenWidth}) {
//     return FilterChip(
//       label: Text(label, style: TextStyle(fontSize: screenWidth * 0.04)),
//       selected: isSelected,
//       onSelected: (selected) {
//         // Add filter logic here if needed
//       },
//       backgroundColor: Colors.grey[300],
//       selectedColor: Colors.blue[100],
//       labelStyle: TextStyle(
//         color: isSelected ? Colors.black : Colors.grey[700],
//         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//       ),
//     );
//   }
// }

// class ProductCard extends StatefulWidget {
//   final ProductModel product;
//   final List<ServiceModel> services;
//   final double screenWidth;

//   const ProductCard({super.key, required this.product, required this.services, required this.screenWidth});

//   @override
//   _ProductCardState createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   bool isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.screenWidth * 0.03)),
//       child: Padding(
//         padding: EdgeInsets.all(widget.screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: () => setState(() => isExpanded = !isExpanded),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     widget.product.data![0].productName ?? 'Unknown Product',
//                     style: TextStyle(fontSize: widget.screenWidth * 0.045, fontWeight: FontWeight.bold),
//                   ),
//                   Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: widget.screenWidth * 0.06),
//                 ],
//               ),
//             ),
//             if (isExpanded)
//               Column(
//                 children: widget.services.map((service) {
//                   return ListTile(
//                     title: Text(
//                       service.data![0].name ?? 'Unknown Service',
//                       style: TextStyle(fontSize: widget.screenWidth * 0.04),
//                     ),
//                     subtitle: Text(
//                       'Price: ₹${service.data![0].price ?? 'N/A'}',
//                       style: TextStyle(fontSize: widget.screenWidth * 0.035),
//                     ),
//                     trailing: ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ServiceDetailsPage(),
//                           ),
//                         );
//                       },
//                       icon: Icon(Icons.arrow_forward, size: widget.screenWidth * 0.045),
//                       label: Text('Details', style: TextStyle(fontSize: widget.screenWidth * 0.035)),
//                     ),
//                   );
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }





















import 'package:flutter/material.dart';
import 'package:gomed_user/screens/service_details.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
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
          'Services',
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
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for services',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 213, 221, 231),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Search functionality
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Filter options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip('Price', screenWidth: screenWidth),
                _buildFilterChip('Ratings',
                    isSelected: true, screenWidth: screenWidth),
                _buildFilterChip('Distance', screenWidth: screenWidth),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            // Service Cards
            Expanded(
              child: ListView(
                children: [
                  ServiceItemCard(screenWidth: screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  ServiceItemCard(screenWidth: screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  ServiceItemCard(screenWidth: screenWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label,
      {bool isSelected = false, required double screenWidth}) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: screenWidth * 0.04)),
      selected: isSelected,
      onSelected: (selected) {
        // Add filter logic here if needed
      },
      backgroundColor: Colors.grey[300],
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class ServiceItemCard extends StatefulWidget {
  const ServiceItemCard({super.key, required this.screenWidth});

  final double screenWidth;

  @override
  _ServiceItemCardState createState() => _ServiceItemCardState();
}

class _ServiceItemCardState extends State<ServiceItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: widget.screenWidth * 0.25,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 213, 221, 231),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: widget.screenWidth * 0.02),
          Text(
            'Service Name',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.screenWidth * 0.045),
          ),
          Text(
            'Category',
            style: TextStyle(
                color: Colors.blue, fontSize: widget.screenWidth * 0.035),
          ),
          SizedBox(height: widget.screenWidth * 0.01),
          Row(
            children: [
              Text(
                '₹ 500',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: widget.screenWidth * 0.04),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(Icons.star,
                      color: Colors.amber, size: widget.screenWidth * 0.035),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenWidth * 0.02),
          Text(
            'Lorem ipsum dolor sit amet consectetur. Fusce dui consectetur aenean pellentesque tincidunt.',
            style: TextStyle(fontSize: widget.screenWidth * 0.035),
          ),
          SizedBox(height: widget.screenWidth * 0.02),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ServiceDetailsPage()));
              },
              icon: Icon(Icons.arrow_forward, size: widget.screenWidth * 0.04),
              label: Text('Details',
                  style: TextStyle(fontSize: widget.screenWidth * 0.04)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.screenWidth * 0.04,
                  vertical: widget.screenWidth * 0.02,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
