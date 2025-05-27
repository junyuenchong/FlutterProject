import 'package:ecommerce/Screen/User/EditUserProfile.dart';
import 'package:ecommerce/Screen/User/add_to_cart.dart';
import 'package:ecommerce/Screen/User/checkout.dart';
import 'package:ecommerce/Screen/User/login_page.dart';
import 'package:ecommerce/Screen/User/userhome_page.dart';
import 'package:ecommerce/controller/home_controller.dart';
import 'package:ecommerce/controller/login_controller.dart';
import 'package:ecommerce/controller/userhome_controller.dart';
import 'package:ecommerce/controller/userpurchase_controller.dart';
//AdminPage
// import 'package:ecommerce/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
// Load .env in your main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  // Prevent Firebase from being initialized multiple times
  // if (Firebase.apps.isEmpty) {
  //   await Firebase.initializeApp(options: firebaseOptions);
  // }
  await Firebase.initializeApp();

  
   await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // for Android
    // iosProvider: AppleProvider.deviceCheck, // for iOS
  );

  //registering my controller
  Get.put(HomeController());
  Get.put(LoginController());
  Get.put(UserhomeController());
  Get.put(UserPurchaseController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //AdminPage
      // home: const HomePage(),
      //UserPage
      // home: const LoginPage(),
      // home: const RegisterPage(),
      // home: const UserHomePage(),

      initialRoute: '/login', // Set the initial route to the login page
      getPages: [
        // Define your routes
        // User home page route
        GetPage(
            name: '/login', page: () => const LoginPage()), // Login page route
        GetPage(name: '/add_to_cart', page: () => const AddToCartPage()),
        GetPage(name: '/homepage', page: () => const UserHomePage()),
        GetPage(name: '/updateprofile', page: () => const UpdateProfilePage()),
        GetPage(name: '/checkout', page: () => Checkout()),
      ],
    );
  }
}
