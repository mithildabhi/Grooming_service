import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import 'package:salon_booking/views/admin/dashboard_screen.dart';
import 'package:salon_booking/views/user/user_home_screen.dart';


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
    Future.delayed(const Duration(seconds: 2), _navigate);
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
Future<void> checkAuth() async {
  final prefs = await SharedPreferences.getInstance();

  final forceLogin = prefs.getBool('forceLogin') ?? true;
  final role = prefs.getString('role');

  // 🚫 ABSOLUTE BLOCK
  if (forceLogin || role == null) {
    Get.offAll(() => LoginScreen());
    return;
  }

  // ✅ Only allowed after manual login
  if (role == 'admin') {
    Get.offAll(() => DashboardScreen());
  } else {
    Get.offAll(() => UserHomeScreen());
  }
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
