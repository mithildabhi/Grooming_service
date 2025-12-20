// lib/views/user/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../app_routes.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
        actions: [
          IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Welcome, user!'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.userBooking),
              child: const Text('Make a Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
