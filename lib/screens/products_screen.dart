import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gomed_user/model/product.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/screens/cart_screen.dart';
import 'package:gomed_user/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:gomed_user/screens/products_details.dart";

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
   final TextEditingController _searchController = TextEditingController();
   String _searchQuery = "";

   int cartItemCount = 0; // To track cart count


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final productState = ref.watch(productProvider);
      // final categories = productState.data?.map((p) => p.category).toSet().toList() ?? [];
      ref.read(productProvider.notifier).fetchProducts().then((_){
       
      _initializeTabController();
    });
    loadCartItemCount();
     });

  }
  void _onCategorySelected(String category) {
  setState(() {
    _tabController?.index = _tabController!.length > 0 ? _tabController!.index : 0;
  });
}


   // Method to initialize the TabController
 void _initializeTabController() {
    final productState = ref.watch(productProvider);
   List<String> categories = ["ALL"]; // Start with "ALL" tab
    categories.addAll(productState.data?.map((p) => p.category).whereType<String>().toSet().toList() ?? []);
  //  void _initializeTabController() {
  // List<String> categories = ["ALL"]; // Start with "ALL" tab

  // ref.listen<AsyncValue<List<ProductModel>>>(productProvider, (previous, next) {
  //   next.whenData((products) {
  //     setState(() {
  //       categories.addAll(
  //         products
  //             .expand((product) => product.data ?? []) // Extract `data` list from each `ProductModel`
  //             .map((data) => data.category) // Get `category` from `Data`
  //             .whereType<String>() // Ensure only non-null categories
  //             .toSet()
  //             .toList(),
  //       );
  //     });
  //   });
  // });

    int initialIndex = categories.indexOf(widget.selectedCategory); // Find selected category index
    _tabController = TabController(
      length: categories.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
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

  void _updateCartCount() {
    loadCartItemCount(); // Recalculate and setState
  }

  @override
  Widget build(BuildContext context) {
        
    final productState = ref.watch(productProvider);
    
   List<String> categories = ["ALL"];
    categories.addAll(productState.data
    ?.map((p) => p.category)
    .whereType<String>()
    .where((c) => c.toLowerCase().contains(_searchQuery)) // 🔍 Filter categories
    .toSet()
    .toList() ?? []);



//      final productState = ref.watch(productProvider);
// List<String> categories = ["ALL"]; // Start with "ALL" tab

// productState.whenData((products) {
//   final extractedCategories = products
//       .expand((product) => product.data ?? []) // Extract `data` list from each `ProductModel`
//       .map((data) => data.category) // Extract category
//       .whereType<String>() // Ensure only valid Strings
//       .toSet()
//       .toList();

//   categories.addAll(extractedCategories);
// });


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
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
          },
        ),
        title: _buildSearchBar(),
         actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                  
                    await loadCartItemCount();
                    setState(() {});  // ✅ Refresh UI after cart update

                  
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
              onTap: (index) => _onCategorySelected(categories[index]),
              isScrollable: true, // Ensures all tabs fit properly
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) => 
                   _buildCategoryContent(category, _updateCartCount)
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
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: "Search Products & Categories",
                border: InputBorder.none,
              ),
              onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            ),
          ),
           if (_searchQuery.isNotEmpty) 
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = "";
              });
            },
          ),
          const Icon(Icons.mic, color: Colors.grey),
          const Icon(Icons.image, color: Colors.grey),
        ],
      ),
    );
  }

 Widget _buildCategoryContent(String category, VoidCallback updateCartCount ) {
  final productState = ref.watch(productProvider);
   final allProducts = productState.data ?? [];

  // Apply category filter
  final filteredProducts = category == "ALL"
      ? allProducts
      : allProducts.where((p) => p.category == category).toList();

  // Apply search filter
  final searchedProducts = filteredProducts.where((p) =>
      p.productName!.toLowerCase().contains(_searchQuery) ||
      p.category!.toLowerCase().contains(_searchQuery)).toList();


// final productState = ref.watch(productProvider);

// final products = productState.when(
//   data: (productList) {
//     return category == "ALL"
//         ? productList.expand((product) => product.data ?? []).toList() // Extract `data` list from `ProductModel`
//         : productList.expand((product) => product.data ?? [])
//             .where((data) => data.category == category)
//             .toList();
//   },
//   loading: () => [],  // Return empty list while loading
//   error: (err, stack) => [], // Return empty list on error
// );
//   if (products.isEmpty) {
//     return const Center(child: Text("No products available."));
//   }

  return GridView.builder(
    shrinkWrap: true,
    physics: const AlwaysScrollableScrollPhysics(),  // ✅ Allows scrolling inside TabBarView
    padding: const EdgeInsets.all(10),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.7,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: searchedProducts.length,
    itemBuilder: (context, index) => _buildProductCard(searchedProducts[index], updateCartCount),
  );
}


Widget _buildProductCard(Data product, VoidCallback updateCartCount) {
  return FutureBuilder<List<String>>(
    future: _getCartItems(), // Fetch cart items
    builder: (context, snapshot) {
      bool isInCart = snapshot.hasData && snapshot.data!.contains(product.productId);

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;

          String truncatedName = product.productName != null && product.productName!.length > 10
              ? "${product.productName!.substring(0, 10)}..."
              : product.productName ?? '';

          String truncatedDescription = product.productDescription != null && product.productDescription!.length > 20
              ? "${product.productDescription!.substring(0, 20)}..."
              : product.productDescription ?? '';
            
            
          return GestureDetector(
                onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                 builder: (context)=>ProductsDetails(product:product, updateCartCount: updateCartCount)
                 ),
               ).then((_){
                  updateCartCount();
               }); 
              },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                           borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                             child: Image.network(
                             product.productImages!.isNotEmpty ? product.productImages!.first : '', // Get the first image from the list
                              height: screenWidth * 0.3,
                            width: double.infinity,
                             fit: BoxFit.cover,
                                 errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 120),
                            ),
                           ),

                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(truncatedName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(truncatedDescription, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                        Text("₹${product.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart ? Colors.orange : const Color(0xFF1BA4CA),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          if (isInCart) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())
                            ).then((_){
                              updateCartCount();
                            });
                          } else {
                            await _addToCart(product.productId!);
                            updateCartCount();
                            setState(() {}); // Refresh UI to update button
                          }
                        },
                        child: Text(
                          isInCart ? "Go to Cart" : "Add to Cart",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Fetch cart items from SharedPreferences
Future<List<String>> _getCartItems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('cartItems') ?? [];
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
       // ✅ Update cart count immediately
    //await loadCartItemCount();
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
