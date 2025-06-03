// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gomed_user/model/service.dart';
// import 'package:gomed_user/providers/products.dart';
// import 'package:gomed_user/providers/getservice.dart';
// import 'package:gomed_user/screens/products_screen.dart';
// import 'package:gomed_user/screens/home_page.dart';
// import "package:gomed_user/model/service.dart" as service_model;
// import "package:gomed_user/model/product.dart" as product_model;

// class HomePageContent extends ConsumerStatefulWidget {
//   final Function(int) onCategorySelected;
//   const HomePageContent({super.key, required this.onCategorySelected});

//   @override
//   _HomePageContentState createState() => _HomePageContentState();
// }

// class _HomePageContentState extends ConsumerState<HomePageContent> {
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _searchFocusNode = FocusNode();
//   final TextEditingController _searchController = TextEditingController();

//   String _searchQuery = "";

//   @override
//   void initState() {
//     super.initState();
//     _searchFocusNode.addListener(() {
//       if (_searchFocusNode.hasFocus) {
//         _scrollController.animateTo(
//           100.0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(productProvider.notifier).fetchProducts();
//       ref.read(serviceProvider.notifier).getSevices();
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchFocusNode.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     final productState = ref.watch(productProvider).data??[];
//     final serviceState = ref.watch(serviceProvider).data??[];

//     return SingleChildScrollView(
//       controller: _scrollController,
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSearchField(),
//             SizedBox(height: screenHeight * 0.02),
//             _buildCategoriesSection(productState, screenHeight),
//             SizedBox(height: screenHeight * 0.02),
//             const Text(
//               'Featured Services',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: screenHeight * 0.01),
//             _buildServicesSection(serviceState, screenWidth, screenHeight),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchField() {
//     return TextField(
//       controller: _searchController,
//       focusNode: _searchFocusNode,
//       decoration: InputDecoration(
//         hintText: 'Search for services',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         filled: true,
//         fillColor: const Color.fromARGB(255, 213, 221, 231),
//         suffixIcon: const Icon(Icons.search),
//       ),
//       onChanged: (query) {
//         setState(() {
//           _searchQuery = query;
//         });
//       },
//     );
//   }

//   Widget _buildCategoriesSection( List<product_model.Data> productState, double screenHeight) {
//     return productState.when(
//       data: (products) {
//         // Get categories from products
//         List<String> categories = products
//                 ?.map((product) => product.categoryName)
//                 .whereType<String>()
//                 .toSet()
//                 .toList() ??
//             [];

//         // Apply search filtering
//         List<String> filteredCategories = categories
//             .where((category) =>
//                 category.toLowerCase().contains(_searchQuery.toLowerCase()))
//             .toList();

//         if (filteredCategories.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Categories',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: screenHeight * 0.01),
//             _buildCategoryList(filteredCategories),
//           ],
//         );
//       },
//       loading: () => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Categories',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           _buildCategoryLoader(),
//         ],
//       ),
//       error: (error, stackTrace) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Categories',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           Container(
//             height: 50,
//             padding: const EdgeInsets.all(16),
//             child: const Text(
//               'Failed to load categories',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildServicesSection( List<service_model.Data> serviceState, double screenWidth, double screenHeight) {
//     return serviceState.when(
//       data: (services) {
//         // Filter services based on search query
//         List<Data> filteredServices = services
//                 ?.where((service) =>
//                     service.name!.toLowerCase().contains(_searchQuery.toLowerCase()))
//                 .toList() ??
//             [];

//         if (filteredServices.isEmpty) {
//           return SizedBox(
//             height: screenHeight * 0.3,
//             child: const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     "No services found",
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return _buildFeaturedServices(screenWidth, screenHeight, filteredServices);
//       },
//       loading: () => _buildServicesLoader(screenWidth, screenHeight),
//       error: (error, stackTrace) => SizedBox(
//         height: screenHeight * 0.3,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text(
//                 "Failed to load services",
//                 style: TextStyle(fontSize: 16, color: Colors.red),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   ref.read(serviceProvider.notifier).getSevices();
//                 },
//                 child: const Text("Retry"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryLoader() {
//     return SizedBox(
//       height: 50,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 5, // Show 5 skeleton items
//         itemBuilder: (context, index) {
//           return Container(
//             margin: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: _buildShimmerContainer(
//               width: 100,
//               height: 34,
//               borderRadius: 16,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildServicesLoader(double screenWidth, double screenHeight) {
//     return SizedBox(
//       height: screenHeight * 0.6,
//       child: ListView.builder(
//         scrollDirection: Axis.vertical,
//         itemCount: 3, // Show 3 skeleton service cards
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//             child: _buildServiceCardLoader(screenWidth, screenHeight),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildServiceCardLoader(double screenWidth, double screenHeight) {
//     return Container(
//       height: screenHeight * 0.2,
//       width: screenWidth * 0.4,
//       margin: EdgeInsets.only(right: screenWidth * 0.03),
//       padding: EdgeInsets.only(
//         top: screenHeight * 0.04,
//         left: screenWidth * 0.03,
//         right: screenWidth * 0.03,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 5,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildShimmerContainer(width: screenWidth * 0.6, height: 16),
//           SizedBox(height: screenWidth * 0.02),
//           Row(
//             children: List.generate(
//               5,
//               (index) => Container(
//                 margin: const EdgeInsets.only(right: 2),
//                 child: _buildShimmerContainer(width: 15, height: 15, isCircular: true),
//               ),
//             ),
//           ),
//           SizedBox(height: screenWidth * 0.02),
//           _buildShimmerContainer(width: screenWidth * 0.4, height: 12),
//           SizedBox(height: screenWidth * 0.01),
//           _buildShimmerContainer(width: screenWidth * 0.3, height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmerContainer({
//     required double width,
//     required double height,
//     double borderRadius = 4,
//     bool isCircular = false,
//   }) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: isCircular 
//             ? BorderRadius.circular(height / 2)
//             : BorderRadius.circular(borderRadius),
//       ),
//       child: const _ShimmerEffect(),
//     );
//   }

//   Widget _buildCategoryList(List<String> categories) {
//     return SizedBox(
//       height: 50,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       ProductsScreen(selectedCategory: categories[index]),
//                 ),
//               );
//             },
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8.0),
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               decoration: BoxDecoration(
//                 color: Colors.blue[100],
//                 borderRadius: BorderRadius.circular(16.0),
//                 border: Border.all(color: Colors.blueAccent),
//               ),
//               child: Text(
//                 categories[index],
//                 style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedServices(double screenWidth, double screenHeight, List<Data> services) {
//     return SizedBox(
//       height: screenHeight * 0.6,
//       child: ListView.builder(
//         scrollDirection: Axis.vertical,
//         itemCount: services.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//             child: ServiceCard(
//               screenWidth: screenWidth,
//               screenHeight: screenHeight,
//               service: services[index],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Shimmer effect widget for loading animation
// class _ShimmerEffect extends StatefulWidget {
//   const _ShimmerEffect();

//   @override
//   __ShimmerEffectState createState() => __ShimmerEffectState();
// }

// class __ShimmerEffectState extends State<_ShimmerEffect>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//     _controller.repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 Colors.grey[300]!,
//                 Colors.grey[100]!,
//                 Colors.grey[300]!,
//               ],
//               stops: [
//                 _animation.value - 0.3,
//                 _animation.value,
//                 _animation.value + 0.3,
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class ServiceCard extends StatelessWidget {
//   const ServiceCard({
//     super.key,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.service,
//   });
  
//   final double screenWidth;
//   final double screenHeight;
//   final Data service;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: screenHeight * 0.2,
//       width: screenWidth * 0.4,
//       margin: EdgeInsets.only(right: screenWidth * 0.03),
//       padding: EdgeInsets.only(
//         top: screenHeight * 0.04,
//         left: screenWidth * 0.03,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 5,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: screenWidth * 0.02),
//           Text(
//             service.name ?? 'Service Name',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           Row(
//             children: List.generate(
//               5,
//               (index) => Icon(Icons.star, color: Colors.amber, size: 15),
//             ),
//           ),
//           SizedBox(height: screenWidth * 0.02),
//           Text(
//             service.details ?? 'Category',
//             style: const TextStyle(color: Colors.blue, fontSize: 12),
//           ),
//           SizedBox(height: screenWidth * 0.01),
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

































import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/service.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/providers/getservice.dart';
import 'package:gomed_user/screens/products_screen.dart';
import 'package:gomed_user/screens/home_page.dart';

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
             padding: EdgeInsets.only(bottom: screenHeight * 0.02), // spacing between cards
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
      padding: EdgeInsets.only(top: screenHeight * 0.04,left: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white, // Changed background color
        borderRadius: BorderRadius.circular(15), // Increased border radius
        boxShadow: [ // Added shadow
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
