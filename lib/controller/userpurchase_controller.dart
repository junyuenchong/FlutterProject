import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Screen/User/login_page.dart';
import 'package:ecommerce/model/address/address.dart';
import 'package:ecommerce/model/cart/cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ecommerce/model/order/order.dart';

class UserPurchaseController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final box = GetStorage();

  // Observable list to track items in the cart
  var cartItems = <Cart>[].obs;
  var orders = <Orders>[].obs;

  // Observable for user login status
  var user = <String, dynamic>{}.obs;

  // Observable list for addresses
  final addresses = <String>[].obs; // List of addresses

  // To store the selected default address
  final defaultAddress = ''.obs;

// Define a reactive variable for the default address
  var calldefaultAddress =
      Rx<String?>(null); // Rx<String?> can be initialized with null.

  @override
  void onInit() {
    super.onInit();
    loadUser(); // Load user data when the controller is initialized
    loadAddresses(); // Load addresses when the controller is initialized
    fetchCart();
    fetchOrders();
    fetchDefaultAddress();
    
  }

  // Load user data into the observable
void loadUser() {
  Map<String, dynamic>? storedUser = box.read('loginUser');

   if (storedUser?.isNotEmpty ?? false) {
    user.value = storedUser!; // Update the observable user map
    print('name: ${storedUser['name']}');
  } else {
    user.value = {}; // Set user to an empty map if no user is found
    print('No user data found');
  }
}


  // Check if the user is logged in
  bool isLoggedIn() {
    return user.isNotEmpty;
  }

  // Add item to the cart with login check
  void addToCart(Cart cart) {
    // Retrieve the logged-in user's details from GetStorage
    Map<String, dynamic>? storedUser = box.read('loginUser');

    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to add items to the cart');
      Get.to(
          () => const LoginPage()); // Redirect to login page if not logged in
      return;
    }

    // Extract the user's ID from the stored user data
    String userId = storedUser['id'];

    // Check if the item already exists in the cart
    var existingOrder = cartItems
        .firstWhereOrNull((element) => element.orderid == cart.orderid);

    if (existingOrder != null) {
      // If item exists, update the quantity
      updateQuantity(cartItems.indexOf(existingOrder),
          existingOrder.quantity + cart.quantity);
    } else {
      // If item does not exist, add it to the cart
      cartItems.add(cart);
      saveToFirebase(userId, cart); // Save to Firebase under the user's orders
    }
    Get.snackbar('Success', 'Item added to cart successfully!');
    update(); // Refresh the UI
  }

  // Save cart item to Firebase under user's document
  void saveToFirebase(String userId, Cart cart) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cart.orderid)
          .set({
        ...cart.toJson(),
        // Optionally include a timestamp
        // 'dateTime': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Item added to Firebase under your orders!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> fetchCart() async {
    // Retrieve the logged-in user data
    Map<String, dynamic>? storedUser = box.read('loginUser');

    // Check if user data is available
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to fetch cart items');
      Get.to(
          () => const LoginPage()); // Redirect to login page if not logged in
      return;
    }

    // Extract the user's ID from the stored user data
    String userId = storedUser['id'];

    try {
      // Query Firestore to get all cart items for the logged-in user
      QuerySnapshot cartSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('cart') // Ensure this is the correct collection
          .get();

      // Check if there are documents in the snapshot
      if (cartSnapshot.docs.isEmpty) {
        Get.snackbar('Info', 'No items found in the cart.');
        return;
      }

      // Convert Firestore documents to Orders objects
      final List<Cart> retrievedCartItems = cartSnapshot.docs
          .map((doc) => Cart.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Clear current cart items and add the fetched items
      cartItems.clear();
      cartItems.assignAll(retrievedCartItems);

      // Optionally, display a success message
      Get.snackbar('Success', 'Cart fetched successfully',
          colorText: Colors.green);

      // Notify the UI to update
      update();
    } catch (err) {
      // Display an error message if fetching fails
      Get.snackbar('Error', 'Failed to fetch cart: $err',
          colorText: Colors.red);
      print('Fetch cart error: $err'); // Log the error for debugging
    }
  }

  Future<void> fetchOrders() async {
    // Retrieve the logged-in user data
    Map<String, dynamic>? storedUser = box.read('loginUser');

    // Check if user data is available
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to fetch cart items');
      Get.to(
          () => const LoginPage()); // Redirect to login page if not logged in
      return;
    }

    // Extract the user's ID from the stored user data
    String userId = storedUser['id'];

    try {
      // Query Firestore to get all cart items for the logged-in user
      QuerySnapshot orderSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('orders') // Ensure this is the correct collection
          .get();

      // Check if there are documents in the snapshot
      if (orderSnapshot.docs.isEmpty) {
        Get.snackbar('Info', 'No items found in the cart.');
        return;
      }

      // Convert Firestore documents to Orders objects
      final List<Orders> retrievedOrderItems = orderSnapshot.docs
          .map((doc) => Orders.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Clear current ord items and add the fetched items
      orders.clear();
      orders.assignAll(retrievedOrderItems);

      // Optionally, display a success message
      Get.snackbar('Success', 'Cart fetched successfully',
          colorText: Colors.green);

      // Notify the UI to update
      update();
    } catch (err) {
      // Display an error message if fetching fails
      Get.snackbar('Error', 'Failed to fetch cart: $err',
          colorText: Colors.red);
      print('Fetch cart error: $err'); // Log the error for debugging
    }
  }

  // Remove item from the cart
  void removeItem(int index) {
    Cart orderToRemove = cartItems[index];
    cartItems.removeAt(index);
    deleteFromFirebase(orderToRemove); // Remove from Firebase as well
    update(); // Refresh the UI
  }

  // Delete item from Firebase
  void deleteFromFirebase(Cart order) async {
    // Retrieve the logged-in user's details from GetStorage
    Map<String, dynamic>? storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to add items to the cart');
      Get.to(
          () => const LoginPage()); // Redirect to login page if not logged in
      return;
    }
    // Extract the user's ID from the stored user data
    String userId = storedUser['id'];
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(order.orderid)
          .delete();
      Get.snackbar('Success', 'Item removed from cart successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Update quantity of an item in the cart
  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      cartItems[index].quantity = newQuantity;
      updateFirebase(cartItems[index]);
      cartItems.refresh(); // Refresh observable
      update(); // Refresh the UI
    } else {
      removeItem(index); // If quantity is zero, remove the item
    }
  }

  // Update item quantity in Firebase
  void updateFirebase(Cart cart) async {
    // Retrieve the logged-in user's details from GetStorage
    Map<String, dynamic>? storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to add items to the cart');
      Get.to(
          () => const LoginPage()); // Redirect to login page if not logged in
      return;
    }
    // Extract the user's ID from the stored user data
    String userId = storedUser['id'];
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cart.orderid)
          .update({'quantity': cart.quantity});
      Get.snackbar('Success', 'Quantity updated successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Calculate total price of all items in the cart
  double get totalPrice {
    return cartItems.fold(
        0, (sum, item) => sum + (item.price ?? 0) * item.quantity);
  }

  // Load addresses from Firestore
  void loadAddresses() async {
    // Retrieve the logged-in user's details from GetStorage
    Map<String, dynamic>? storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to add items to the cart');
      Get.to(
          () => const LoginPage()); // Redirect to login page if not logged in
      return;
    }
    // Extract the user's ID from the stored user data
    String userId = storedUser['id'];
    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();
      addresses.value =
          snapshot.docs.map((doc) => doc['address'] as String).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load addresses: $e');
    }
  }

// Add item to the cart with login check
  void UserCheckout(List<Orders> orders) {
    // Retrieve the logged-in user's details from GetStorage
    Map<String, dynamic>? storedUser = box.read('loginUser');

    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to proceed with checkout');
      Get.to(
          () => const LoginPage()); // Redirect to login page if not logged in
      return;
    }

    // Extract the user's ID from the stored user data
    String userId = storedUser['id'];

    // Loop through the orders and save them to Firebase
    for (var order in orders) {
      saveOrderToFirebase(
          userId, order); // Save to Firebase under the user's orders
    }

    Get.snackbar('Success', 'Orders processed successfully!');
    fetchOrders();
    update(); // Refresh the UI
  }

// Save cart item to Firebase under user's document
  void saveOrderToFirebase(String userId, Orders order) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc()
          .set({
        ...order.toJson(),
        // Optionally include a timestamp
        // 'dateTime': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Success',
        'Item added to Firebase under your orders!',
        snackPosition: SnackPosition.BOTTOM, // Position it at the bottom or top
        duration:
            const Duration(seconds: 1), // Set a shorter duration if desired
        isDismissible: true, // Allow the user to dismiss it manually
        forwardAnimationCurve: Curves.easeIn, // Fast forward animation
        reverseAnimationCurve: Curves.easeOut, // Fast reverse animation
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Add a new address to Firestore
  Future<void> addAddress(String addressString,
      {bool isDefault = false}) async {
    final storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in');
      Get.to(() => const LoginPage());
      return;
    }

    final userId = storedUser['id'];
    final address = Address(address: addressString, isDefault: isDefault);

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add(address.toJson());
      loadAddresses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add address: $e');
    }
  }

  // Delete an address
  Future<void> deleteAddress(String address) async {
    final storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in');
      Get.to(() => const LoginPage());
      return;
    }

    final userId = storedUser['id'];

    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('address', isEqualTo: address)
          .get();

      // Loop through all matching addresses and delete them
      for (var doc in snapshot.docs) {
        // Deserialize the document snapshot to an Address object
        Address addressObj = Address.fromJson(
            doc.data()); // Check if the address matches and proceed to delete
        if (addressObj.address == address) {
          await firestore
              .collection('users')
              .doc(userId)
              .collection('addresses')
              .doc(doc.id)
              .delete();
        }
      }

      loadAddresses(); // Refresh address list after deletion
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete address: $e');
    }
  }

  // Update an address
  Future<void> updateAddress(String oldAddress, String newAddress) async {
    final storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in');
      Get.to(() => const LoginPage());
      return;
    }

    final userId = storedUser['id'];
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('address', isEqualTo: oldAddress)
          .get();

      for (var doc in snapshot.docs) {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(doc.id)
            .update({'address': newAddress});
      }
      loadAddresses();
      fetchDefaultAddress();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update address: $e');
    }
  }

  // Set a default address
  void setDefaultAddress(String address) async {
    final storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in');
      Get.to(() => const LoginPage());
      return;
    }

    final userId = storedUser['id'];

    try {
      // Update the UI with the new default address
      defaultAddress.value = address;

      // Step 1: Set all addresses as not default
      final allAddressesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      // Set 'isDefault' to false for all addresses
      for (var doc in allAddressesSnapshot.docs) {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(doc.id)
            .update({'isDefault': false});
      }

      // Step 2: Check if the selected address already exists
      final addressesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('address', isEqualTo: address)
          .get();

      // If the address doesn't exist, add it
      if (addressesSnapshot.docs.isEmpty) {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .add({'address': address, 'isDefault': true});
      } else {
        // If the address exists, update it to be the default
        for (var doc in addressesSnapshot.docs) {
          await firestore
              .collection('users')
              .doc(userId)
              .collection('addresses')
              .doc(doc.id)
              .update({'isDefault': true});
        }
      }

      Get.snackbar('Success', 'Default address updated successfully!');
      fetchDefaultAddress(); // Refresh the default address
    } catch (e) {
      Get.snackbar('Error', 'Failed to update address: $e');
    }
  }

  // Fetch the default address

  void fetchDefaultAddress() async {
    final storedUser = box.read('loginUser');
    if (storedUser == null || storedUser.isEmpty) {
      Get.snackbar('Error', 'You must be logged in');
      Get.to(() => const LoginPage());
      return;
    }

    final userId = storedUser['id'];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Convert the first document snapshot to an Address model
        Map<String, dynamic> addressJson = snapshot.docs.first.data();
        Address address = Address.fromJson(addressJson);

        // Update the Rx variable with the address
        calldefaultAddress.value = address.address;
        String? defaultMyAddress = calldefaultAddress.value;
      } else {
        calldefaultAddress.value = null;
      }
    } catch (e) {
      print('Error fetching default address: $e');
      calldefaultAddress.value = null;
    }
  }
}
