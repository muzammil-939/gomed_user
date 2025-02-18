import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/screens/products_screen.dart';

class HomePageContent extends ConsumerStatefulWidget {
  final Function(int) onCategorySelected; // Callback function to switch tab
  const HomePageContent({super.key,required this.onCategorySelected });

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
    // Fetch products to get categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).fetchProducts();
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

    // Extract unique categories
    List<String> categories = productState.data
            ?.map((product) => product.category)
            .whereType<String>()
            .toSet()
            .toList() ??
        [];

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            SizedBox(height: screenHeight * 0.02),

            // Show categories if available
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
              'Featured',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01),
            _buildFeaturedServices(screenWidth, screenHeight),
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
               //widget.onCategorySelected(index); // Switch to Products tab
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

  Widget _buildFeaturedServices(double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(5, (index) {
          return ServiceCard(screenWidth: screenWidth, screenHeight: screenHeight);
        }),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.screenWidth, required this.screenHeight});
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.6,
      width: screenWidth * 0.4,
      margin: EdgeInsets.only(right: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenWidth * 0.2,
            color: const Color.fromARGB(255, 213, 221, 231),
          ),
          SizedBox(height: screenWidth * 0.02),
          const Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 15))),
          SizedBox(height: screenWidth * 0.01),
          const Text('Category', style: TextStyle(color: Colors.blue, fontSize: 12)),
          SizedBox(height: screenWidth * 0.01),
          const Text(
            'Lorem ipsum dolor sit amet consectetur. Fusce dui consectetur aenean pellentesque tincidunt.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
