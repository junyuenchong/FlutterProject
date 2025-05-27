import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Screen/User/userhome_page.dart';
import 'package:ecommerce/model/user/user.dart' as AppUser;
import 'package:ecommerce/services/email_service.dart';
import 'package:ecommerce/services/twilio_service.dart';
import 'package:ecommerce/widgets/CryptPassword.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final GetStorage box = GetStorage();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late CollectionReference userCollection;

  final TextEditingController registerNameCtrl = TextEditingController();
  final TextEditingController registerNumberCtrl = TextEditingController();
  final TextEditingController registerPasswordCtrl = TextEditingController();
  final TextEditingController registerConfirmPasswordCtrl =
      TextEditingController();
  final TextEditingController registerEmailCtrl = TextEditingController();
  final TextEditingController loginNumberCtrl = TextEditingController();
  final TextEditingController loginPasswordCtrl = TextEditingController();

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
      Get.to(() => const UserHomePage());
    }
    super.onReady();
  }

  @override
  void onInit() {
    userCollection = firestore.collection('users');
    super.onInit();
  }

  void setVerificationMethod(String method) {
    verificationMethod = method;
    update();
  }

  Future<void> sendOtp(BuildContext context) async {
    try {
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

      // Generate OTP
      final random = Random();
      int otp = 1000 + random.nextInt(9000);
      otpSend = otp;
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
    }
  }

  Future<void> addUser(BuildContext context) async {
    try {
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
    }
  }

  Future<void> loginWithPhoneOrEmail(BuildContext context) async {
    try {
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
        querySnapshot = await userCollection
            .where('email', isEqualTo: identifier)
            .limit(1)
            .get();
      } else {
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
        querySnapshot = await userCollection
            .where('number', isEqualTo: phone)
            .limit(1)
            .get();
      }

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
    }
  }

  Future<void> updateUserPassword(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      update();
    }
  }

  void _clearRegisterFields() {
    registerNameCtrl.clear();
    registerNumberCtrl.clear();
    registerPasswordCtrl.clear();
    registerConfirmPasswordCtrl.clear();
    registerEmailCtrl.clear();
    otpController.clear();
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

