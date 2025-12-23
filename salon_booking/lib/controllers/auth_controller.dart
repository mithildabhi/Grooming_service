import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../app_routes.dart';
import 'admin_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  RxBool isLoggedIn = false.obs;
  RxString role = 'user'.obs;

  // ---------------- LOGIN ----------------
  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);

      isLoggedIn.value = true;
      role.value = _authService.getRole();

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

  // ---------------- RESET PASSWORD ----------------
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      Get.snackbar('Success', 'Password reset email sent');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn.value = false;
    role.value = 'user';
    Get.offAllNamed(AppRoutes.login);
  }

  // ---------------- REDIRECT ----------------
  void _redirectByRole() {
    if (role.value == 'admin') {
      Get.find<AdminController>().activeSalonId.value = '1';
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.userHome);
    }
  }
}
