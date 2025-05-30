import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/controller/login_controller.dart';
import 'package:ecommerce/widgets/CustomBottomNavBar.dart';

class UpdateProfilePage extends StatelessWidget {
  const UpdateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();
<<<<<<< HEAD

    // Create the controller once
    final TextEditingController nameController = TextEditingController();

    // Also create other controllers
=======
    final TextEditingController nameController =
        TextEditingController(text: controller.loginUser?.name ?? '');
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
<<<<<<< HEAD
            Obx(() {
              final name = controller.loginUser.value?.name ?? '';
              // Only update text if different to avoid cursor jump
              if (nameController.text != name) {
                nameController.text = name;
              }
              return TextField(
                controller: nameController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              );
            }),
=======
            TextField(
              controller: nameController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
            const SizedBox(height: 16),
            const Text(
              'New Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter new password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Re-enter new password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.updateUserPassword(
<<<<<<< HEAD
                    context,
                    passwordController,
                    confirmPasswordController,
=======
                     context, // pass context here
                    passwordController.text.trim(),
                    confirmPasswordController.text.trim(),
>>>>>>> 0bd57a3c251c25e241eaaed7d0a0aac49ca6e615
                  );
                },
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
