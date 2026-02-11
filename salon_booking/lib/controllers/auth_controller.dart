// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:salon_booking/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'admin_controller.dart';
import 'booking_controller.dart';
import '../services/django_api_service.dart';
import 'user_controller.dart';
import '../widgets/custom_snackbar.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoggedIn = false.obs;
  RxString role = 'user'.obs;

  User? get user => FirebaseAuth.instance.currentUser;

  // ---------------- LOGIN ----------------
  Future<void> login(String email, String password) async {
    print("🟡 LOGIN STARTED");

    try {
      await _authService.login(email, password);
      final user = _auth.currentUser;
      print("🟢 Firebase User: ${user?.email}");

      await DjangoApiService.testAuth();
      await DjangoApiService.syncUser();
      await _fetchRoleFromDjango();

      // Clear force login flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('forceLogin', false);

      isLoggedIn.value = true;

      // Load user data into UserController after successful login
      await _loadUserControllerData();

      print("🎯 Login complete, redirecting as: ${role.value}");
      _redirectByRole();
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
      print("❌ LOGIN ERROR: $e");
      CustomSnackbar.show(
        title: 'Login failed',
        message: e.toString(),
        isError: true,
      );
      rethrow;
    }
  }

  // ---------------- FETCH ROLE FROM DJANGO ----------------
  Future<void> _fetchRoleFromDjango() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No Firebase user');

      final token = await user.getIdToken(true); // force refresh
      await Future.delayed(const Duration(milliseconds: 800));

      print('📤 Fetching role from: ${ApiConfig.baseUrl}/auth/me/');

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/auth/me/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Django /auth/me/ response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final djangoRole = data['role'];

        print('✅ Django role: $djangoRole');

        if (djangoRole == 'SALON_OWNER' || djangoRole == 'SUPER_ADMIN') {
          role.value = 'admin';
        } else {
          role.value = 'user';
        }

        await saveRole(role.value);
        print('✅ Mapped to Flutter role: ${role.value}');
      } else {
        print('⚠️ Failed to fetch role, defaulting to user');
        role.value = 'user';
        await saveRole('user');
      }
    } catch (e) {
      print('❌ Error fetching role: $e');
      role.value = 'user';
      await saveRole('user');
    }
  }

  // ---------------- REGISTER ----------------
  Future<void> register(
    String email,
    String password,
    String role, {
    String? name,
    String? phone,
    String? gender, // ✅ ADD GENDER PARAMETER
  }) async {
    try {
      print('📝 Registering user: $email, Role: $role');
      print('📝 Name: $name, Phone: $phone, Gender: $gender');

      UserCredential credential;
      try {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('⚠️ Firebase user exists, signing in...');
          credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      print('✅ Firebase user ready: ${credential.user?.uid}');

      final token = await credential.user?.getIdToken();

      if (token != null) {
        // ✅ BUILD REQUEST BODY WITH NAME, PHONE AND GENDER
        final requestBody = {
          'email': email,
          'password': password,
          'role': role,
          'firebase_uid': credential.user?.uid,
        };

        // ✅ ADD NAME, PHONE AND GENDER IF PROVIDED
        if (name != null && name.trim().isNotEmpty) {
          requestBody['full_name'] = name.trim();
        }
        if (phone != null && phone.trim().isNotEmpty) {
          requestBody['phone'] = phone.trim();
        }
        if (gender != null && gender.trim().isNotEmpty) {
          requestBody['gender'] = gender.trim();
        }

        print('📤 Sending to Django: $requestBody');

        final response = await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/auth/register/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 30));

        print('📥 Django response: ${response.statusCode}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          await _fetchRoleFromDjango();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('forceLogin', false);

          isLoggedIn.value = true;

          // ✅ IMMEDIATELY LOAD USER DATA after registration
          // This ensures the profile data is available right away
          await _loadUserControllerData();

          // ✅ FORCE REFRESH to sync the registered data
          if (Get.isRegistered<UserController>()) {
            final userController = Get.find<UserController>();
            await userController.refreshUserData();
            print('✅ User profile data synced after registration');
          }

          print('🎯 Registration complete, redirecting as: ${this.role.value}');

          Get.offAllNamed(AppRoutes.userHome);

          CustomSnackbar.show(
            title: 'Success',
            message: 'Account created successfully!',
            isSuccess: true,
          );

          _redirectByRole();
        } else {
          throw Exception('Django registration failed: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Registration error: $e');
      CustomSnackbar.show(
        title: 'Registration Failed',
        message: e.toString(),
        isError: true,
      );
      rethrow;
    }
  }

  // ✅ SAVE ROLE METHOD (RESTORED)
  Future<void> saveRole(String userRole) async {
    try {
      await _authService.saveRole(userRole);
      role.value = userRole;
      print('💾 Role saved: $userRole');
    } catch (e) {
      print('❌ Error saving role: $e');
    }
  }

  // ---------------- RESET PASSWORD ----------------
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      CustomSnackbar.show(
        title: 'Success',
        message: 'Password reset email sent',
        isSuccess: true,
      );
    } catch (e) {
      CustomSnackbar.show(title: 'Error', message: e.toString(), isError: true);
    }
  }

  // ---------------- LOGOUT ----------------
  // Centralized logout - handles ALL cleanup for both user and admin roles
  Future<void> logout() async {
    try {
      print('👋 AUTH: Starting centralized logout...');

      // ✅ Clear UserController data
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        userController.clearUserData();
        print('✅ AUTH: Cleared UserController data');
      }

      // ✅ Clear AdminController data
      if (Get.isRegistered<AdminController>()) {
        final adminController = Get.find<AdminController>();
        adminController.clearAdminData();
        print('✅ AUTH: Cleared AdminController data');
      }

      // ✅ Clear BookingController data
      if (Get.isRegistered<BookingController>()) {
        final bookingController = Get.find<BookingController>();
        bookingController.userBookings.clear();
        bookingController.bookings.clear();
        print('✅ AUTH: Cleared BookingController data');
      }

      // ✅ Use centralized AuthService logout (handles SharedPrefs + Firebase signout)
      await _authService.logout();

      print('✅ AUTH: AuthService logout complete');

      // ✅ Update in-memory state
      isLoggedIn.value = false;
      role.value = 'user';

      print('👋 AUTH: User logged out, navigating to login...');

      // ✅ Navigate to login (close all previous screens)
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('❌ AUTH: Logout error: $e');

      // ✅ Ensure state is cleared even on error
      isLoggedIn.value = false;
      role.value = 'user';

      // ✅ Force navigation even on error
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ---------------- SESSION INITIALIZATION ----------------
  // ✅ ONLY called manually from SplashScreen
  Future<void> initializeUserSession() async {
    try {
      print('🔄 AUTH: Initializing session...');

      await DjangoApiService.testAuth().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Backend timeout'),
      );

      await DjangoApiService.syncUser();
      await _fetchRoleFromDjango();

      isLoggedIn.value = true;

      // Load user data into UserController after session restore
      await _loadUserControllerData();

      print('✅ AUTH: Session initialized with role: ${role.value}');
    } catch (e) {
      print('❌ AUTH: Session init error: $e');
      rethrow;
    }
  }

  // ---------------- LOAD USER CONTROLLER DATA ----------------
  Future<void> _loadUserControllerData() async {
    try {
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        await userController.loadUserData();
        await userController.loadUserStatistics();
        print('✅ AUTH: UserController data loaded');
      }
    } catch (e) {
      print('⚠️ AUTH: Could not load UserController data: $e');
    }
  }

  // ---------------- REDIRECT ----------------
  void _redirectByRole() {
    print('🚀 AUTH: Redirecting with role: ${role.value}');

    if (role.value == 'admin') {
      print('➡️ AUTH: Going to Admin Dashboard');

      // ✅ AdminController already exists, just set salon ID
      final adminCtrl = Get.find<AdminController>();
      adminCtrl.activeSalonId.value = '1';

      // ✅ Use the correct route
      Get.offAllNamed('/admin');
    } else {
      print('➡️ AUTH: Going to User Home');
      Get.offAllNamed(AppRoutes.userHome);
    }
  }
}
