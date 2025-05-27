import 'package:ecommerce/widgets/drop_down_btn.dart';
import 'package:ecommerce/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // For File

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (ctrl) {
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
                  'Add Product',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.indigoAccent,
                      fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: ctrl.productNameCtrl,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      label: const Text('Product Name'),
                      hintText: 'Enter Your Product Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl.productDescriptionCtrl,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      label: const Text('Product Description'),
                      hintText: 'Enter Your Product Description'),
                  maxLines: 4,
                ),
                const SizedBox(height: 10),
                // Image picker icon button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_camera),
                      onPressed: () async {
                        await ctrl.pickImage();
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(ctrl.productImgPath != null
                        ? 'Image selected'
                        : 'No image selected')
                  ],
                ),
                ctrl.productImgPath != null
                    ? (ctrl.productImgPath!.startsWith('http')
                        ? Image.network(
                            ctrl.productImgPath!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : (File(ctrl.productImgPath!).existsSync()
                            ? Image.file(
                                File(ctrl.productImgPath!),
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                            : const Text('Image not found')))
                    : const Text('No image selected'),

                const SizedBox(height: 10),
                TextField(
                  controller: ctrl.productPriceCtrl,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      label: const Text('Product Price'),
                      hintText: 'Enter Your Product Price'),
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
                              ctrl.category = selectedValue ?? 'general';
                              ctrl.update();
                            })),
                    Flexible(
                        child: DropDownBtn(
                            item: const ['Puma', 'Adidas', 'Asics', 'Brooks'],
                            selectedItemText: ctrl.brand,
                            onSelected: (selectedValue) {
                              ctrl.brand = selectedValue ?? 'un brand';
                              ctrl.update();
                            }))
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Offer Product?"),
                const SizedBox(height: 10),
                DropDownBtn(
                  item: const ['true', 'false'],
                  selectedItemText: ctrl.offer.toString(),
                  onSelected: (selectedValue) {
                    ctrl.offer = bool.parse(selectedValue ?? 'false') ?? false;
                    ctrl.update();
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      ctrl.addProduct();
                    },
                    child: const Text('Add Product')),
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
          ),
        ),
      );
    });
  }
}
