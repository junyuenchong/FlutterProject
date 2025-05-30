import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Screen/User/userhome_page.dart';
import 'package:ecommerce/model/user/user.dart' as AppUser;
import 'package:ecommerce/services/email_service.dart';
import 'package:ecommerce/services/twilio_service.dart';
import 'package:ecommerce/widgets/CryptPassword.dart';
import 'package:ecommerce/widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';

class LoginController extends GetxController {
  final GetStorage box = GetStorage(); // Local storage instance
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Firestore instance
  late CollectionReference userCollection; // Firestore user collection ref

// Text controllers for registration and login inputs
  final TextEditingController registerNameCtrl = TextEditingController();
  final TextEditingController registerNumberCtrl = TextEditingController();
  final TextEditingController registerPasswordCtrl = TextEditingController();
  final TextEditingController registerConfirmPasswordCtrl =
      TextEditingController();
  final TextEditingController registerEmailCtrl = TextEditingController();
  final TextEditingController loginNumberCtrl = TextEditingController();
  final TextEditingController loginPasswordCtrl = TextEditingController();

  final OtpFieldControllerV2 otpController =
      OtpFieldControllerV2(); // OTP input controller

  int? otpSend; // OTP sent to user
  int? otpEnter; // OTP entered by user

// Reactive variables for UI state management
  var verificationMethod = 'phone'.obs; // Current verification method
  var phoneReadOnly = false.obs; // Phone field editable state
  var emailReadOnly = false.obs; // Email field editable state
  var showChangeLink = false.obs; // Show change method link
  var otpFieldShown = false.obs; // Show OTP input field

  final Rxn<AppUser.User> loginUser =
      Rxn<AppUser.User>(); // Logged-in user data

  @override
  void onReady() {
    // Load saved user from local storage and navigate to home if found
    final user = box.read('loginUser');
    if (user != null) {
      loginUser.value = AppUser.User.fromJson(user);
      // Navigate to the user's home page
      Get.to(() => const UserHomePage());
    }
    super.onReady();
  }

  @override
  void onInit() {
    // Set Firestore 'users' collection reference and call super.onInit
    userCollection = firestore.collection('users');
    super.onInit();
  }

  // Update the verification method (e.g., 'email' or 'phone')// Update the verification method (e.g., 'email' or 'phone')
  void setVerificationMethod(String method) {
    verificationMethod.value = method;
  }

  Future<void> sendOtp(BuildContext context) async {
    try {
      // Generate OTP
      final random = Random();
      int otp = 1000 + random.nextInt(9000);
      otpSend = otp;

      /*                                                         */
      /*                verificationMethod = phone               */
      /*                                                         */
      if (verificationMethod == 'phone') {
        //Set Phone TextField
        final phone = registerNumberCtrl.text.trim();

        //Convert to int
        int? intphone = int.tryParse(phone);

        //SetFullPhone
        final fullPhoneNumber = phone.startsWith('+') ? phone : '+$phone';

        /*                                                         */
        /*                  validatePhoneNumber                    */
        /*                                                         */
        //Check phone is empty
        if (phone.isEmpty) {
          Alert.show(context, 'Error', 'Please enter phone number');
          return;
        }
        // Validate Malaysian format: e.g., 60123456789 (min 12 digits including +)
        if (!RegExp(r'^60\d{9}$').hasMatch(phone)) {
          Alert.show(context, 'Error',
              'Invalid phone number format. Example: 60123129895');
          return;
        }
        // 🔍 Check if phone already registered
        final existingPhoneUsers =
            await userCollection.where("number", isEqualTo: intphone).get();
        if (existingPhoneUsers.docs.isNotEmpty) {
          Alert.show(
              context, 'Error', 'This phone number is already registered');
          return;
        }
        /*                                                         */
        /*                        Send OTP                         */
        /*                                                         */
        // ✅ Send OTP
        final sent = await TwilioService.sendOtp(fullPhoneNumber, otp);
        if (sent) {
          Alert.show(context, 'OTP Sent', 'OTP sent to $fullPhoneNumber');
          otpFieldShown.value = true;
          phoneReadOnly.value = true;
          showChangeLink.value = true;
        } else {
          Alert.show(context, 'Error', 'Failed to send OTP via Twilio');
        }
      } else {
        /*                                                         */
        /*                verificationMethod = email               */
        /*                                                         */
        // Email format regex check
        final email = registerEmailCtrl.text.trim();
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        /*                                                         */
        /*                       validateEmail                     */
        /*                                                         */
        // Check email is empty error
        if (email.isEmpty) {
          Alert.show(context, 'Error', 'Please enter email');
          return;
        }
        //Check email format validity
        if (!emailRegex.hasMatch(email)) {
          Alert.show(context, 'Error',
              'Please enter a valid email address (e.g., example@domain.com).');
          return;
        }
        // 🔍 Check if email already registered
        final existingEmailUsers =
            await userCollection.where('email', isEqualTo: email).get();
        if (existingEmailUsers.docs.isNotEmpty) {
          return Alert.show(
              context, 'Error', 'This email is already registered');
        }
        /*                                                         */
        /*                        Send OTP                         */
        /*                                                         */

        // ✅ Send OTP
        final sent = await EmailService.sendOtp(email, otp);
        if (sent) {
          //Alert OTP sent
          Alert.show(context, 'OTP Sent', 'OTP sent to $email');
          // Show the OTP field
          otpFieldShown.value = true;
          emailReadOnly.value = true;
          showChangeLink.value = true;
        } else {
          Alert.show(context, 'Error', 'Failed to send OTP via Email');
        }
      }
    } catch (e) {
      Alert.show(context, 'Error', 'Failed to send OTP: $e');
    }
  }

  Future<void> addUser(BuildContext context) async {
    try {
      final password = registerPasswordCtrl.text;
      // Encrypt the password before saving
      String encryptedPassword = PasswordUtils.hashPassword(password);
      final confirmPassword = registerConfirmPasswordCtrl.text;
      final name = registerNameCtrl.text.trim();
      final phoneText = registerNumberCtrl.text.trim();
      // Parse the phone number from the text input
      int? phone = int.tryParse(phoneText);
      final email = registerEmailCtrl.text.trim();
      /*                                                         */
      /*               Register Validation                       */
      /*                                                         */

      if (name.isEmpty) {
        return Alert.show(context, 'Error', 'Please enter your name');
      }

      if (password.isEmpty || confirmPassword.isEmpty) {
        return Alert.show(context, 'Error',
            'Please enter your password and confirm password');
      }

      final passwordRegex =
          RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

      if (!passwordRegex.hasMatch(password)) {
        return Alert.show(context, 'Invalid Password',
            'Password must be at least 8 characters long,\ninclude uppercase, lowercase, number, and special character.');
      }

      if (password != confirmPassword) {
        return Alert.show(context, 'Error', 'Passwords do not match');
      }
      if (otpSend != otpEnter) {
        return Alert.show(context, 'Error', 'OTP is incorrect');
      }
      /*                                                         */
      /*              Check Email or Phone Validation            */
      /*                                                         */

      if (verificationMethod == 'email') {
        // Check if email field is empty
        if (email.isEmpty) {
          return Alert.show(context, 'Error', 'Email cannot be empty');
        }
        // Check if email format
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          return Alert.show(
              context, 'Error', 'Please enter a valid email address');
        }
      } else if (verificationMethod == 'phone') {
        // Check if phone field is empty
        if (phoneText.isEmpty) {
          return Alert.show(context, 'Error', 'Phone number cannot be empty');
        }

        if (phoneText.length < 7) {
          return Alert.show(context, 'Error', 'Invalid phone number format');
        }
      }
      /*                                                         */
      /*              Save the user data to Firestore            */
      /*                                                         */
      // Create a new document reference in the user collection
      DocumentReference doc = userCollection.doc();
      AppUser.User user = AppUser.User(
        id: doc.id,
        name: name,
        number: phone,
        password: encryptedPassword,
        email: email,
      );

      // Save the user data to Firestore
      await doc.set(user.toJson());
      /*                                                                    */
      /* Clear all registration input fields after successful user creation */
      /*                                                                    */
      clearRegisterFields();
      Alert.show(context, 'Success', 'User added successfully');
    } catch (err) {
      Alert.show(context, 'Error', 'Failed to register user');
    }
  }

  Future<void> loginWithPhoneOrEmail(BuildContext context) async {
    try {
      /*                                                         */
      /*     Set Identifier and Password Text Fields             */
      /*                                                         */
      // Retrieve and trim input values
      final identifier = loginNumberCtrl.text.trim();
      final password = loginPasswordCtrl.text.trim();
      /*                                                         */
      /*     Validate Identifier and Password Text Fields        */
      /*                                                         */
      // Validate inputs
      if (identifier.isEmpty || password.isEmpty) {
        Alert.show(
            context, 'Error', 'Please enter both identifier and password');
        return;
      }

      /*                                                         */
      /*              Email/Phone Login                          */
      /*                                                         */

      QuerySnapshot querySnapshot;
      // Check if identifier is email or phone number and query accordingly
      if (identifier.contains('@')) {
        // Validate Gmail format
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(identifier)) {
          Alert.show(context, 'Error',
              'Invalid email format. Example: example@gmail.com');
          return;
        }

        // Email login
        querySnapshot = await userCollection
            .where('email', isEqualTo: identifier)
            .limit(1)
            .get();
      } else {
        // Validate phone number format (must be 11 digits starting with 60)
        if (!RegExp(r'^60\d{9,11}$').hasMatch(identifier)) {
          Alert.show(context, 'Error',
              'Invalid phone number format. Example: 60123129895');
          return;
        }
        // Phone login - ensure valid phone number format
        final phone = int.tryParse(identifier);
        // Phone login
        querySnapshot = await userCollection
            .where('number', isEqualTo: phone)
            .limit(1)
            .get();
      }

      // Check if any user document was returned from Firestore
      if (querySnapshot.docs.isEmpty) {
        // If no user is found, show error and return early
        Alert.show(context, 'Error', 'User not found, please register');
        return;
      }

      // Extract user data from the first document in the query result
      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

      // Get the stored hashed password from the user document
      final storedHashedPassword = userData['password'] as String;

      // Use your password utility to compare the entered password with the stored hash
      final isPasswordValid =
          PasswordUtils.verifyPassword(password, storedHashedPassword);

      // If the password doesn't match, show an error and return
      if (!isPasswordValid) {
        Alert.show(context, 'Error', 'Incorrect password');
        return;
      }

      // Save the logged-in user's data locally using GetStorage (persistent storage)
      box.write('loginUser', userData);

      // Convert the user data from Firestore into a User model instance for app-wide access
      loginUser.value = AppUser.User.fromJson(userData);

      // Navigate to user home page
      Get.offAll(() => const UserHomePage());
      // Alert.show(context, 'Success', 'Login Successful');
      Get.snackbar(
        'Success',
        'Login Successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.purpleAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      // Clear input fields
      loginNumberCtrl.clear();
      loginPasswordCtrl.clear();
    } catch (e) {
      return Alert.show(context, 'Error', 'Failed to login: ${e.toString()}');
    }
  }

  Future<void> updateUserPassword(
      BuildContext context,
      TextEditingController passwordController,
      TextEditingController confirmPasswordController) async {
    // Access the text values
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    /*                                                         */
    /*   Helper method to show error messages using SnackBar   */
    /*                                                         */

    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }

    try {
      final user = loginUser.value;
      /*                                                         */
      /*                showValidationMessage                    */
      /*                                                         */
      // Check if user is logged in
      if (user == null) return showError('No logged-in user found');

      // Check if both password fields are filled
      if (password.isEmpty || confirmPassword.isEmpty) {
        return showError('Both fields are required');
      }

      // Define password strength criteria using regex
      final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
      );

      // Validate password format
      if (!passwordRegex.hasMatch(password)) {
        return showError(
          'Password must be at least 8 characters and include:\n'
          '- Uppercase letter\n- Lowercase letter\n- Number\n- Special character',
        );
      }

      // Check if password and confirm password match
      if (password != confirmPassword) {
        return showError('Passwords do not match');
      }

      // Ensure current password is available
      final currentHashedPassword = user.password;
      if (currentHashedPassword == null) {
        return showError('Password data is missing. Please log in again.');
      }

      // Check if new password is the same as the current password
      if (PasswordUtils.verifyPassword(password, currentHashedPassword)) {
        return showError(
            'New password cannot be the same as the current password');
      }

      // Hash the new password before saving
      final newHashedPassword = PasswordUtils.hashPassword(password);
      /*                                                         */
      /*                Update password to Firestore             */
      /*                                                         */
      // Update password in Firestore
      await userCollection.doc(user.id).update({'password': newHashedPassword});

      // Update local state and storage with new password
      user.password = newHashedPassword;
      loginUser.refresh();
      box.write('loginUser', user.toJson());

      // On successful update, clear the controllers
      passwordController.clear();
      confirmPasswordController.clear();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void clearRegisterFields() {
    registerNameCtrl.clear();
    registerNumberCtrl.clear();
    registerPasswordCtrl.clear();
    registerConfirmPasswordCtrl.clear();
    registerEmailCtrl.clear();
    otpController.clear();
    otpFieldShown.value = false;
    showChangeLink.value = false;
  }
}
