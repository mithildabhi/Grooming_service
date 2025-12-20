import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../app_routes.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), _navigate);
  }

  void _navigate() {
    if (!auth.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.login);
    } else if (auth.role.value == 'admin') {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.userHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to Salon Booking',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
