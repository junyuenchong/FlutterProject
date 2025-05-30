import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/model/product/product.dart';
import 'package:ecommerce/widgets/alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

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
      productImgPath = image.path; // show local image
      update();

      String? imageUrl = await uploadImageToFirebase(image);
      if (imageUrl.isNotEmpty) {
        productImgPath = imageUrl;
        update(); // show image from Firebase
      }
    }
  }

Future<String> uploadImageToFirebase(XFile image,
      {String fileName = 'product_image.jpg'}) async {
    try {
      File file = File(image.path);

      if (!await file.exists()) {
        print("❌ File does not exist at path: ${file.path}");
        return '';
      }

      // Read image bytes and compute hash
      List<int> imageBytes = await file.readAsBytes();
      String imageHash = md5.convert(imageBytes).toString();
      print("🔑 MD5 Hash: $imageHash");

      // Optional: store previous hash to avoid re-upload
      // You can use SharedPreferences, Firestore, etc. to store and check previous image hash
      // If you want to always upload, skip this part.

      // Fixed file name to overwrite
      String firebasePath = 'images/$fileName';
      Reference ref = FirebaseStorage.instance.ref(firebasePath);

      // Upload and overwrite the file
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();

      print("✅ Image uploaded to: $firebasePath");
      print("🌐 Download URL: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading image: $e");
      return '';
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

Future<void> deleteProduct(String id, BuildContext context) async {
    try {
      // Delete product from Firestore
      await productCollection.doc(id).delete();

      // Fetch remaining products
      await fetchProducts();

      // If no products left, delete all images from Firebase Storage
      if (products.isEmpty) {
        await deleteAllImagesFromFirebase();
      }

      setValuesDefault();
      return Alert.show(context, 'Success', 'Product deleted successfully');
    } catch (err) {
      return Alert.show(context, 'Error', err.toString());
    }
  }

  Future<void> deleteAllImagesFromFirebase() async {
    try {
      final ListResult result =
          await FirebaseStorage.instance.ref('images/').listAll();

      for (Reference ref in result.items) {
        await ref.delete();
        print("🗑️ Deleted image: ${ref.name}");
      }

      print("✅ All images deleted from Firebase Storage.");
    } catch (e) {
      print("❌ Error deleting images: $e");
    }
  }

  Future<void> updateProduct(BuildContext context, String id) async {
    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.purpleAccent),
      );
    }
    try {
      String? finalImageUrl = productImgPath;

      // If it's a local path (not a URL), upload it
      if (productImgPath != null && !productImgPath!.startsWith('http')) {
        final XFile tempImage = XFile(productImgPath!);
        String uploadedUrl = await uploadImageToFirebase(tempImage);
        if (uploadedUrl.isNotEmpty) {
          finalImageUrl = uploadedUrl;
        }
      }

      Product updatedProduct = Product(
        id: id,
        name: productNameCtrl.text,
        category: category,
        description: productDescriptionCtrl.text,
        price: double.tryParse(productPriceCtrl.text),
        brand: brand,
        image: finalImageUrl,
        offer: offer,
      );

      await productCollection.doc(id).update(updatedProduct.toJson());
      await fetchProducts();
       Navigator.pop(context);
      return showError(
          'Success'
          'Product updated successfully',
        );
        

    } catch (err) {
      Get.snackbar('Error', err.toString(), colorText: Colors.red);
      print(err);
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
