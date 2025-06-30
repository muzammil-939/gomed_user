import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/product.dart';
import 'package:gomed_user/providers/products.dart';
import 'package:gomed_user/screens/cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsDetails extends ConsumerStatefulWidget {
  final Data product;
  final VoidCallback updateCartCount;

  const ProductsDetails({super.key, required this.product, required this.updateCartCount});

  @override
  ConsumerState<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends ConsumerState<ProductsDetails> {
  int _currentImageIndex = 0;
  bool _isInCart = false;
  List<Data> similarProducts = [];

  @override
  void initState() {
    super.initState();
    _checkCartStatus();
  }

  @override
  void didUpdateWidget(covariant ProductsDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.productId != widget.product.productId) {
      _checkCartStatus();
      _filterSimilarProducts(); // Refresh on product change
    }
  }

 Future<void> _checkCartStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> cartItems = prefs.getStringList('cartItems') ?? [];

  String cartKey = "${widget.product.productId}_${widget.product.distributorId}";
  setState(() {
    _isInCart = cartItems.contains(cartKey);
  });
}


  Future<void> _addToCart() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> cartItems = prefs.getStringList('cartItems') ?? [];

  String cartKey = "${widget.product.productId}_${widget.product.distributorId}";

  if (!cartItems.contains(cartKey)) {
    cartItems.add(cartKey);
    await prefs.setStringList('cartItems', cartItems);

    setState(() {
      _isInCart = true;
    });
    widget.updateCartCount();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item added in cart"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
  void _filterSimilarProducts() {
    final allProducts = ref.read(productProvider).data ?? [];
    final currentCategory = widget.product.categoryName?.trim().toLowerCase();

    final filtered = allProducts.where((p) =>
        p.productId != widget.product.productId &&
        p.categoryName?.trim().toLowerCase() == currentCategory).toList();

    setState(() {
      similarProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    if (productState is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productState is AsyncError) {
      return const Center(child: Text("Failed to load products"));
    }

    final allProducts = productState.data ?? [];

    // Fetch similar products only once after data is loaded
    if (similarProducts.isEmpty && allProducts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filterSimilarProducts();
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1BA4CA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.product.productName ?? 'Product Name'),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 300,
            color: Colors.grey[300],
            child: widget.product.productImages != null && widget.product.productImages!.isNotEmpty
                ? Image.network(
                    widget.product.productImages![_currentImageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 120),
                  )
                : const Center(child: Text('No IMAGE')),
          ),
          _buildHorizontalProductImages(widget.product.productImages),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.productName ?? 'Product Title',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.yellow),
                    Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('(150 ratings)'),
                  ],
                ),
                const SizedBox(height: 8),
               Text('₹${(widget.product.price! * 1.10).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(widget.product.productDescription ?? 'Description'),

                const SizedBox(height: 16),
                const Text('About the item', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Detailed description goes here. Replace with actual description.'),

                const SizedBox(height: 16),
                Table(
                  children: const [
                    TableRow(children: [Text('Brand'), Text('Brand Name')]),
                    TableRow(children: [Text('Format'), Text('Tube')]),
                    TableRow(children: [Text('Size'), Text('Large')]),
                  ],
                ),

                const SizedBox(height: 16),
                const Text('Customer Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.yellow),
                    Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('(150 ratings)'),
                  ],
                ),
                _buildRatingBar('5 star', 80),
                _buildRatingBar('4 star', 50),
                _buildRatingBar('3 star', 10),
                _buildRatingBar('2 star', 5),
                _buildRatingBar('1 star', 5),

                const SizedBox(height: 16),
                const Text('Similar Products', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildHorizontalProductList(similarProducts),

                const SizedBox(height: 16),
                const Text('Frequently Bought Together', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildHorizontalbookedProductList(),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _isInCart
                          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))
                          : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isInCart ? Colors.orange : const Color(0xFF1BA4CA),
                        minimumSize: const Size(150, 50),
                      ),
                      child: Text(_isInCart ? 'Go to Cart' : 'Add to Cart',
                          style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, int value) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value'),
      ],
    );
  }

  Widget _buildHorizontalProductList(List<Data> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No similar products found"),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductsDetails(product: product, updateCartCount: widget.updateCartCount),
                ),
              );
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  product.productImages != null && product.productImages!.isNotEmpty
                      ? Image.network(product.productImages![0],
                          height: 100, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 100, color: Colors.grey[300], child: const Icon(Icons.image)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(product.productName ?? "Product",
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '₹${(product.price! + product.price !* 0.10).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalbookedProductList() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Replace with dynamic list if needed
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.all(8),
            color: Colors.white,
            child: Center(child: Text('Product $index')),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProductImages(List<String>? imageUrls) {
    if (imageUrls == null || imageUrls.isEmpty) {
      return const Center(child: Text("No images available"));
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(
                    color: _currentImageIndex == index ? Colors.blue : Colors.grey),
              ),
              child: Image.network(imageUrls[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
