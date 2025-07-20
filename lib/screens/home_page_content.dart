
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/service.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/providers/getservice.dart';
import 'package:gomed_user/screens/products_screen.dart';


class HomePageContent extends ConsumerStatefulWidget {
  final  Function(int) onCategorySelected;
  const HomePageContent({super.key, required this.onCategorySelected});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends ConsumerState<HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
   final TextEditingController _searchController = TextEditingController(); 

   String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _scrollController.animateTo(
          100.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).fetchProducts();
      ref.read(serviceProvider.notifier).getSevices();
      //ref.read(serviceProvider.notifier).getServices();
    });
  }
  

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
     _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;



  final productState = ref.watch(productProvider);
  final serviceState = ref.watch(serviceProvider);

     // Get categories from products
    List<String> categories = productState.data
            ?.map((product) => product.categoryName)
            .whereType<String>()
            .toSet()
            .toList() ??
        [];

    // Apply search filtering
    List<String> filteredCategories = categories
        .where((category) =>
            category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();    

    // **Filter services based on search query**
    List<Data> filteredServices = serviceState.data
            ?.where((service) =>
                service.name!.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList() ??
        [];
            // List<String> categories = [];

        // productState.when(
        //   data: (products) {
        //     categories = products
        //         .where((product) => product.data != null && product.data!.isNotEmpty) // Ensure data is not null or empty
        //         .map((product) => product.data!.first.category ?? 'Unknown') // Safely access the first category
        //         .whereType<String>()
        //         .toSet()
        //         .toList();
        //   },
        //   loading: () => [],
        //   error: (err, stack) => [],
        // );



    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            SizedBox(height: screenHeight * 0.02),
            if (filteredCategories.isNotEmpty) ...[
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildCategoryList(filteredCategories),
              SizedBox(height: screenHeight * 0.02),
            ],
            const Text(
              'Featured Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01),
           // Build featured services based on provider data
            filteredServices.isNotEmpty
                ? _buildFeaturedServices(screenWidth, screenHeight, filteredServices)
                : const Center(child: Text("No services available")), // Show loading indicator while fetching
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search for services',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 213, 221, 231),
        suffixIcon: const Icon(Icons.search),
      ),
       onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      
    );
  }

  // Build category list dynamically
  Widget _buildCategoryList(List<String> categories) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
               // widget.onCategorySelected(index);

              Navigator.push(
                context,
                MaterialPageRoute( 
                  builder: (context) =>
                      ProductsScreen(selectedCategory: categories[index]),
                ),
              );
              
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Text(
                categories[index],
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedServices(double screenWidth, double screenHeight, List<Data> services) {
    return SizedBox(
      height: screenHeight * 0.6,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: services.length, // Use services data from the provider
        itemBuilder: (context, index) {
          return Padding(
             padding: EdgeInsets.only(bottom: screenHeight * 0.03), // spacing between cards
            child: ServiceCard(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              service: services[index], // Pass the service data to the card
            ),
          );
        },
      ),
    );
  }
}

//   // Fixed _buildFeaturedServices method
// Widget _buildFeaturedServices(double screenWidth, double screenHeight, List<Data> services) {
//   return Column(
//     children: services.map((service) {
//       return ServiceCard(
//         screenWidth: screenWidth,
//         screenHeight: screenHeight,
//         service: service,
//       );
//     }).toList(),
//   );
// }
// }


class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.screenWidth, required this.screenHeight, required this.service});
  final double screenWidth;
  final double screenHeight;
  final Data service; // Add service data parameter

  @override
  Widget build(BuildContext context) {
    final lightGreyShadow = Colors.grey.withValues(alpha: 18);
    return Container(
      height: screenHeight * 0.2,
      width: screenWidth * 0.4,
      margin: EdgeInsets.only(right: screenWidth * 0.03),
      padding: EdgeInsets.only(top: screenHeight * 0.04,left: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white, // Changed background color
        borderRadius: BorderRadius.circular(15), // Increased border radius
        boxShadow: [ // Added shadow
          BoxShadow(
            color: lightGreyShadow,
            spreadRadius: 5,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         // Container(
           // height: screenWidth * 0.2,
            // decoration: BoxDecoration( // Use BoxDecoration for image
            //   borderRadius: BorderRadius.circular(10),
            //   image: const DecorationImage(
            //     image: NetworkImage("https://via.placeholder.com/150"), // Replace with your image URL or asset
            //     fit: BoxFit.cover,
            //   ),
            // ),
         // ),
          SizedBox(height: screenWidth * 0.02),
          Text(service.name ?? 'Service Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Display service name
          Row(
            children: List.generate(
                5, (index) => Icon(Icons.star, color: Colors.amber, size: 15)),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(service.details ?? 'Category', style: const TextStyle(color: Colors.blue, fontSize: 12)), // Display category or details
          SizedBox(height: screenWidth * 0.01),
          Text(
                service.price != null ? '₹${service.price}' : 'Price N/A', // Display price
                style: const TextStyle(
                  color: Colors.green, // Or any color you prefer
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}

// Fixed ServiceCard Widget
// class ServiceCard extends StatelessWidget {
//   const ServiceCard({super.key, required this.screenWidth, required this.screenHeight, required this.service});
//   final double screenWidth;
//   final double screenHeight;
//   final Data service;

//   @override
//   Widget build(BuildContext context) {
//     final lightGreyShadow = Colors.grey.withValues(alpha: 26);
//     return Container(
//       height: screenHeight * 0.18, // Reduced height slightly
//       width: double.infinity, // Use full width instead of fixed width
//       margin: EdgeInsets.only(bottom: screenHeight * 0.015), // Consistent bottom margin
//       padding: EdgeInsets.all(screenWidth * 0.04), // More balanced padding
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: lightGreyShadow,
//             spreadRadius: 2, // Reduced spread radius
//             blurRadius: 6, // Reduced blur radius
//             offset: const Offset(0, 2), // Reduced offset
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute space evenly
//         children: [
//           // Service name
//           Text(
//             service.name ?? 'Service Name',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//             maxLines: 2, // Limit to 2 lines to prevent overflow
//             overflow: TextOverflow.ellipsis,
//           ),
          
//           // Star rating
//           Row(
//             children: List.generate(
//               5,
//               (index) => Icon(
//                 Icons.star,
//                 color: Colors.amber,
//                 size: 16,
//               ),
//             ),
//           ),
          
//           // Service details
//           Text(
//             service.details ?? 'Category',
//             style: const TextStyle(
//               color: Colors.blue,
//               fontSize: 12,
//             ),
//             maxLines: 2, // Limit to 2 lines
//             overflow: TextOverflow.ellipsis,
//           ),
          
//           // Price
//           Text(
//             service.price != null ? '₹${service.price}' : 'Price N/A',
//             style: const TextStyle(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


