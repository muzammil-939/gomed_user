import 'package:flutter/material.dart';
import 'package:gomed_user/screens/products_screen.dart';
import 'package:gomed_user/screens/profile_screen.dart';
import 'package:gomed_user/screens/settings_screen.dart';
import 'package:gomed_user/screens/services.dart';

import 'booking_screen.dart';
import 'home_page_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages to navigate to
  static const List<Widget> _pages = <Widget>[
    HomePageContent(),
    ProfilePage(),
    ProductsScreen(selectedCategory: "ALL"),
    BookingsPage(),
    ServicesPage(),
    SettingsPage(),

  ];

  // Function to handle page switching
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.grey[100],
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/gomedlogo.png"),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  const Text(
                    'Welcome,\n[User Name]!',
                    style: TextStyle(
                      color: Color.fromARGB(255, 36, 16, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Color.fromARGB(255, 19, 12, 12)),
                    onPressed: () {},
                  ),
                ],
              ),
            )
          : null, // Only show AppBar on the Home Page
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1BA4CA),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E3236),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory),  label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.miscellaneous_services), label: 'Services'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),

        ],
      ),
    );
  }
}
