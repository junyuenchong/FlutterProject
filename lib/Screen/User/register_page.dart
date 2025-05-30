import 'package:ecommerce/Screen/User/login_page.dart';
import 'package:ecommerce/controller/login_controller.dart';
import 'package:ecommerce/widgets/otp_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (ctrl) {
      return Scaffold(
        body: SafeArea(
          // Ensures the UI does not go under system bars
          child: SingleChildScrollView(
            // Allows scrolling if content overflows
            child: Padding(
              padding: const EdgeInsets.all(20),
<<<<<<< HEAD
              child: Obx(() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Create Your Account !!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 2, 1, 3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (ctrl.showChangeLink.value)
                            (ctrl.verificationMethod.value == 'phone')
                                ? GestureDetector(
                                    onTap: () {
                                      ctrl.otpFieldShown.value = false;
                                      ctrl.phoneReadOnly.value = false;
                                      ctrl.showChangeLink.value = false;
                                      ctrl.clearRegisterFields();
                                    },
                                    child: const Text(
                                      'Change Phone Number',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      ctrl.emailReadOnly.value = false;
                                      ctrl.otpFieldShown.value = false;
                                      ctrl.showChangeLink.value = false;
                                      ctrl.clearRegisterFields();
                                    },
                                    child: const Text(
                                      'Change email',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'email',
                            groupValue: ctrl.verificationMethod.value,
                            onChanged: (value) {
                              if (value != null) {
                                ctrl.setVerificationMethod(value);
                              }
                              ctrl.otpFieldShown.value = false;
                              ctrl.emailReadOnly.value = false;
                              ctrl.showChangeLink.value = false;
                              ctrl.clearRegisterFields();
                            },
                          ),
                          const Text("Email"),
                          Radio<String>(
                            value: 'phone',
                            groupValue: ctrl.verificationMethod.value,
                            onChanged: (value) {
                              if (value != null) {
                                ctrl.setVerificationMethod(value);
                              }
                              ctrl.otpFieldShown.value = false;
                              ctrl.phoneReadOnly.value = false;
                              ctrl.showChangeLink.value = false;
                              ctrl.clearRegisterFields();
                            },
                          ),
                          const Text("Phone"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.name,
                        controller: ctrl.registerNameCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Your Name',
                          hintText: 'Enter your Name',
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (ctrl.verificationMethod.value == 'phone')
                        IntlPhoneField(
                          controller: ctrl.registerNumberCtrl,
                          readOnly: ctrl.phoneReadOnly.value,
                          initialCountryCode: 'MY',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.phone_android),
                            labelText: 'Mobile Number',
                            hintText: 'Enter your phone number',
                          ),
                        )
                      else
                        TextField(
                          controller: ctrl.registerEmailCtrl,
                          readOnly: ctrl.emailReadOnly.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.email),
                            labelText: 'Email',
                            hintText: 'Enter your email',
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        controller: ctrl.registerPasswordCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          hintText: 'Enter your password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        controller: ctrl.registerConfirmPasswordCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      OtpTextField(
                        otpController: ctrl.otpController,
                        visible: ctrl.otpFieldShown.value,
                        onComplete: (otp) {
                          if (otp == null || otp.trim().isEmpty) {
                            ctrl.otpEnter = null;
                          } else {
                            ctrl.otpEnter = int.tryParse(otp.trim());
                          }
                        },
                      ),
                      if (ctrl.otpFieldShown.value)
                        TextButton(
                          onPressed: () => ctrl.sendOtp(context),
                          child: const Text(
                            'Resend Code',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (ctrl.otpFieldShown.value) {
                            ctrl.addUser(context);
                          } else {
                            ctrl.sendOtp(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: Text(
                            ctrl.otpFieldShown.value ? 'Register' : 'Send OTP'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(const LoginPage());
                        },
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 30),
                    ],
                  )),
=======
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30), // Added spacing at the top
                  const Text(
                    'Create Your Account !!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 2, 1, 3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'email',
                        groupValue: ctrl.verificationMethod,
                        onChanged: (value) {
                          if (value != null) ctrl.setVerificationMethod(value);
                        },
                      ),
                      const Text("Email"),
                      Radio<String>(
                        value: 'phone',
                        groupValue: ctrl.verificationMethod,
                        onChanged: (value) {
                          if (value != null) ctrl.setVerificationMethod(value);
                        },
                      ),
                      const Text("Phone"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.name,
                    controller: ctrl.registerNameCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'Your Name',
                      hintText: 'Enter your Name',
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (ctrl.verificationMethod == 'phone')
                    IntlPhoneField(
                      controller: ctrl.registerNumberCtrl,
                      initialCountryCode: 'MY',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.phone_android),
                        labelText: 'Mobile Number',
                        hintText: 'Enter your phone number',
                      ),
                    )
                  else
                    TextField(
                      controller: ctrl.registerEmailCtrl,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email),
                        labelText: 'Email',
                        hintText: 'Enter your email',
                      ),
                    ),

                  const SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    controller: ctrl.registerPasswordCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Password',
                      hintText: 'Enter your password',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    controller: ctrl.registerConfirmPasswordCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                    ),
                  ),
                  const SizedBox(height: 20),
                  OtpTextField(
                    otpController: ctrl.otpController,
                    visible: ctrl.otpFieldShown,
                    onComplete: (otp) {
                      ctrl.otpEnter = int.tryParse(otp ?? '0000');
                    },
                  ),
                  if (ctrl.otpFieldShown)
                    TextButton(
                      onPressed: () => ctrl.sendOtp(context),
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (ctrl.otpFieldShown) {
                        ctrl.addUser(context);
                      } else {
                        ctrl.sendOtp(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text(ctrl.otpFieldShown ? 'Register' : 'Send OTP'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(const LoginPage());
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 30), // Added spacing at the bottom
                ],
              ),
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
            ),
          ),
        ),
      );
    });
  }
}
