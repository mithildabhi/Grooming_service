// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:salon_booking/routes/app_routes.dart';
import 'package:salon_booking/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../routes/admin_routes.dart';  
import 'admin_controller.dart';
import '../services/django_api_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;  // ✅ ADD THIS LINE

  RxBool isLoggedIn = false.obs;
  RxString role = 'user'.obs;

  // ---------------- LOGIN ----------------
  Future<void> login(String email, String password) async {
    print("🟡 LOGIN STARTED");

    try {
      // 1. Firebase login
      await _authService.login(email, password);

      final user = FirebaseAuth.instance.currentUser;
      print("🟢 Firebase User: ${user?.email}");

      final token = await user?.getIdToken(true);
      print("🔥 Firebase Token: ${token?.substring(0, 50)}...");

      // 2. Test auth with Django
      await DjangoApiService.testAuth();
      await DjangoApiService.syncUser();

      // ✅ 3. CRITICAL: Fetch role from Django BEFORE redirecting
      await _fetchRoleFromDjango();

      // 4. Now redirect based on the fetched role
      isLoggedIn.value = true;
      
      print("🎯 Redirecting based on role: ${role.value}");
      _redirectByRole();
      
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
      Get.snackbar('Login failed', e.toString());
    }
  }

  // ✅ NEW: Fetch role from Django
  Future<void> _fetchRoleFromDjango() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No Firebase user');
      }

      final token = await user.getIdToken();
      
      print('📤 Fetching role from: ${ApiConfig.baseUrl}/auth/me/');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 Django /auth/me/ response: ${response.statusCode}');
      print('📥 Django /auth/me/ body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final djangoRole = data['role']; // 'SALON_OWNER' or 'CUSTOMER'
        
        print('✅ Django role: $djangoRole');
        
        // ✅ Map Django role to Flutter role
        if (djangoRole == 'SALON_OWNER' || djangoRole == 'SUPER_ADMIN') {
          role.value = 'admin';
        } else {
          role.value = 'user';
        }
        
        // Save to SharedPreferences
        await saveRole(role.value);
        
        print('✅ Mapped to Flutter role: ${role.value}');
      } else {
        print('⚠️ Failed to fetch role, defaulting to user');
        role.value = 'user';
      }
    } catch (e) {
      print('❌ Error fetching role from Django: $e');
      // Default to user if error
      // role.value = 'user';
    }
  }

// ---------------- REGISTER ----------------
Future<void> register(String email, String password, String role) async {
  try {
    print('🔐 Registering user: $email, Role: $role');
    
    // 1. Create Firebase user
    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('⚠️ Firebase user already exists, signing in...');
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        rethrow;
      }
    }

    print('✅ Firebase user ready: ${credential.user?.uid}');

    // 2. Get Firebase ID token
    final token = await credential.user?.getIdToken();
    
    // 3. Sync to Django backend with role
    if (token != null) {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
          'firebase_uid': credential.user?.uid,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Django response status: ${response.statusCode}');
      print('📥 Django response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Django user ready with role: ${data['role']}');
        
        // ✅ CRITICAL: Fetch role from Django BEFORE redirecting
        await _fetchRoleFromDjango();
        
        // ✅ Set login state
        isLoggedIn.value = true;
        
        print('🎯 Registration complete, redirecting as: ${this.role.value}');
        
        // ✅ Show success message
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        
        // ✅ Redirect based on role
        _redirectByRole();
        
      } else {
        throw Exception('Django registration failed: ${response.body}');
      }
    }

  } catch (e) {
    print('❌ Registration error: $e');
    Get.snackbar(
      'Registration Failed',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    rethrow;
  }
}

  // ✅ ADD THIS METHOD
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
      Get.snackbar('Success', 'Password reset email sent');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ---------------- LOGOUT ----------------
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('forceLogin', true);
  await prefs.remove('role');

  await FirebaseAuth.instance.signOut();

  Get.offAll(() => LoginScreen());
}

  // ---------------- REDIRECT ----------------
  void _redirectByRole() {
    print('🚀 _redirectByRole called with role: ${role.value}');
    
    if (role.value == 'admin') {
      print('➡️ Redirecting to Admin Dashboard');
      
      // ✅ Initialize if not already registered
      if (!Get.isRegistered<AdminController>()) {
        Get.put(AdminController());
      }
      
      // Now safe to access
      Get.find<AdminController>().activeSalonId.value = '1';
      Get.offAllNamed(AdminRoutes.adminDashboard);
    } else {
      print('➡️ Redirecting to User Home');
      Get.offAllNamed(AppRoutes.userHome);
    }
  }

  @override
  void onInit() {
    super.onInit();
    restoreSession();
    
    if (isLoggedIn.value) {
      // 🔥 User already logged in → verify backend
      _initializeUserSession();
    }
  }

  Future<void> _initializeUserSession() async {
    try {
      await DjangoApiService.testAuth();
      await DjangoApiService.syncUser();
      
      // ✅ Fetch role from Django to ensure it's correct
      await _fetchRoleFromDjango();
      
      print('✅ Session initialized with role: ${role.value}');
    } catch (e) {
      print('❌ Session initialization error: $e');
    }
  }

  void restoreSession() {
    if (_authService.isUserLoggedIn()) {
      isLoggedIn.value = true;
      // Don't set role here - let _fetchRoleFromDjango() do it
      print('📂 Session restored, will fetch role from Django');
    } else {
      isLoggedIn.value = false;
      role.value = 'user';
    }
  }
}