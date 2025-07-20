import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/screens/products_screen.dart';
import 'package:gomed_user/screens/profile_screen.dart';
import 'package:gomed_user/screens/settings_screen.dart';
import 'package:gomed_user/screens/services.dart';
import 'package:gomed_user/providers/auth_state.dart';
import 'booking_screen.dart';
import 'home_page_content.dart';

class HomePage extends ConsumerStatefulWidget { 
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  String selectedCategory = "ALL";
  final List<String> categories = ["ALL", "Category 1", "Category 2", "Category 3"];

  // void _onCategorySelected(int index) {
  //   setState(() {
  //     _selectedIndex = 2; // Navigate to products screen
  //   });
  // }
   void _onCategorySelected(int index) {
  String selectedCategory = categories[index]; // ✅ Convert index to category
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductsScreen(selectedCategory: selectedCategory),
    ),
  );
}



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
        HomePageContent(onCategorySelected: _onCategorySelected),
        const ProfilePage(),
        ProductsScreen(selectedCategory: selectedCategory),
        BookingsPage(),
        ServicesPage(),
        SettingsPage(),
      ];

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userProvider);
    String ownerName = "User";
    String? profileImage;

    if (userModel.data != null && userModel.data!.isNotEmpty) {
      final user = userModel.data![0].user;
      ownerName = user?.name ?? "User";
      profileImage =
          user?.profileImage?.isNotEmpty == true ? user!.profileImage![0] : null;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.grey[100],
              elevation: 0,
               automaticallyImplyLeading: false,
              title: Row(
                children: [
                  if (profileImage != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                    )
                  else
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/gomedlogo.png"),
                    ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    'Welcome,\n$ownerName', // Interpolation for name
                    style: const TextStyle(
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
          : null,
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
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.miscellaneous_services), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
