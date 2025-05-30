import 'package:ecommerce/Screen/User/userhome_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController otpCtrl = TextEditingController();
  bool isVerifying = false;

  Future<void> verifyOtp() async {
    final String otp = otpCtrl.text.trim();

    if (otp.length != 6) {
      Get.snackbar('Error', 'Please enter a 6-digit OTP',
          colorText: Colors.red);
      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Optionally: Check if user exists in Firestore, if needed
      // You can also write user info to local storage here

      Get.offAll(() => const UserHomePage()); // Navigate to home page
      Get.snackbar('Success', 'Phone login successful',
          colorText: Colors.green);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Verification failed',
          colorText: Colors.red);
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  @override
  void dispose() {
    otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Enter the 6-digit OTP sent to +91${widget.phone}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isVerifying ? null : verifyOtp,
              child: isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
