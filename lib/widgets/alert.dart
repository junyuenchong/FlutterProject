// lib/alert.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Alert {
  static void show(BuildContext context, String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // MUST HAVE THIS
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
