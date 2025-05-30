import 'package:ecommerce/main.dart';
import 'package:ecommerce/model/product/product.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter binding is initialized before any async calls
  await GetStorage.init(); // Initialize GetStorage before running the app
  runApp(const MyApp());
}
class UserproductCartlistPag extends StatelessWidget {
  // This would typically come from a cart provider or controller.
  final List<Product> cartItems = Get.arguments['cartItems'] ?? [];

  UserproductCartlistPag({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return CartItemCard(product: cartItems[index]);
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  child: const Text('Proceed to Checkout'),
                  onPressed: () {
                    // Handle checkout logic here
                  },
                ),
              ),
            )
          : null,
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Product product;
  const CartItemCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // This would typically get the quantity from a state management solution
    int quantity = 1; // For demonstration purposes

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.image ?? '',
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Rs: ${product.price ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Quantity: $quantity'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () {
                // Handle remove item from cart logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}
