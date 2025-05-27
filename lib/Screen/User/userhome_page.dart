import 'package:ecommerce/Screen/User/login_page.dart';
import 'package:ecommerce/Screen/User/userproduct_description_page.dart';
import 'package:ecommerce/controller/userhome_controller.dart';
import 'package:ecommerce/widgets/CustomBottomNavBar.dart';

import 'package:ecommerce/widgets/drop_down_btn.dart';
import 'package:ecommerce/widgets/multi_select_drop_down.dart';
import 'package:ecommerce/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Import the custom bottom nav bar widget

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return GetBuilder<UserhomeController>(builder: (ctrl) {
      return RefreshIndicator(
        onRefresh: () async {
          ctrl.fetchProducts();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Footwear Store',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false, // Hides the back button
            actions: [
              IconButton(
                onPressed: () {
                  try {
                    GetStorage box = GetStorage();
                    box.remove(
                        'loginUser'); // Only remove login info, not everything

                    Get.offAll(() => LoginPage()); // Navigate to Login Page

                    Get.snackbar('Success', 'Logged out successfully',
                        colorText: Colors.green);
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to log out: ${e.toString()}',
                        colorText: Colors.red);
                  }
                },
                icon: const Icon(Icons.logout),
              )
            ],
          ),
          body: Column(
            children: [
              // Search Input and Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, category, or brand',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        ctrl.search(searchController.text.trim());
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
              // Categories
              SizedBox(
                height: 50,
                child: ListView.builder(
                  itemCount: ctrl.productCategories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        ctrl.filterByCategory(
                            ctrl.productCategories[index].name ?? '');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Chip(
                            label: Text(
                                ctrl.productCategories[index].name ?? 'Error')),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: DropDownBtn(
                      item: const ['Rs : Low to High', 'Rs: High to Low '],
                      selectedItemText: 'Sort',
                      onSelected: (selected) {
                        ctrl.sortByPrice(
                          ascending:
                              selected == 'Rs : Low to High' ? true : false,
                        );
                      },
                    ),
                  ),
                  Flexible(
                    child: MultiSelectDropDown(
                      items: const ['asics', 'puma', 'adidas', 'Shoe'],
                      onSelectionChanged: (selectedItems) {
                        print(selectedItems);
                        ctrl.filterByBrand(selectedItems);
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: ctrl.productShowInUI.length,
                  itemBuilder: (content, index) {
                    return ProductCard(
                      name: ctrl.productShowInUI[index].name ?? 'No name',
                      imageUrl: ctrl.productShowInUI[index].image ??
                          "No Image", // Pass the image URL or empty string if null
                      price: ctrl.productShowInUI[index].price ?? 0.0,
                      offerTag: '20%',
                      onTap: () {
                        Get.to(const UserproductDescriptionPage(),
                            arguments: {'data': ctrl.productShowInUI[index]});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Adding the custom bottom navigation bar
          bottomNavigationBar: const CustomBottomNavBar(),
        ),
      );
    });
  }
}
