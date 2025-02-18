import 'package:flutter/material.dart';
//import 'package:gomed_user/model/auth.dart';
import 'package:gomed_user/model/product.dart';
import 'package:gomed_user/screens/cart_screen.dart';
import 'package:gomed_user/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsDetails extends StatefulWidget {
  final Data product;
  final VoidCallback updateCartCount;
  const ProductsDetails({super.key, required this.product, required this.updateCartCount});

  @override
  State<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends State<ProductsDetails> {
  int _currentImageIndex = 0;
  bool _isInCart = false;

 @override
  void initState() {
    super.initState();
    _checkCartStatus(); // Check on initialization
  }

  Future<void> _checkCartStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];
    setState(() {
      _isInCart = cartItems.contains(widget.product.productId);
    });
  }

   Future<void> _addToCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];

    if (!cartItems.contains(widget.product.productId)) {
      cartItems.addAll([widget.product.productId].where((id) => id != null).cast<String>());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1BA4CA),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Assumed icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.product.productName ?? 'Product Name'), // Replace with actual product name
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border), // Assumed icon
            onPressed: () {
              // Handle share
            },
          ),
          IconButton(
            icon: Icon(Icons.share), // Assumed icon
            onPressed: () {
              // Handle share
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert), // Assumed icon
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          
           Container(
            height: 300, // Adjust as needed
            color: Colors.grey[300], // Placeholder
            //child: Center(child: Text('Product Image ${_currentImageIndex + 1}')),// Display current image number
           child: widget.product.productImage != null
                   ? Image.network(
                     "http://97.74.93.26:3000/${widget.product.productImage}",
                    fit: BoxFit.cover, // Or BoxFit.contain, depending on your needs
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 120),
           )
           : const Center(child: Text('No IMAGE'),)
          ),
          // Horizontal Product Thumbnails
          _buildHorizontalProductImages(widget.product.productImage), // Pass the image URL

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                 Text(widget.product.productName ?? 'Product Title', // Replace with actual title
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('(150 ratings)'), // Replace with dynamic ratings/count
                  ],
                ),
                SizedBox(height: 8),
                Text('₹${widget.product.price}', // Replace with actual price
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(widget.product.productDescription ?? 'Description',), // Dynamic description
                SizedBox(height: 16),
                Text('Available offers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Upto ₹50 off on Axis Bank Credit Cards',
                    style: TextStyle(color: Colors.grey)), // Example offer

                SizedBox(height: 16),
                Text('About the item',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'Detailed description goes here. Replace with actual description.'),

                SizedBox(height: 16),
                // Specifications Table
                Table(
                  children: [
                    TableRow(children: [Text('Brand'), Text('Brand Name')]),
                    TableRow(children: [Text('Format'), Text('Tube')]),
                    TableRow(children: [Text('Size'), Text('Large')]),
                  ],
                ),

                SizedBox(height: 16),
                // Customer Reviews Section
                Text('Customer Reviews',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('(150 ratings)'),
                  ],
                ),
                // Ratings Breakdown (Static for now)
                _buildRatingBar('5 star', 80),
                _buildRatingBar('4 star', 50),
                _buildRatingBar('3 star', 10),
                _buildRatingBar('2 star', 5),
                _buildRatingBar('1 star', 5),

                SizedBox(height: 16),
                // Similar Products Section
                Text('Similar Products',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildHorizontalProductList(), // Static list

                SizedBox(height: 16),
                // Frequently Bought Together
                Text('Frequently Bought Together',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildHorizontalProductList(), // Static list

                SizedBox(height: 16),
                // Recently Viewed
                Text('Recently Viewed',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildHorizontalProductList(), // Static list

                SizedBox(height: 16),
                // Questions and Answers Section
                Text('Questions & Answers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // Add your Q&A items here (static for now)
                _buildQuestionAnswer('Question 1', 'Answer 1'),
                _buildQuestionAnswer('Question 2', 'Answer 2'),

                
                SizedBox(height: 16),
                // Delivery & Services Section
                Text('Delivery & Services',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded( // Address takes up available space
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deliver to: Hyderabad, Telangana, India'), // Example address
                          Text('400096', style: TextStyle(color: Colors.grey)), // Example pincode
                        ],
                      ),
                    ),
                    TextButton( // Changed to TextButton
                      onPressed: () {
                        // Handle change address
                      },
                      child: Text('Change'),
                    ),
                  ],
                ),
                Text('Free delivery'), // Example
                Text('10 Days Replacement Policy'), // Example
                Text('Cash on Delivery available'), // Example
                SizedBox(height: 16),
                // Add to Cart and Buy Now Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _isInCart
                      ? () {
                        Navigator.push(context, 
                        MaterialPageRoute(builder: (context) =>CartScreen())
                        );
                      }
                      : _addToCart,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _isInCart? Colors.orange : const Color(0xFF1BA4CA), 
                           minimumSize: const Size(150, 50), // Width: 150, Height: 50
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ), 
                         child: Text(
                          _isInCart ? 'Go to Cart': 'Add to Cart',
                          style: TextStyle(color: Colors.white, fontSize: 18),),
                    ),
                    // OutlinedButton( // Changed to OutlinedButton
                    //   onPressed: () {
                    //     // Handle buy now
                    //   },
                    //   style: OutlinedButton.styleFrom(
                    //     side: BorderSide(color: Colors.blue), // Blue border
                    //   ),
                    //   child: Text('Buy Now', style: TextStyle(color: Colors.red)),
                    // ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle buy now
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 50), // Width: 150, Height: 50
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          backgroundColor: Colors.red),
                          
                      child:
                          Text('Buy Now', style: TextStyle(color: Colors.white)),
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
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100, // Assuming max is 100, adjust as needed
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ),
        SizedBox(width: 8),
        Text('$value'),
      ],
    );
  }

    Widget _buildHorizontalProductList() {
    return Container(
      height: 200, // Adjust as needed
      color: Colors.grey[200], // Placeholder
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Replace with your actual count
        itemBuilder: (context, index) {
          return Container(
            width: 150, // Adjust as needed
            margin: EdgeInsets.all(8),
            color: Colors.white, // Placeholder for product item
            child: Center(child: Text('Product $index')),
          );
        },
      ),
    );
  }

  // Helper function to build Q&A items (static for now)
Widget _buildQuestionAnswer(String question, String answer) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
      Text(answer),
      Row( // Added thumbs up/down buttons
        children: [
          IconButton(
            onPressed: () {
              // Handle thumbs up
            },
            icon: Icon(Icons.thumb_up_alt_outlined),
          ),
          Text('0'), // Replace with dynamic count
          IconButton(
            onPressed: () {
              // Handle thumbs down
            },
            icon: Icon(Icons.thumb_down_alt_outlined),
          ),
          Text('0'), // Replace with dynamic count
        ],
      ),
      SizedBox(height: 8),
    ],
  );
}

    // Helper function for horizontally scrollable product images
  Widget _buildHorizontalProductImages(String? imageUrl) {
    return Container(
      height: 100, // Reduced height for thumbnails
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Replace with your actual count
        itemBuilder: (context, index) {
          return GestureDetector( // Wrap with GestureDetector
            onTap: () {
              setState(() {
                _currentImageIndex = index; // Update current image index
              });
            },
            child: Container(
              width: 100, // Adjust as needed
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration( // Add border for selection
                border: Border.all(
                  color: _currentImageIndex == index ? Colors.blue : Colors.transparent, // Highlight selected image
                  width: 2,
                ),
                color: Colors.grey[300], // Placeholder for product image
              ),
             // child: Center(child: Text('Thumbnail ${index + 1}')), // Placeholder
             child: imageUrl != null
                  ? Image.network(
                      "http://97.74.93.26:3000/$imageUrl",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
                    )
                  : const Center(child: Text('No Image')),
            ),
          );
        },
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:gomed_user/model/product.dart';

// class ProductDetailsPopup extends StatelessWidget {
//   final Data product;

//   const ProductDetailsPopup({super.key, required this.product});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: EdgeInsets.all(10),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // App Bar Section with Icons
//           AppBar(
//             backgroundColor:const Color(0xFF1BA4CA),
//             elevation: 0,
//             leading: IconButton(
//               icon: Icon(Icons.close, color: Colors.black),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Text(
//               product.productName ?? 'Product Details',
//               style: TextStyle(color: Colors.black),
//             ),
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.search, color: Colors.black),
//                 onPressed: () {
//                   // TODO: Implement Search functionality
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.favorite_border, color: Colors.black),
//                 onPressed: () {
//                   // TODO: Implement Favorite functionality
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.shopping_cart, color: Colors.black),
//                 onPressed: () {
//                   // TODO: Implement Cart functionality
//                 },
//               ),
//             ],
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Product Image
//                     Image.network(
//                       product.productImage ??
//                           'http://97.74.93.26:3000/sample_product.jpg',
//                       width: double.infinity,
//                       height: 200,
//                       fit: BoxFit.cover,
//                     ),
//                     SizedBox(height: 16),
//                     // Product Name
//                     Text(
//                       product.productName ?? 'Product Name',
//                       style: TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8),
//                     // Product Price
//                     Text(
//                       'Price: ₹${product.price?.toStringAsFixed(2) ?? '0.00'}',
//                       style: TextStyle(
//                           fontSize: 16, color: Colors.grey[600]),
//                     ),
//                     SizedBox(height: 16),
//                     // Ratings and Offer
//                     Row(
//                       children: [
//                         Icon(Icons.star,
//                             color: Colors.orange, size: 18),
//                         Text(
//                           '4.6',
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           '209 Ratings',
//                           style: TextStyle(
//                               fontSize: 14, color: Colors.grey[600]),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           '32% OFF',
//                           style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     // Product Description
//                     Text(
//                       'Description',
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(product.productDescription ??
//                         'No description available.'),
//                     SizedBox(height: 16),
//                     // Brand and Size
//                     Row(
//                       children: [
//                         Text(
//                           'Brand: ${product.category ?? 'Unknown'}',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           'Size: ${product.category ?? 'N/A'}',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     // Delivery Information
//                     Text(
//                       'Delivery Information',
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                         'Delivery to: ${product.category ?? 'Not available'}'),
//                     SizedBox(height: 8),
//                     Text('Get it by: ${product.category ?? 'N/A'}'),
//                     SizedBox(height: 8),
//                     Text(
//                         'Usually ships in: ${product.category ?? '24 hours'}'),
//                     SizedBox(height: 16),
//                     Divider(),
//                     SizedBox(height: 8),
//                     // Customer Ratings and Review
//                     Text(
//                       'Customer Ratings And Review',
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.star,
//                             color: Colors.orange, size: 18),
//                         Text(
//                           '4.6',
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           '209 Ratings',
//                           style: TextStyle(
//                               fontSize: 14, color: Colors.grey[600]),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           '100 Reviews',
//                           style: TextStyle(
//                               fontSize: 14, color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     Divider(),
//                     SizedBox(height: 8),
//                     // Questions & Answers Section
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Questions & Answers',
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         Icon(Icons.search,
//                             color: Colors.black, size: 20),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     ListTile(
//                       title: Text('Q: Is this product genuine?'),
//                       subtitle: Text(
//                           'A: Yes, it is 100% genuine and certified.'),
//                     ),
//                     ListTile(
//                       title: Text('Q: What is the expiration date?'),
//                       subtitle: Text(
//                           'A: It is at least 12 months from the date of purchase.'),
//                     ),
//                     SizedBox(height: 16),
//                     Divider(),
//                     SizedBox(height: 8),
//                     // Additional Details Section (Static)
//                     Text(
//                       'Additional Details',
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8),
//                     Text('Sold By: Gomed Store Pvt Ltd',
//                         style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 4),
//                     Text('Manufacturer: XYZ Pharmaceuticals',
//                         style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 4),
//                     Text('Country of Origin: India',
//                         style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 4),
//                     Text(
//                       'Disclaimer: Product information is for reference only.',
//                       style: TextStyle(
//                           fontSize: 14, color: Colors.grey[600]),
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             print('Add to Cart Clicked');
//                           },
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orange),
//                           child: Text('Add to Cart',
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             print('Buy Now Clicked');
//                           },
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue),
//                           child: Text('Buy Now',
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
