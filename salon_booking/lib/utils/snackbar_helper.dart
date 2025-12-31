import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  static void error(String message) {
    if (Get.context == null) return;

    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  static void success(String message) {
    if (Get.context == null) return;

    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
