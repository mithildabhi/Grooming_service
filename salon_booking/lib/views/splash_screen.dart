// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../routes/admin_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_hasNavigated) return;

    print('🟢 SPLASH: Starting...');

    // Wait 2 seconds for animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted || _hasNavigated) return;

    await _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (_hasNavigated || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final forceLogin = prefs.getBool('forceLogin') ?? true;

      print('🔍 SPLASH: Firebase User: ${firebaseUser?.email}');
      print('🔍 SPLASH: Force Login: $forceLogin');

      // ❌ No user OR forced logout → Go to login
      if (firebaseUser == null || forceLogin) {
        print('➡️ SPLASH: Going to Login');
        _navigateTo(AppRoutes.login);
        return;
      }

      // ✅ User exists → Restore session
      print('✅ SPLASH: Restoring session...');

      final authController = Get.find<AuthController>();

      // Manually initialize session WITHOUT triggering onInit
      await authController.initializeUserSession();

      // Navigate based on role
      if (authController.role.value == 'admin') {
        print('➡️ SPLASH: Going to Admin Dashboard');
        _navigateTo(AdminRoutes.adminDashboard);
      } else {
        print('➡️ SPLASH: Going to User Home');
        _navigateTo(AppRoutes.userHome);
      }
    } catch (e) {
      print('❌ SPLASH: Error - $e');
      _navigateTo(AppRoutes.login);
    }
  }

  void _navigateTo(String route) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    print('🚀 SPLASH: Navigating to $route');

    // ✅ Direct navigation - more reliable than postFrameCallback
    Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.content_cut, size: 90, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "StyleX",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Beauty & Wellness, Simplified",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
