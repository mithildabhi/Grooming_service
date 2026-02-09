import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_snackbar.dart';

class SnackbarHelper {
  static void error(String message) {
    CustomSnackbar.show(
      title: 'Error',
      message: message,
      isError: true,
    );
  }

  static void success(String message) {
    CustomSnackbar.show(
      title: 'Success',
      message: message,
      isSuccess: true,
    );
  }

  static void info(String title, String message) {
    CustomSnackbar.show(
      title: title,
      message: message,
    );
  }
}
