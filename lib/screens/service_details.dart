import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import "package:font_awesome_flutter/font_awesome_flutter.dart";

import 'bookingstagepage.dart';

class ServiceDetailsPage extends StatefulWidget {
  const ServiceDetailsPage({super.key});

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Services',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Notification functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Name and Rating
              Text(
                'Service Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                ),
              ),
              Row(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: screenWidth * 0.04,
                      ),
                    ),
                  ),
                  Text(
                    ' (30)',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Category',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                '₹ 500',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Lorem ipsum dolor sit amet consectetur. Fusce dui consectetur aenean pellentesque tincidunt.',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Image Gallery
              Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: screenWidth * 0.02,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: (screenWidth - screenWidth * 0.18) / 2,
                    height: screenWidth * 0.3,
                    color: const Color.fromARGB(255, 213, 221, 231),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Book Service Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BookingStagePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                  child: Text(
                    'Book Service',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Share Icons
              Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.facebook,
                        color: Colors.blue, size: screenWidth * 0.07),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.twitter,
                        color: Colors.lightBlue, size: screenWidth * 0.07),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.linked_camera,
                        color: Colors.red, size: screenWidth * 0.07),
                    onPressed: () {},
                  ),
                  // Add more icons as needed
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Reviews & Ratings Section
              Text(
                'Reviews & Ratings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                ),
              ),
              Row(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: screenWidth * 0.04,
                      ),
                    ),
                  ),
                  Text(
                    ' (30)',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildReviewFilterButtons(screenWidth),
              SizedBox(height: screenHeight * 0.02),

              // Review Cards
              ...List.generate(
                  4, (index) => _buildReviewCard(screenWidth, screenHeight)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewFilterButtons(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[100],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Latest',
            style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.04),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Ratings',
            style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.04),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.08,
            backgroundImage: const AssetImage(
                'assets/user_profile.png'), // Replace with actual image
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                Text(
                  'Verified Customer',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: screenWidth * 0.035,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Lorem ipsum dolor sit amet consectetur. Duis diam suspendisse tristique pellentesque orci tristique id in felis.',
                  style: TextStyle(fontSize: screenWidth * 0.035),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
