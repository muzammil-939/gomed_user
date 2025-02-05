import 'package:flutter/material.dart';
import 'package:gomed_user/screens/services.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listener to scroll up when the search field gains focus
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _scrollController.animateTo(
          100.0, // Adjust this value to scroll the featured section into view
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for services',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 213, 221, 231),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ),
              onSubmitted: (value) {},
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryCard(
                    icon: Icons.medical_services,
                    label: 'Healthcare',
                    screenWidth: screenWidth),
                CategoryCard(
                    icon: Icons.brush,
                    label: 'Beauty',
                    screenWidth: screenWidth),
                CategoryCard(
                    icon: Icons.directions_bike,
                    label: 'Wellness',
                    screenWidth: screenWidth),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Featured',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              height: screenHeight * 0.4, // Define height for horizontal list
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ServiceCard(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                  ServiceCard(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                  ServiceCard(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                  ServiceCard(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                  ServiceCard(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                  ServiceCard(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.032),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.3),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ServicesPage()));
                },
                child: const Text(
                  'View All Services',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The rest of the classes remain the same
class CategoryCard extends StatelessWidget {
  const CategoryCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.screenWidth});
  final IconData icon;
  final String label;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.25,
      height: screenWidth * 0.25,
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 213, 221, 231),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: screenWidth * 0.1, color: Colors.black),
          SizedBox(height: screenWidth * 0.02),
          Text(
            label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard(
      {super.key, required this.screenWidth, required this.screenHeight});
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
          const Text('Service Name',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
              children: List.generate(
                  5,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 15))),
          SizedBox(height: screenWidth * 0.01),
          const Text('Category',
              style: TextStyle(color: Colors.blue, fontSize: 12)),
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
