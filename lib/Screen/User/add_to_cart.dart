import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/model/order/order.dart';
import 'package:ecommerce/widgets/address.dart';
import 'package:ecommerce/widgets/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ecommerce/controller/userpurchase_controller.dart';
import 'package:ecommerce/Screen/User/checkout.dart';

class AddToCartPage extends StatelessWidget {
  const AddToCartPage({super.key});
  bool isUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    Uri uri = Uri.tryParse(imageUrl) ?? Uri();
    return uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserPurchaseController>(builder: (ctrl) {
      // Check if cartItems is empty directly
      if (ctrl.cartItems.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart'),
          ),
          body: const Center(
            child: Text('No items in your cart'),
          ),
          bottomNavigationBar:
              const CustomBottomNavBar(), // Add nav bar for empty cart case
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Obx(() => Text(
                    "Default address: ${ctrl.calldefaultAddress.value ?? 'No default address set'}",
                    style: const TextStyle(fontSize: 16),
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddressDialog(context); // Show address management dialog
              },
              child: const Text('Manage Address'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ctrl.cartItems.length,
                itemBuilder: (context, index) {
                  final order = ctrl.cartItems[index]; // Get the current order

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: isUrl(order.image)
                          ? Image.network(
                              order.image ?? '',
                              width: 80, // Adjust width
                              height: 150, // Adjust height
                              fit: BoxFit
                                  .cover, // Adjust how the image should be inscribed into the box
                            )
                          : Image.file(
                              File(order.image ?? ''),
                              width: 80, // Adjust width
                              height: 150, // Adjust height
                              fit: BoxFit
                                  .cover, // Adjust how the image should be inscribed into the box
                            ),
                      title: Text(order.name ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Price: \$${order.price?.toStringAsFixed(2) ?? '0.00'}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (order.quantity > 1) {
                                    ctrl.updateQuantity(
                                        index, order.quantity - 1);
                                  }
                                },
                              ),
                              Text('${order.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => ctrl.updateQuantity(
                                    index, order.quantity + 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => ctrl.removeItem(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Subtotal: \$${ctrl.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                child: const Text('Checkout'),
                onPressed: () {
                  // Ensure cartItems is not empty
                  if (ctrl.cartItems.isEmpty) {
                    return; // Optionally show an alert if the cart is empty
                  }

                  // Loop through each item in cartItems and create Orders
                  final orders = ctrl.cartItems.map((item) {
                    final box = GetStorage(); // Initialize GetStorage
                    Map<String, dynamic>? user = box.read('loginUser');
                    String? userName = user != null ? user['name'] : null;
                    return Orders(
                      orderid: item.orderid ?? '',
                      image: item.image ?? '',
                      price: item.price ?? 0.0,
                      name: item.name,
                      quantity: item.quantity,
                      paymentstatus: "pending",
                      address: ctrl
                          .defaultAddress.value, // Use the default address here
                      customer: userName,
                      dateTime: Timestamp.now(),
                    );
                  }).toList();

                  // Pass the list of orders for checkout
                  ctrl.UserCheckout(orders);
                  Get.to(() => Checkout());
                },
              ),
            ),
            const CustomBottomNavBar(), // Add the custom navigation bar here
          ],
        ),
      );
    });
  }

  // Function to show the address management dialog
  void _showAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manage Address'),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.5, // 80% of screen width
            height: MediaQuery.of(context).size.height *
                0.2, // 60% of screen height
            child:
                AddressManagement(), // A widget to handle the list of addresses
          ), // A widget to handle the list of addresses
          actions: <Widget>[
            TextButton(
              child: const Text('Add Address'),
              onPressed: () {},
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
