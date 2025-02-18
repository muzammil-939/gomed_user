import 'package:flutter/material.dart';
// import "package:font_awesome_flutter/font_awesome_flutter.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/model/auth.dart';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/providers/firebase_auth.dart';
import 'package:gomed_user/screens/booking_screen.dart';
import 'package:gomed_user/screens/bookingstagepage.dart';
import 'package:gomed_user/screens/home_page.dart';
import 'package:gomed_user/screens/login_screen.dart'; // Import Riverpod
import 'package:gomed_user/screens/ordertracking.dart';
import 'package:gomed_user/screens/payment.dart';
import 'package:gomed_user/screens/products_screen.dart';
import 'package:gomed_user/screens/profile_screen.dart';
import 'package:gomed_user/screens/service_details.dart';
import 'package:gomed_user/screens/services.dart';
import 'package:gomed_user/screens/settings_screen.dart';
// import 'package:gomed_user/screens/welcom.dart';

import 'firebase_options.dart';
import 'screens/home_page_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    const ProviderScope(
      // Wrap your app with ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, routes: {
      '/': (context) {
        return Consumer(
  builder: (context, ref, child) {
    print("build main.dart");
    final authState = ref.watch(userProvider);

    // Extract access token
    final accessToken = authState.data?.isNotEmpty == true
        ? authState.data![0].accessToken
        : null;

    print('Access token in main.dart: $accessToken');

    if (accessToken != null && accessToken.isNotEmpty) {
      print('Valid access token found. Navigating to HomePage.');
      return const HomePage();
    }

    print('No valid access token. Attempting auto-login.');

    return FutureBuilder(
      future: ref.read(userProvider.notifier).tryAutoLogin(),
      builder: (context, snapshot) {
        print('Auto-login result: ${snapshot.data}');
        print('Snapshot connection state: ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

         // If auto-login is successful, navigate to the home page, else show login screen
                if (snapshot.hasData && snapshot.data == true) {
                  print('Auto-login successful. Navigating to HomePage.');
                  return const HomePage();
                } else {
                  print('Auto-login failed. Navigating to LoginScreen.');
                  return const LoginScreen();
                }
            },
           );
          },
         );
      },
      
        "booking_screen":(context)=>const BookingsPage(),
        "bookingstagepage":(context)=>const BookingStagePage(),
        //"home_page_content":(context)=>const HomePageContent(),
        "home_page":(context)=>const HomePage(),
         "login_screen":(context)=>const LoginScreen(),
        // "products_screen":(context)=>const ProductsScreen(),
        "profile_screen":(context)=>const ProfilePage(),
        "settings_screen":(context)=>const SettingsPage(),
        "services":(context)=>const ServicesPage(),
        //"payment":(context)=>const PaymentPage()
        "service_details":(context)=>const ServiceDetailsPage(),
         //"ordertracking":(context)=>const OrderTrackingPage(),
    });
  }
}
