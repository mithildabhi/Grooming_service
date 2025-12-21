import 'package:get/get.dart';
import '../app_routes.dart';
import '../services/auth_service.dart';
import 'admin_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoggedIn = false.obs;
  final RxString role = 'user'.obs;

  // ---------------- LOGIN ----------------
Future<void> login(String email, String password) async {
  try {
    await _authService.login(email, password);

    isLoggedIn.value = true;
    role.value = _authService.getRole();

    print("LOGIN SUCCESS, ROLE = ${role.value}");

    _redirectByRole();
  } catch (e) {
    Get.snackbar('Login failed', e.toString());
  }
}

  // ---------------- REGISTER ----------------
  Future<void> register(String email, String password, String role) async {
    try {
      await _authService.register(email, password, role);

      isLoggedIn.value = true;
      this.role.value = role;

      _redirectByRole();
    } catch (e) {
      Get.snackbar('Register failed', e.toString());
    }
  }

  // ---------------- REDIRECT ----------------
  void _redirectByRole() {
    if (role.value == 'admin') {
      final adminCtrl = Get.find<AdminController>();

      // TEMP FIX (until API-based salon fetch)
      adminCtrl.setActiveSalon('1'); // 👈 YOUR SALON ID FROM BACKEND

      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.userHome);
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn.value = false;
    role.value = 'user';
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
    Get.snackbar('Success', 'Password reset requested');
  }
}