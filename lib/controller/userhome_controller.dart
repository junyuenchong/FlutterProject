import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/model/product/product.dart';
import 'package:ecommerce/model/product_category/product_category.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserhomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference productCollection;
  late CollectionReference categoryCollection;
  List<Product> products = [];
  List<Product> productShowInUI = [];
  List<ProductCategory> productCategories = [];

  @override
  Future<void> onInit() async {
    super.onInit();
    productCollection = firestore.collection('products');
    categoryCollection = firestore.collection('category');
    await fetchCategory();
    await fetchProducts();
  }

  // Fetch products from Firestore
  Future<void> fetchProducts() async {
    try {
      QuerySnapshot productSnapshot = await productCollection.get();
      final List<Product> retrievedProducts = productSnapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .where((product) => product.name != null) // ✅ Ensure product has a name
          .toList();
      products.clear();
      products.assignAll(retrievedProducts);
      productShowInUI.assignAll(products);
      update();
      Get.snackbar('Success', 'Products fetched successfully', colorText: Colors.green);
    } catch (err) {
      Get.snackbar('Error', 'Failed to fetch products: $err', colorText: Colors.red);
      print("Error fetching products: $err");
    }
  }

  // Fetch product categories
  Future<void> fetchCategory() async {
    try {
      QuerySnapshot categorySnapshot = await categoryCollection.get();
      final List<ProductCategory> retrievedCategories = categorySnapshot.docs
          .map((doc) =>
              ProductCategory.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      productCategories.clear();
      productCategories.assignAll(retrievedCategories);
      update();
      Get.snackbar('Success', 'Categories fetched successfully', colorText: Colors.green);
    } catch (err) {
      Get.snackbar('Error', 'Failed to fetch categories: $err', colorText: Colors.red);
      print("Error fetching categories: $err");
    }
  }

  // Filter products by category
  void filterByCategory(String category) {
    productShowInUI.clear();
    if (category == 'all') {
      productShowInUI.assignAll(products); // Show all products
    } else {
      productShowInUI = products.where((product) => product.category == category).toList();
    }
    update();
  }

  // Filter products by selected brands
  void filterByBrand(List<String> brands) {
    if (brands.isNotEmpty) {
      List<String> lowerCaseBrands = brands.map((brand) => brand.toLowerCase()).toList();

      productShowInUI = products.where((product) {
        return product.brand != null &&
            lowerCaseBrands.contains(product.brand?.toLowerCase());
      }).toList();
    } else {
      productShowInUI.assignAll(products); // If no brands selected, show all products
    }
    update();
  }

  // Sort products by price (ascending or descending)
  void sortByPrice({required bool ascending}) {
    List<Product> sortedProducts = List<Product>.from(productShowInUI);
    sortedProducts.sort((a, b) => ascending
        ? a.price!.compareTo(b.price!)
        : b.price!.compareTo(a.price!));
    productShowInUI = sortedProducts;
    update();
  }

  // Search for products by query
  void search(String query) {
    if (query.isEmpty) {
      productShowInUI.assignAll(products);
    } else {
      String lowerCaseQuery = query.toLowerCase();

      productShowInUI = products.where((product) {
        return (product.name?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
            (product.category?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
            (product.brand?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
    }
    update();
  }

 


  
}
