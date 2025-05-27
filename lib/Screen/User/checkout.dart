import 'package:ecommerce/controller/userpurchase_controller.dart';
import 'package:ecommerce/widgets/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Checkout extends StatelessWidget {
  final UserPurchaseController controller = Get.put(UserPurchaseController());

  Checkout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
        elevation: 4.0, // Slight shadow for depth
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(), // Add nav bar for empty cart case

      body: GetBuilder<UserPurchaseController>(builder: (ctrl) {
        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchOrders();
          },
          child: ctrl.orders.isEmpty
              ? const Center(
                  child: Text(
                    'No orders found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: ctrl.orders.length,
                  itemBuilder: (context, index) {
                    final order = ctrl.orders[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            order.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      order.image!,
                                      height: 80, // Smaller image size
                                      width: 80, // Smaller image size
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const SizedBox(
                                    width: 80, height: 80), // Placeholder size
                            const SizedBox(
                                width: 16), // Space between image and text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order ID: ${order.orderid}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16, // Smaller font size
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Name: ${order.name}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .black54), // Smaller font size
                                  ),
                                  Text(
                                    'Customer: ${order.customer}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .black54), // Smaller font size
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'DateTime: ${order.getFormattedDateTime()} UTC+8',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    'Address: ${order.address}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    'Payment Status: ${order.paymentstatus}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Price: \$${order.price != null ? double.parse(order.price.toString()).toStringAsFixed(2) : 'N/A'}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange),
                                  ),
                                  Text(
                                    'Quantity: ${order.quantity ?? 0}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      }),
    );
  }
}
