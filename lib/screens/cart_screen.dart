import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends ConsumerState<CartScreen> {
  int selectedItems = 2; // Default selected items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: const Color(0xFF1BA4CA),
        title: Text("CART")),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Deliver To: 562130", style: TextStyle(fontSize: 18)),
                  TextButton(onPressed: () {}, child: Text("Change", style: TextStyle(color: Colors.blue))),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.green[100],
              child: Text(
                "You're Saving ₹860 On This Order",
                style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CartItem(available: true),
                    CartItem(available: false),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: PriceDetails(),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  final bool available;

  CartItem({required this.available});

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: widget.available
                      ? (value) {
                          setState(() {
                            isSelected = value!;
                          });
                        }
                      : null,
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Globus Naturals", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Gold Radiance Face", style: TextStyle(fontSize: 14, color: Colors.black54)),
                      Text("Sold By: M/S GLOBUS R", style: TextStyle(fontSize: 12, color: Colors.black45)),
                      if (widget.available)
                        Row(
                          children: [
                            Text("Size: 90-100gm", style: TextStyle(fontSize: 14, color: Colors.black54)),
                            SizedBox(width: 10),
                            Text("Qty: 2", style: TextStyle(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      Row(
                        children: [
                          Text("35% ", style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
                          Text("₹2246", style: TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.black45)),
                          SizedBox(width: 5),
                          Text("₹740.85", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (!widget.available)
                        Text("Out of Stock", style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold)),
                      if (widget.available)
                        Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.blue, size: 16),
                            SizedBox(width: 5),
                            Text("Delivered By Feb 3, Mon . ₹80", style: TextStyle(fontSize: 12, color: Colors.blue)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.delete_outline, color: Colors.black54),
                  label: Text("Remove", style: TextStyle(color: Colors.black54)),
                ),
                if (widget.available)
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                    label: Text("Buy Now", style: TextStyle(color: Colors.blue)),
                  ),
                if (!widget.available)
                  TextButton(
                    onPressed: () {},
                    child: Text("Find Similar", style: TextStyle(color: Colors.blue)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PriceDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PRICE DETAILS", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total MRP:"), Text("₹3,680")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Discount MRP:"), Text("- ₹860")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Platform Fee:"), Text("₹20")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Shipping Fee:"), Text("FREE")]),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)), Text("₹3,020")],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: Text("VIEW PRICE DETAILS", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(minimumSize: Size(150, 50)),
                child: Text("Continue", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
