import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Screen/User/userhome_page.dart';
import 'package:ecommerce/model/user/user.dart' as AppUser;
import 'package:ecommerce/services/email_service.dart';
import 'package:ecommerce/services/twilio_service.dart';
import 'package:ecommerce/widgets/CryptPassword.dart';
<<<<<<< HEAD
import 'package:ecommerce/widgets/alert.dart';
=======
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
<<<<<<< HEAD

class LoginController extends GetxController {
  final GetStorage box = GetStorage(); // Local storage instance
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Firestore instance
  late CollectionReference userCollection; // Firestore user collection ref

// Text controllers for registration and login inputs
=======
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final GetStorage box = GetStorage();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late CollectionReference userCollection;

>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
  final TextEditingController registerNameCtrl = TextEditingController();
  final TextEditingController registerNumberCtrl = TextEditingController();
  final TextEditingController registerPasswordCtrl = TextEditingController();
  final TextEditingController registerConfirmPasswordCtrl =
      TextEditingController();
  final TextEditingController registerEmailCtrl = TextEditingController();
  final TextEditingController loginNumberCtrl = TextEditingController();
  final TextEditingController loginPasswordCtrl = TextEditingController();

<<<<<<< HEAD
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
=======
  final OtpFieldControllerV2 otpController = OtpFieldControllerV2();
  bool otpFieldShown = false;
  int? otpSend;
  int? otpEnter;
  String verificationMethod = 'phone'; // default is phone

  AppUser.User? loginUser;
  final TextEditingController _emailController = TextEditingController();
  final String _verificationCode = "";
  @override
  void onReady() {
    final user = box.read('loginUser');
    if (user != null) {
      loginUser = AppUser.User.fromJson(user);
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
      Get.to(() => const UserHomePage());
    }
    super.onReady();
  }

  @override
  void onInit() {
<<<<<<< HEAD
    // Set Firestore 'users' collection reference and call super.onInit
=======
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
    userCollection = firestore.collection('users');
    super.onInit();
  }

<<<<<<< HEAD
  // Update the verification method (e.g., 'email' or 'phone')// Update the verification method (e.g., 'email' or 'phone')
  void setVerificationMethod(String method) {
    verificationMethod.value = method;
=======
  void setVerificationMethod(String method) {
    verificationMethod = method;
    update();
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
  }

  Future<void> sendOtp(BuildContext context) async {
    try {
<<<<<<< HEAD
=======
      // Validate name
      if (registerNameCtrl.text.isEmpty) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter your name'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ],
        ));
        return;
      }

>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
      // Generate OTP
      final random = Random();
      int otp = 1000 + random.nextInt(9000);
      otpSend = otp;
<<<<<<< HEAD

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
=======
      otpFieldShown = true;

      // Decide based on verification method
      if (verificationMethod == 'phone') {
        if (registerNumberCtrl.text.isEmpty) {
          Get.dialog(AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter phone number'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'))
            ],
          ));
          return;
        }

        final completePhone = registerNumberCtrl.text.trim();
        final fullPhoneNumber =
            completePhone.startsWith('+') ? completePhone : '+$completePhone';

        final sent = await TwilioService.sendOtp(fullPhoneNumber, otp);
        if (sent) {
          Get.dialog(AlertDialog(
            title: const Text('OTP Sent'),
            content: Text('OTP sent to $fullPhoneNumber'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ));
        } else {
          Get.dialog(AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to send OTP via Twilio'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ));
        }
      } else {
        if (registerEmailCtrl.text.isEmpty) {
          Get.dialog(AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter email'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              )
            ],
          ));
          return;
        }

        final email = registerEmailCtrl.text.trim();
        final sent =
            await EmailService.sendOtp(email, otp); // You implement this
        if (sent) {
          Get.dialog(AlertDialog(
            title: const Text('OTP Sent'),
            content: Text('OTP sent to $email'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ));
        } else {
          Get.dialog(AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to send OTP via Email'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ));
        }
      }
    } catch (e) {
      Get.dialog(AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to send OTP: $e'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ));
    } finally {
      update();
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
    }
  }

  Future<void> addUser(BuildContext context) async {
    try {
<<<<<<< HEAD
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
=======
      // Check if passwords match
      if (registerPasswordCtrl.text != registerConfirmPasswordCtrl.text) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: Text('Passwords do not match'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
        return;
      }

      // Check OTP
      if (otpSend != otpEnter) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: Text('OTP is incorrect'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
        return;
      }

      // Validate based on verification method
      if (verificationMethod == 'email' &&
          registerEmailCtrl.text.trim().isEmpty) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: Text('Email cannot be empty'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
        return;
      }

      if (verificationMethod == 'phone' &&
          registerNumberCtrl.text.trim().isEmpty) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: Text('Phone number cannot be empty'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
        return;
      }

      // Hash password for storing in Firestore
      String encryptedPassword =
          PasswordUtils.hashPassword(registerPasswordCtrl.text);

      // Prepare Firestore user document
      DocumentReference doc = userCollection.doc();

      String email =
          verificationMethod == 'email' ? registerEmailCtrl.text.trim() : '';
      String phoneText = registerNumberCtrl.text.trim();
      int? phone = int.tryParse(phoneText);
      if (phone == null || phoneText.length < 7) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: Text('Invalid phone number format'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
        return;
      }

      AppUser.User user = AppUser.User(
        id: doc.id,
        name: registerNameCtrl.text.trim(),
        number: phone,
        password: encryptedPassword,
        email: email.isNotEmpty ? email : null,
      );

      // Register in FirebaseAuth if using email
      // if (verificationMethod == 'email') {
      //   try {
      //     await auth.createUserWithEmailAndPassword(
      //       email: email,
      //       password: registerPasswordCtrl.text.trim(),
      //     );
      //   } on FirebaseAuthException catch (e) {
      //     Get.snackbar('Firebase Error', e.message ?? 'Unknown error',
      //         colorText: Colors.red);
      //     return;
      //   }
      // }

      // Save user to Firestore
      await doc.set(user.toJson());

      Get.dialog(AlertDialog(
        title: const Text('Success'),
        content: Text('User added successfully'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ));

      _clearRegisterFields(); // Reset form fields
    } catch (err) {
      Get.dialog(AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to register user'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ));
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
    }
  }

  Future<void> loginWithPhoneOrEmail(BuildContext context) async {
    try {
<<<<<<< HEAD
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
=======
      String identifier = loginNumberCtrl.text.trim();
      String password = loginPasswordCtrl.text.trim();

      if (identifier.isEmpty || password.isEmpty) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: Text('Please enter both identifier and password'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
        return;
      }

      QuerySnapshot querySnapshot;

      if (identifier.contains('@')) {
        // Login by Email
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
        querySnapshot = await userCollection
            .where('email', isEqualTo: identifier)
            .limit(1)
            .get();
      } else {
<<<<<<< HEAD
        // Validate phone number format (must be 11 digits starting with 60)
        if (!RegExp(r'^60\d{9,11}$').hasMatch(identifier)) {
          Alert.show(context, 'Error',
              'Invalid phone number format. Example: 60123129895');
          return;
        }
        // Phone login - ensure valid phone number format
        final phone = int.tryParse(identifier);
        // Phone login
=======
        // Login by Phone
        int? phone = int.tryParse(identifier);
        if (phone == null) {
          Get.dialog(AlertDialog(
            title: const Text('Error'),
            content: Text('Invalid phone number format'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ));
          return;
        }
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
        querySnapshot = await userCollection
            .where('number', isEqualTo: phone)
            .limit(1)
            .get();
      }

<<<<<<< HEAD
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
=======
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        String storedHashedPassword = userData['password'];
        bool isPasswordValid =
            PasswordUtils.verifyPassword(password, storedHashedPassword);

        if (isPasswordValid) {
          box.write('loginUser', userData);
          loginUser = AppUser.User.fromJson(userData);

          loginNumberCtrl.clear();
          loginPasswordCtrl.clear();

          Get.offAll(() => const UserHomePage());
          Get.dialog(AlertDialog(
            title: const Text('Success'),
            content: Text('Login Successful'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ));
        } else {
          Get.dialog(AlertDialog(
            title: const Text('Error'),
            content: Text('Incorrect password'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ));
        }
      } else {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: Text('User not found, please register'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
      }
    } catch (error) {
      Get.dialog(AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to login: ${error.toString()}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ));
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
    }
  }

  Future<void> updateUserPassword(
<<<<<<< HEAD
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
=======
      BuildContext context, String password, String confirmPassword) async {
    try {
      if (loginUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No logged-in user found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (password.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Both fields are required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Password format validation
      final passwordRegex = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

      if (!passwordRegex.hasMatch(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password must be at least 8 characters and include:\n'
              '- Uppercase letter\n'
              '- Lowercase letter\n'
              '- Number\n'
              '- Special character',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String hashedPassword = PasswordUtils.hashPassword(password);

      await userCollection.doc(loginUser!.id).update({
        'password': hashedPassword,
      });

      loginUser!.password = hashedPassword;
      box.write('loginUser', loginUser!.toJson());

>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
<<<<<<< HEAD
      // Handle any unexpected errors
=======
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
<<<<<<< HEAD
    }
  }

  void clearRegisterFields() {
=======
    } finally {
      update();
    }
  }

  void _clearRegisterFields() {
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
    registerNameCtrl.clear();
    registerNumberCtrl.clear();
    registerPasswordCtrl.clear();
    registerConfirmPasswordCtrl.clear();
    registerEmailCtrl.clear();
    otpController.clear();
<<<<<<< HEAD
    otpFieldShown.value = false;
    showChangeLink.value = false;
  }
}
=======
    otpFieldShown = false;
  }
} 


  




  

//   Future<void> sendPasswordResetLink(String email) async {
//   try {
//     if (email.isEmpty) {
//       Get.snackbar('Error', 'Please enter your email', colorText: Colors.red);
//       return;
//     }

//     await auth.sendPasswordResetEmail(email: email);
//     Get.snackbar('Success', 'Password reset email sent.', colorText: Colors.green);
//   } catch (e) {
//     print("Error: $e");
//     Get.snackbar('Error', 'Failed to send password reset email', colorText: Colors.red);
//   }
// }

>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
