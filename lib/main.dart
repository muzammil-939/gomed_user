import 'package:flutter/material.dart';
// import "package:font_awesome_flutter/font_awesome_flutter.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/providers/auth_state.dart';
import 'package:gomed_user/screens/booking_screen.dart';
import 'package:gomed_user/screens/home_page.dart';
import 'package:gomed_user/screens/login_screen.dart'; // Import Riverpod
import 'package:gomed_user/screens/profile_screen.dart';
import 'package:gomed_user/screens/services.dart';
import 'package:gomed_user/screens/settings_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'dart:math';

//🟢 Global key for showing SnackBar from anywhere
final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );
    print("🔥 Firebase project in use: ${app.options.projectId}");


  // Restrict orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp( 
    const ProviderScope(
      // Wrap your app with ProviderScope
      child: MyApp(),
    ),
  );
}
String generateOtp() {
  final random = Random();
  return (100000 + random.nextInt(900000)).toString(); // 6-digit
}

String generatebookingOtp() {
  final random = Random();
  // Generate a 4-digit number between 1000 and 9999
  int otp = 1000 + random.nextInt(9000);
  return otp.toString();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();
   _connectivityStream = _connectivity.onConnectivityChanged.map((list) => list.first);


    _connectivityStream.listen((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;

      globalMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            isConnected ? '✅ Back online' : '🚫 No internet connection',
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,  scaffoldMessengerKey: globalMessengerKey,
    
    routes: {
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
       // "bookingstagepage":(context)=>const BookingStagePage(),
        //"home_page_content":(context)=>const HomePageContent(),
        "home_page":(context)=>const HomePage(),
         "login_screen":(context)=>const LoginScreen(),
        // "products_screen":(context)=>const ProductsScreen(),
        "profile_screen":(context)=>const ProfilePage(),
        "settings_screen":(context)=>const SettingsPage(),
        "services":(context)=>const ServicesPage(),
        //"payment":(context)=>const PaymentPage()
        // "service_details":(context)=>const ServiceDetailsPage(),
         //"ordertracking":(context)=>const OrderTrackingPage(),
    });
  }
}


