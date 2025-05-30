import 'dart:io';
import 'package:ecommerce/controller/home_controller.dart';
import 'package:ecommerce/model/product/EditProductPage.dart';
import 'package:ecommerce/Screen/admin/add_product_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (ctrl) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Footware Admin"),
          ),
          body: ListView.builder(
              itemCount: ctrl.products.length,
              itemBuilder: (context, index) {
                // Check if the product image is a local path or a URL
                Widget imageWidget;
                if (ctrl.products[index].image != null &&
                    ctrl.products[index].image!.startsWith('http')) {
                  // Display image from network
                  imageWidget = Image.network(
                    ctrl.products[index].image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  );
                } else if (ctrl.products[index].image != null) {
                  // Display image from local file path
                  imageWidget = Image.file(
                    File(ctrl.products[index].image!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                } else {
                  // Display placeholder if no image is available
                  imageWidget = const Icon(Icons.image_not_supported);
                }

                return ListTile(
                  leading: SizedBox(
                    width: 50, // Specify the width for the image widget
                    height: 50, // Specify the height for the image widget
                    child: imageWidget,
                  ),
                  title: Text(ctrl.products[index].name ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((ctrl.products[index].price ?? 0).toString()),
                      if (ctrl.products[index].offer != null)
                        Text(
                          'Offer: ${ctrl.products[index].offer}',
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Get.to(EditProductPage(
                              productId: ctrl.products[index].id!));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
<<<<<<< HEAD
                          ctrl.deleteProduct(
                            ctrl.products[index].id ?? '',
                            context,
                          );
=======
                          ctrl.deleteProduct(ctrl.products[index].id ?? '');
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
                        },
                      ),
                    ],
                  ),
                );
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(const AddProductPage());
            },
            child: const Icon(Icons.add),
          ));
    });
  }
}
