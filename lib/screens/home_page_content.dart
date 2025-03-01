import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/service.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/providers/getservice.dart';
import 'package:gomed_user/screens/products_screen.dart';
import 'package:gomed_user/screens/home_page.dart';

class HomePageContent extends ConsumerStatefulWidget {
  final Function(int) onCategorySelected;
  const HomePageContent({super.key, required this.onCategorySelected});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends ConsumerState<HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final productState = ref.watch(productProvider);
    final serviceState = ref.watch(serviceProvider); // Watch service provider

    List<String> categories = productState.data
            ?.map((product) => product.category)
            .whereType<String>()
            .toSet()
            .toList() ??
        [];
    //List<String> categories = [];

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
            if (categories.isNotEmpty) ...[
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildCategoryList(categories),
              SizedBox(height: screenHeight * 0.02),
            ],
            const Text(
              'Featured Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01),
           // Build featured services based on provider data
            serviceState.data != null && serviceState.data!.isNotEmpty
                ? _buildFeaturedServices(screenWidth, screenHeight, serviceState.data!)
                : const Center(child: CircularProgressIndicator()), // Show loading indicator while fetching
//            serviceState.when(
//   data: (services) {
//     List<Data> allServices = services.expand<Data>((model) => model.data ?? []).toList(); // Not needed anymore

//     if (allServices.isNotEmpty) {
//       return _buildFeaturedServices(screenWidth, screenHeight, allServices);
//     } else {
//       return const Center(child: Text("No services available"));
//     }
//   },
//   loading: () => const Center(child: CircularProgressIndicator()),
//   error: (err, stack) => Center(child: Text("Error: $err")),
// )


          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
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
                widget.onCategorySelected(index);

              // Navigator.push(
              //   context,
              //   MaterialPageRoute( 
              //     builder: (context) =>
              //         ProductsScreen(selectedCategory: categories[index]),
              //   ),
              // );
              
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
          return ServiceCard(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            service: services[index], // Pass the service data to the card
          );
        },
      ),
    );
  }
}


class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.screenWidth, required this.screenHeight, required this.service});
  final double screenWidth;
  final double screenHeight;
  final Data service; // Add service data parameter

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.2,
      width: screenWidth * 0.4,
      margin: EdgeInsets.only(right: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white, // Changed background color
        borderRadius: BorderRadius.circular(15), // Increased border radius
        boxShadow: [ // Added shadow
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
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
          SizedBox(height: screenWidth * 0.01),
          Text(service.details ?? 'Category', style: const TextStyle(color: Colors.blue, fontSize: 12)), // Display category or details
          SizedBox(height: screenWidth * 0.01),
          Text(
                service.price != null ? '\$${service.price}' : 'Price N/A', // Display price
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
