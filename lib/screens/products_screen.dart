import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gomed_user/model/product.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/screens/cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final String selectedCategory;
  const ProductsScreen({super.key, required this.selectedCategory});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends ConsumerState<ProductsScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
   TabController? _tabController;
   int cartItemCount = 0; // To track cart count


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final productState = ref.watch(productProvider);
      // final categories = productState.data?.map((p) => p.category).toSet().toList() ?? [];
      ref.read(productProvider.notifier).fetchProducts();
       loadCartItemCount();
      
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  // Load cart item count from SharedPreferences
  Future<void> loadCartItemCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];
    setState(() {
      cartItemCount = cartItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
        
    final productState = ref.watch(productProvider);
    List<String> categories = ["ALL"]; // Start with "ALL" tab
    categories.addAll(productState.data?.map((p) => p.category).whereType<String>().toSet().toList() ?? []);

   // Ensure TabController gets updated and selects the correct tab
    if (_tabController == null || _tabController!.length != categories.length) {
      int initialIndex =
          categories.indexOf(widget.selectedCategory); // Find selected category
      _tabController = TabController(
        length: categories.length,
        vsync: this,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1BA4CA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: _buildSearchBar(),
         actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: categories.isEmpty || _tabController == null
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator until data is available
      : Column(
        children: [
          const SizedBox(height: 5,),
          _buildFilterButtonsRow(),
          const SizedBox(height: 5,),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              isScrollable: true, // Ensures all tabs fit properly
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) => 
                   _buildCategoryContent(category)
                     ).toList(),

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: "Search Products",
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.mic, color: Colors.grey),
          const Icon(Icons.image, color: Colors.grey),
        ],
      ),
    );
  }

 Widget _buildCategoryContent(String category) {
  final productState = ref.watch(productProvider);
  final products = category == "ALL" 
      ? productState.data ?? [] // Show all products in "ALL" tab
      : productState.data?.where((p) => p.category == category).toList() ?? [];

  if (products.isEmpty) {
    return const Center(child: Text("No products available."));
  }

  return GridView.builder(
    shrinkWrap: false,
    physics: const AlwaysScrollableScrollPhysics(),  // ✅ Allows scrolling inside TabBarView
    padding: const EdgeInsets.all(10),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.7,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: products.length,
    itemBuilder: (context, index) => _buildProductCard(products[index]),
  );
}


Widget _buildProductCard(Data product) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
     
      // Truncate text if it's too long
      String truncatedName = product.productName != null && product.productName!.length > 10
          ? "${product.productName!.substring(0, 10)}..."
          : product.productName ?? '';

      String truncatedDescription = product.productDescription != null && product.productDescription!.length > 20
          ? "${product.productDescription!.substring(0, 20)}..."
          : product.productDescription ?? '';

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                "http://97.74.93.26:3000/${product.productImage}",
                height: screenWidth * 0.3, // Responsive height
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 120),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(truncatedName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(truncatedDescription, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                  Text("₹${product.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            //const Spacer(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BA4CA),
                    minimumSize: const Size(double.infinity, 50), // Responsive button height
                  ),
                  onPressed: ()async {
                
                  await _addToCart(product.productId!);
                  },
                  child: const Text("Add to Cart",style: TextStyle(color:Colors.white,fontSize: 16 ),),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
// Function to store product ID in SharedPreferences
Future<void> _addToCart(String productId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> cartItems = prefs.getStringList('cartItems') ?? [];

  if (!cartItems.contains(productId)) {
    cartItems.add(productId);
    await prefs.setStringList('cartItems', cartItems);
      setState(() {
        cartItemCount = cartItems.length;
      });
     if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Item added to cart",
              style: TextStyle(color: Colors.white),
            ),
            duration:  Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
     }
   // Show Scaffold Messenger
     
    }



  Widget _buildFilterButtonsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton('Top Rated'),
          _buildFilterButton('Customer Ratings'),
          _buildFilterButton('F Assured'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}
