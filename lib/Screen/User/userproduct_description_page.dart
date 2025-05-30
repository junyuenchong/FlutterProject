import 'dart:io';
import 'package:ecommerce/Screen/User/add_to_cart.dart';
import 'package:ecommerce/controller/userpurchase_controller.dart';
import 'package:ecommerce/model/cart/cart.dart';
import 'package:ecommerce/model/product/product.dart';
import 'package:ecommerce/widgets/itemcount_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserproductDescriptionPage extends StatelessWidget {
  const UserproductDescriptionPage({super.key});

  bool isUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    Uri uri = Uri.tryParse(imageUrl) ?? Uri();
    return uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    // Check if Get.arguments is not null and contains 'data'
    if (Get.arguments == null || Get.arguments['data'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Product data not found.'),
        ),
      );
    }

    // Make product observable
    final Rx<Product> product = Rx<Product>(Get.arguments['data']);
    final UserPurchaseController purchaseController =
        Get.find<UserPurchaseController>();
    var selectedQuantity = 1.obs; // Use an observable variable for quantity

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: isUrl(product.value.image)
                      ? Image.network(
                          product.value.image ?? '',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 200,
                        )
                      : Image.file(
                          File(product.value.image ?? ''),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 200,
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  product.value.name ?? '',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  product.value.description ?? '',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'Rs: ${product.value.price ?? ''}',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Obx(() => ItemCount1(
                      color: Colors.indigoAccent,
                      buttonSizeHeight: 50,
                      buttonSizeWidth: 100,
                      initialValue: selectedQuantity.value,
                      minValue: 1,
                      maxValue: 10,
                      decimalPlaces: 0,
                      onChanged: (value) {
                        selectedQuantity.value = value;
                      },
                      TextSizeHeight: 50,
                      TextSizeWidth: 50,
                    )),
                      ],
            )),
      ),
           bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),

                child:SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.indigoAccent,
                    ),
                    child: const Text(
                      'Add To Cart',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: () {
                      final box = GetStorage(); // Initialize GetStorage
                      Map<String, dynamic>? user = box.read('loginUser');
                      String? userName = user != null ? user['name'] : null;

                      // Check if user is logged in
                      if (userName == null) {
                        Get.snackbar('Error',
                            'Please log in to add items to your cart.');
                        return; // Stop further execution
                      }

                      // Ensure product data is valid
                      if (product.value.id == null ||
                          product.value.name == null ||
                          product.value.image == null ||
                          product.value.price == null) {
                        Get.snackbar('Error',
                            'Product data is incomplete. Cannot add to cart.');
                        return; // Stop further execution
                      }

                      // Add the product to the cart using the controller
                      purchaseController.addToCart(
                        Cart(
                          orderid: product.value.id,
                          name: product.value.name,
                          image: product.value.image,
                          price: product.value.price,
                          quantity: selectedQuantity.value,
                    
                        ),
                      );

                      Get.to(() => const AddToCartPage());
                      Get.snackbar('Added to Cart',
                          '${product.value.name} has been added to your cart.');
                    },
                  ),
                ),
                
           ),
     
    );
  }
}
