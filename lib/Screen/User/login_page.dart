import 'package:ecommerce/Screen/User/register_page.dart';
import 'package:ecommerce/Screen/admin/admin_page.dart';
import 'package:ecommerce/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (ctrl) {
      return Scaffold(
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl.loginNumberCtrl,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone_android),
                    labelText: 'Mobile Number',
                    hintText: 'Enter your phone number'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: ctrl.loginPasswordCtrl,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.password),
                    labelText: 'Password',
                    hintText: 'Enter you password'),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgotPassword (),));
                      },
                      child: const Text("Fotgot Password"))),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  ctrl.loginWithPhoneOrEmail(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Get.to(const RegisterPage());
                },
                child: const Text('Register new account'),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                  alignment: Alignment.center,
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ));
                      },
                      child: const Text("Admin"))),
            ],
          ),
        ),
      );
    });
  }
}
