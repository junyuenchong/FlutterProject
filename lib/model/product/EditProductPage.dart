import 'package:ecommerce/controller/home_controller.dart';
import 'package:ecommerce/widgets/drop_down_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class EditProductPage extends StatelessWidget {
  final String productId;

  const EditProductPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (ctrl) {
      final product = ctrl.products.firstWhereOrNull((p) => p.id == productId);

      if (product == null) {
        return const Center(
          child: Text(
            'Product not found',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        );
      }

      // Ensure product fields are initialized once
      ctrl.initEditProduct(product);

      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Edit Product',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.indigoAccent,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl.productNameCtrl,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      label: const Text('Product Name'),
                      hintText: 'Enter Product Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl.productDescriptionCtrl,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      label: const Text('Product Description'),
                      hintText: 'Enter Product Description'),
                  maxLines: 4,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_camera),
                      onPressed: () async {
                        await ctrl.pickImage();
                        ctrl.update();
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(ctrl.productImgPath != null
                        ? 'Image selected'
                        : 'No image selected')
                  ],
                ),
                if (ctrl.productImgPath != null)
                  ctrl.productImgPath!.startsWith('http')
                      ? Image.network(
                          ctrl.productImgPath!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : File(ctrl.productImgPath!).existsSync()
                          ? Image.file(
                              File(ctrl.productImgPath!),
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                          : const Text('Image not found'),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl.productPriceCtrl,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      label: const Text('Product Price'),
                      hintText: 'Enter Product Price'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: DropDownBtn(
                        item: const [
                          'Boots',
                          'Shoe',
                          'Beach Shoes',
                          'High heels'
                        ],
                        selectedItemText: ctrl.category,
                        onSelected: (selectedValue) {
                          if (selectedValue != null &&
                              selectedValue != ctrl.category) {
                            ctrl.category = selectedValue;
                            ctrl.update();
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: DropDownBtn(
                        item: const ['Puma', 'Adidas', 'Asics', 'Brooks'],
                        selectedItemText: ctrl.brand,
                        onSelected: (selectedValue) {
                          if (selectedValue != null &&
                              selectedValue != ctrl.brand) {
                            ctrl.brand = selectedValue;
                            ctrl.update();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Offer Product?"),
                const SizedBox(height: 10),
                DropDownBtn(
                  item: const ['true', 'false'],
                  selectedItemText: ctrl.offer.toString(),
                  onSelected: (selectedValue) {
                    if (selectedValue != null) {
                      ctrl.offer = selectedValue == 'true';
                      ctrl.update();
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        ctrl.updateProduct(context, productId);
                        ctrl.clearEditForm();
                      },
                      child: const Text('Save Changes'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        ctrl.clearEditForm();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
