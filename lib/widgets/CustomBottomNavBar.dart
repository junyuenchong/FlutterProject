import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_camera_front_outlined),
          label: 'EditProfile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.badge),
          label: 'Your Order',
        ),
        BottomNavigationBarItem(
         icon: Icon(Icons.add_shopping_cart), 
          label: 'cart',
        ),
      ],
      onTap: (index) {
        // Handle navigation based on the tapped index
        switch (index) {
          case 0:
            Get.offAllNamed('/homepage'); // Navigate to Home
            break;
          case 1:
            Get.offAllNamed('/updateprofile'); // Navigate to Search
            break;
          case 2:
            Get.offAllNamed('/checkout'); // Navigate to Favorites
            break;
          case 3:
         Get.offAllNamed('/add_to_cart'); //Navigate to Add to Cart
            break;
        }
      },
    );
  }
}
