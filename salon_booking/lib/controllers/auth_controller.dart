import 'package:get/get.dart';
import '../app_routes.dart';
import '../services/auth_service.dart';
import 'admin_controller.dart';
import '../services/salon_api_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoggedIn = false.obs;
  final RxString role = 'user'.obs;

  // ---------------- LOGIN ----------------

Future<void> login(String email, String password) async {
  try {
    // 🔐 Step 1: Login
    await _authService.login(email, password);

    isLoggedIn.value = true;
    role.value = _authService.getRole();

    print('LOGIN SUCCESS → ROLE = ${role.value}');

    // 🟢 Step 2: ONLY FOR ADMIN
    if (role.value == 'admin') {
      final adminCtrl = Get.find<AdminController>();

      // get JWT token from auth service
      final token = (_authService as dynamic).token;

      // 🔽 Step 3: CALL BACKEND
      final salons = await SalonApiService.fetchSalons(token);

      if (salons.isNotEmpty) {
        adminCtrl.activeSalonId.value = salons[0]['id'].toString();
        print('ACTIVE SALON ID SET → ${adminCtrl.activeSalonId.value}');
      } else {
        throw Exception('No salon found for this admin');
      }
    }

    // 🚀 Step 4: Redirect
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

      // TEMP FIX (until API-based salon mapping)
      adminCtrl.activeSalonId.value = '1';

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