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
  
  int cartItemCount = 0;
  bool _isInitialized = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();
    
    // Initialize products and setup TabController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      await ref.read(productProvider.notifier).fetchProducts();
      if (mounted) {
        _setupCategories();
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  void _setupCategories() {
    final productState = ref.read(productProvider);
    
    if (productState.data != null) {
      setState(() {
        _categories = ["ALL"];
        _categories.addAll(
          productState.data!
              .map((p) => p.categoryName)
              .whereType<String>()
              .toSet()
              .toList()
        );
        
        _initializeTabController();
        _isInitialized = true;
      });
    }
  }

  void _initializeTabController() {
    _tabController?.dispose(); // Dispose previous controller
    
    int initialIndex = _categories.indexOf(widget.selectedCategory);
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCartItemCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cartItems = prefs.getStringList('cartItems') ?? [];
      if (mounted) {
        setState(() {
          cartItemCount = cartItems.length;
        });
      }
    } catch (e) {
      print('Error loading cart count: $e');
    }
  }

  void _updateCartCount() {
    _loadCartItemCount();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    
    if (!_isInitialized || _tabController == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 5),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) => 
                _buildCategoryContent(category, _updateCartCount)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1BA4CA),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const HomePage())
          );
        },
      ),
      title: _buildSearchBar(),
      actions: [_buildCartButton()],
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
              onChanged: _onSearchChanged,
            ),
          ),
          if (_searchQuery.isNotEmpty) 
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: _clearSearch,
            ),
          const Icon(Icons.mic, color: Colors.grey),
          const Icon(Icons.image, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
            _updateCartCount();
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
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.orange,
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.grey,
        isScrollable: true,
        tabs: _categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  Widget _buildCategoryContent(String category, VoidCallback updateCartCount) {
    final productState = ref.watch(productProvider);
    final allProducts = productState.data ?? [];

    // Filter products by category
    final filteredProducts = allProducts.where((p) {
      final matchesCategory = category == "ALL" || p.categoryName == category;
      final isTopLevel = p.parentId == null;
      return matchesCategory && isTopLevel;
    }).toList();

    // Apply search filter
    final searchedProducts = filteredProducts.where((p) =>
      _searchQuery.isEmpty ||
      (p.productName?.toLowerCase().contains(_searchQuery) ?? false) ||
      (p.categoryName?.toLowerCase().contains(_searchQuery) ?? false)
    ).toList();

    if (searchedProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Increased from 0.7 to give more height
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: searchedProducts.length,
      itemBuilder: (context, index) => 
        _buildProductCard(searchedProducts[index], updateCartCount),
    );
  }

 // 2. Update _buildProductCard to check for specific distributor combination
  Widget _buildProductCard(Data product, VoidCallback updateCartCount) {
  return FutureBuilder<List<String>>(
    future: _getCartItems(),
    builder: (context, snapshot) {
      // Create the same composite key to check if this specific product-distributor combo is in cart
      String cartItemKey = "${product.productId}_${product.distributorId}";
      bool isInCart = snapshot.hasData && 
                     snapshot.data!.contains(cartItemKey);

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: InkWell(
          onTap: () => _navigateToProductDetails(product, updateCartCount),
          borderRadius: BorderRadius.circular(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(product, constraints.maxHeight * 0.45),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildProductInfo(product)),
                          _buildAddToCartButton(product, isInCart, updateCartCount),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}


  Widget _buildProductImage(Data product, [double? height]) {
    final imageHeight = height ?? 120.0; // Default height if not provided
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: Image.network(
        (product.productImages?.isNotEmpty ?? false) 
          ? product.productImages!.first 
          : '',
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
          Container(
            height: imageHeight,
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 40, color: Colors.grey),
          ),
      ),
    );
  }

  Widget _buildProductInfo(Data product) {
    String truncatedName = _truncateText(product.productName ?? '', 12);
    String truncatedDescription = _truncateText(product.productDescription ?? '', 15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          truncatedName, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          truncatedDescription, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis, 
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        if (product.price != null)
          Text(
            "₹${(product.price! * 1.10).toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.green, 
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        Text(
          "AvlQty: ${product.quantity ?? 0}", 
          style: const TextStyle(
            color: Color.fromARGB(255, 175, 76, 99), 
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(Data product, bool isInCart, VoidCallback updateCartCount) {
    return SizedBox(
      height: 32, // Fixed smaller height
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isInCart ? Colors.orange : const Color(0xFF1BA4CA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: () => _handleCartButtonPress(product, isInCart, updateCartCount),
        child: Text(
          isInCart ? "Go to Cart" : "Add to Cart",
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    return text.length > maxLength 
      ? "${text.substring(0, maxLength)}..." 
      : text;
  }

  Future<void> _navigateToProductDetails(Data product, VoidCallback updateCartCount) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsDetails(
          product: product, 
          updateCartCount: updateCartCount
        )
      ),
    );
    updateCartCount();
  }

  // 3. Update _handleCartButtonPress to pass distributorId
Future<void> _handleCartButtonPress(Data product, bool isInCart, VoidCallback updateCartCount) async {
  if (isInCart) {
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const CartScreen())
    );
    updateCartCount();
  } else {
    // Pass both productId and distributorId
    await _addToCart(product.productId!, product.distributorId!);
    updateCartCount();
  }
}

  Future<List<String>> _getCartItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('cartItems') ?? [];
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

// 4. Additional helper method to get cart items for a specific product
Future<bool> _isProductInCart(String productId, String distributorId) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];
    String cartItemKey = "${productId}_${distributorId}";
    return cartItems.contains(cartItemKey);
  } catch (e) {
    print('Error checking cart: $e');
    return false;
  }
}  

  // 1. Update _addToCart method to include distributorId
Future<void> _addToCart(String productId, String distributorId) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];
    
    // Create composite key: productId_distributorId
    String cartItemKey = "${productId}_${distributorId}";

    if (!cartItems.contains(cartItemKey)) {
      cartItems.add(cartItemKey);
      await prefs.setStringList('cartItems', cartItems);
      
      if (mounted) {
        setState(() {
          cartItemCount = cartItems.length;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Item added to cart"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  } catch (e) {
    print('Error adding to cart: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error adding item to cart"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}
































































































// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:gomed_user/model/product.dart';
// import 'package:gomed_user/providers/products.dart';
// import 'package:gomed_user/screens/cart_screen.dart';
// import 'package:gomed_user/screens/home_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import "package:gomed_user/screens/products_details.dart";

// class ProductsScreen extends ConsumerStatefulWidget {
//   final String selectedCategory;
//   const ProductsScreen({super.key, required this.selectedCategory});

//   @override
//   ProductsScreenState createState() => ProductsScreenState();
// }

// class ProductsScreenState extends ConsumerState<ProductsScreen> with TickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _searchFocusNode = FocusNode();
//   TabController? _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = "";
  
//   int cartItemCount = 0;
//   bool _isInitialized = false;
//   List<String> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCartItemCount();
    
//     // Initialize products and setup TabController
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeData();
//     });
//   }

//   Future<void> _initializeData() async {
//     try {
//       await ref.read(productProvider.notifier).fetchProducts();
//       if (mounted) {
//         _setupCategories();
//       }
//     } catch (e) {
//       print('Error initializing data: $e');
//     }
//   }

//   void _setupCategories() {
//     final productState = ref.read(productProvider);
    
//     if (productState.data != null) {
//       setState(() {
//         _categories = ["ALL"];
//         _categories.addAll(
//           productState.data!
//               .map((p) => p.categoryName)
//               .whereType<String>()
//               .toSet()
//               .toList()
//         );
        
//         _initializeTabController();
//         _isInitialized = true;
//       });
//     }
//   }

//   void _initializeTabController() {
//     _tabController?.dispose(); // Dispose previous controller
    
//     int initialIndex = _categories.indexOf(widget.selectedCategory);
//     _tabController = TabController(
//       length: _categories.length,
//       vsync: this,
//       initialIndex: initialIndex >= 0 ? initialIndex : 0,
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchFocusNode.dispose();
//     _tabController?.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCartItemCount() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       List<String> cartItems = prefs.getStringList('cartItems') ?? [];
//       if (mounted) {
//         setState(() {
//           cartItemCount = cartItems.length;
//         });
//       }
//     } catch (e) {
//       print('Error loading cart count: $e');
//     }
//   }

//   void _updateCartCount() {
//     _loadCartItemCount();
//   }

//   void _onSearchChanged(String value) {
//     setState(() {
//       _searchQuery = value.toLowerCase();
//     });
//   }

//   void _clearSearch() {
//     setState(() {
//       _searchController.clear();
//       _searchQuery = "";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productState = ref.watch(productProvider);
    
//     if (!_isInitialized || _tabController == null) {
//       return Scaffold(
//         appBar: _buildAppBar(),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           const SizedBox(height: 5),
//           _buildTabBar(),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: _categories.map((category) => 
//                 _buildCategoryContent(category, _updateCartCount)
//               ).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: const Color(0xFF1BA4CA),
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.white),
//         onPressed: () {
//           Navigator.pushReplacement(
//             context, 
//             MaterialPageRoute(builder: (context) => const HomePage())
//           );
//         },
//       ),
//       title: _buildSearchBar(),
//       actions: [_buildCartButton()],
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           const Icon(Icons.search, color: Colors.grey),
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               focusNode: _searchFocusNode,
//               decoration: const InputDecoration(
//                 hintText: "Search Products & Categories",
//                 border: InputBorder.none,
//               ),
//               onChanged: _onSearchChanged,
//             ),
//           ),
//           if (_searchQuery.isNotEmpty) 
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.grey),
//               onPressed: _clearSearch,
//             ),
//           const Icon(Icons.mic, color: Colors.grey),
//           const Icon(Icons.image, color: Colors.grey),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartButton() {
//     return Stack(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.shopping_cart, color: Colors.white),
//           onPressed: () async {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const CartScreen()),
//             );
//             _updateCartCount();
//           },
//         ),
//         if (cartItemCount > 0)
//           Positioned(
//             right: 6,
//             top: 12,
//             child: Container(
//               padding: const EdgeInsets.all(3),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
//               child: Text(
//                 '$cartItemCount',
//                 style: const TextStyle(
//                   color: Colors.white, 
//                   fontSize: 11, 
//                   fontWeight: FontWeight.bold
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       color: Colors.white,
//       child: TabBar(
//         controller: _tabController,
//         indicatorColor: Colors.orange,
//         labelColor: Colors.orange,
//         unselectedLabelColor: Colors.grey,
//         isScrollable: true,
//         tabs: _categories.map((category) => Tab(text: category)).toList(),
//       ),
//     );
//   }

//   Widget _buildCategoryContent(String category, VoidCallback updateCartCount) {
//     final productState = ref.watch(productProvider);
//     final allProducts = productState.data ?? [];

//     // Filter products by category
//     final filteredProducts = allProducts.where((p) {
//       final matchesCategory = category == "ALL" || p.categoryName == category;
//       final isTopLevel = p.parentId == null;
//       return matchesCategory && isTopLevel;
//     }).toList();

//     // Apply search filter
//     final searchedProducts = filteredProducts.where((p) =>
//       _searchQuery.isEmpty ||
//       (p.productName?.toLowerCase().contains(_searchQuery) ?? false) ||
//       (p.categoryName?.toLowerCase().contains(_searchQuery) ?? false)
//     ).toList();

//     if (searchedProducts.isEmpty) {
//       return const Center(
//         child: Text(
//           'No products found',
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       );
//     }

//     return GridView.builder(
//       padding: const EdgeInsets.all(10),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.75, // Increased from 0.7 to give more height
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: searchedProducts.length,
//       itemBuilder: (context, index) => 
//         _buildProductCard(searchedProducts[index], updateCartCount),
//     );
//   }

//   Widget _buildProductCard(Data product, VoidCallback updateCartCount) {
//     return FutureBuilder<List<String>>(
//       future: _getCartItems(),
//       builder: (context, snapshot) {
//         bool isInCart = snapshot.hasData && 
//                        snapshot.data!.contains(product.productId);

//         return Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           elevation: 3,
//           child: InkWell(
//             onTap: () => _navigateToProductDetails(product, updateCartCount),
//             borderRadius: BorderRadius.circular(10),
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildProductImage(product, constraints.maxHeight * 0.45), // 45% of card height
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(6),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(child: _buildProductInfo(product)),
//                             _buildAddToCartButton(product, isInCart, updateCartCount),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProductImage(Data product, [double? height]) {
//     final imageHeight = height ?? 120.0; // Default height if not provided
    
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
//       child: Image.network(
//         (product.productImages?.isNotEmpty ?? false) 
//           ? product.productImages!.first 
//           : '',
//         height: imageHeight,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => 
//           Container(
//             height: imageHeight,
//             color: Colors.grey[200],
//             child: const Icon(Icons.image, size: 40, color: Colors.grey),
//           ),
//       ),
//     );
//   }

//   Widget _buildProductInfo(Data product) {
//     String truncatedName = _truncateText(product.productName ?? '', 12);
//     String truncatedDescription = _truncateText(product.productDescription ?? '', 15);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           truncatedName, 
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 2),
//         Text(
//           truncatedDescription, 
//           maxLines: 1, 
//           overflow: TextOverflow.ellipsis, 
//           style: const TextStyle(color: Colors.grey, fontSize: 10),
//         ),
//         const SizedBox(height: 4),
//         if (product.price != null)
//           Text(
//             "₹${(product.price! * 1.10).toStringAsFixed(2)}",
//             style: const TextStyle(
//               color: Colors.green, 
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//             ),
//           ),
//         Text(
//           "AvlQty: ${product.quantity ?? 0}", 
//           style: const TextStyle(
//             color: Color.fromARGB(255, 175, 76, 99), 
//             fontWeight: FontWeight.bold,
//             fontSize: 10,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAddToCartButton(Data product, bool isInCart, VoidCallback updateCartCount) {
//     return SizedBox(
//       height: 32, // Fixed smaller height
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isInCart ? Colors.orange : const Color(0xFF1BA4CA),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//         ),
//         onPressed: () => _handleCartButtonPress(product, isInCart, updateCartCount),
//         child: Text(
//           isInCart ? "Go to Cart" : "Add to Cart",
//           style: const TextStyle(color: Colors.white, fontSize: 11),
//         ),
//       ),
//     );
//   }

//   String _truncateText(String text, int maxLength) {
//     return text.length > maxLength 
//       ? "${text.substring(0, maxLength)}..." 
//       : text;
//   }

//   Future<void> _navigateToProductDetails(Data product, VoidCallback updateCartCount) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProductsDetails(
//           product: product, 
//           updateCartCount: updateCartCount
//         )
//       ),
//     );
//     updateCartCount();
//   }

//   Future<void> _handleCartButtonPress(Data product, bool isInCart, VoidCallback updateCartCount) async {
//     if (isInCart) {
//       await Navigator.push(
//         context, 
//         MaterialPageRoute(builder: (context) => const CartScreen())
//       );
//       updateCartCount();
//     } else {
//       await _addToCart(product.productId!);
//       updateCartCount();
//     }
//   }

//   Future<List<String>> _getCartItems() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       return prefs.getStringList('cartItems') ?? [];
//     } catch (e) {
//       print('Error getting cart items: $e');
//       return [];
//     }
//   }

//   Future<void> _addToCart(String productId) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       List<String> cartItems = prefs.getStringList('cartItems') ?? [];

//       if (!cartItems.contains(productId)) {
//         cartItems.add(productId);
//         await prefs.setStringList('cartItems', cartItems);
        
//         if (mounted) {
//           setState(() {
//             cartItemCount = cartItems.length;
//           });
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Item added to cart"),
//               duration: Duration(seconds: 2),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error adding to cart: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Error adding item to cart"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
