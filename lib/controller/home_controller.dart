import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/model/product/product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference productCollection;

  // Add Product Text Controllers
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescriptionCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();

  String category = 'general';
  String brand = 'un brand';
  bool offer = false;
  String? productImgPath; // Store local image path temporarily

  List<Product> products = [];

  @override
  Future<void> onInit() async {
    productCollection = firestore.collection('products');
    await fetchProducts();
    super.onInit();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      productImgPath = image.path; // local path
      update(); // show local image immediately

      String? imageUrl = await uploadImageToFirebase(image);
      if (imageUrl.isNotEmpty) {
        productImgPath = imageUrl; // URL from firebase
        update(); // important! update UI again to show image from URL
      }
    }
  }

  Future<String> uploadImageToFirebase(XFile image) async {
    try {
      File file = File(image.path);
      String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      Reference ref = FirebaseStorage.instance.ref(fileName);

      // Upload the file
      await ref.putFile(file);
      print("Image uploaded successfully: $fileName");

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();
      print("Download URL: $downloadUrl");
      return downloadUrl; // Return the download URL
    } catch (e) {
      print("Error uploading image: $e");
      return ''; // Return an empty string on error
    }
  }

  Future<void> addProduct() async {
    try {
      DocumentReference doc = productCollection.doc();
      Product product = Product(
        id: doc.id,
        name: productNameCtrl.text,
        category: category,
        description: productDescriptionCtrl.text,
        price: double.tryParse(productPriceCtrl.text),
        brand: brand,
        image: productImgPath, // Store the URL from Firebase Storage
        offer: offer,
      );
      final productJson = product.toJson();
      await doc.set(productJson);
      Get.snackbar('Success', 'Product added successfully',
          colorText: Colors.green);
      setValuesDefault();
      fetchProducts(); // Fetch products after adding a new product
    } catch (err) {
      Get.snackbar('Error', err.toString(), colorText: Colors.red);
      print(err);
    }
  }

  Future<void> fetchProducts() async {
    try {
      QuerySnapshot productSnapshot = await productCollection.get();
      final List<Product> retrievedProducts = productSnapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      products.clear();
      products.assignAll(retrievedProducts);
      update();
    } catch (err) {
      Get.snackbar('Error', err.toString(), colorText: Colors.red);
      print(err);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await productCollection.doc(id).delete();
      fetchProducts(); // Fetch products after deleting a product
      setValuesDefault();
    } catch (err) {
      Get.snackbar('Error', err.toString(), colorText: Colors.red);
      print(err);
    }
  }

  Future<void> updateProduct(BuildContext context, String id) async {
    try {
      Product updatedProduct = Product(
        id: id,
        name: productNameCtrl.text,
        category: category,
        description: productDescriptionCtrl.text,
        price: double.tryParse(productPriceCtrl.text),
        brand: brand,
        image: productImgPath, // This should now be a URL
        offer: offer,
      );

      await productCollection.doc(id).update(updatedProduct.toJson());
      Get.snackbar('Success', 'Product updated successfully',
          colorText: Colors.green);
      fetchProducts();

      // Pop the current screen after a successful update
      Navigator.pop(context);
    } catch (err) {
      Get.snackbar('Error', err.toString(), colorText: Colors.red);
    }
  }

  // Reset to Default Values
  void setValuesDefault() {
    productNameCtrl.clear();
    productDescriptionCtrl.clear();
    productPriceCtrl.clear();
    productImgPath = null; // Reset image path to null

    category = 'general';
    brand = 'un brand';
    offer = false;
    update();
  }

  void initEditProduct(Product product) {
  if (productNameCtrl.text.isEmpty) {
    productNameCtrl.text = product.name ?? '';
    productDescriptionCtrl.text = product.description ?? '';
    productPriceCtrl.text = product.price.toString();
    category = product.category ?? 'general';
    brand = product.brand ?? 'un brand';
    offer = product.offer ?? false;
    productImgPath = product.image;
  }
}

void clearEditForm() {
  productNameCtrl.clear();
  productDescriptionCtrl.clear();
  productPriceCtrl.clear();
  category = 'general';
  brand = 'un brand';
  offer = false;
  productImgPath = null;
}


}
