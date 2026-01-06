// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:salon_booking/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'admin_controller.dart';
import '../services/django_api_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoggedIn = false.obs;
  RxString role = 'user'.obs;

  get user => null;

  // ✅ REMOVED onInit() - NO AUTO-INITIALIZATION!

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
      
      print("🎯 Login complete, redirecting as: ${role.value}");
      _redirectByRole();
      
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
      Get.snackbar('Login failed', e.toString());
      rethrow;
    }
  }
  
  // ---------------- FETCH ROLE FROM DJANGO ----------------
  Future<void> _fetchRoleFromDjango() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No Firebase user');

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
  Future<void> register(String email, String password, String role) async {
    try {
      print('📝 Registering user: $email, Role: $role');
      
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

        print('📥 Django response: ${response.statusCode}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          await _fetchRoleFromDjango();
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('forceLogin', false);
          
          isLoggedIn.value = true;
          
          print('🎯 Registration complete, redirecting as: ${this.role.value}');
          
          Get.snackbar(
            'Success',
            'Account created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          
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
    try {
      print('👋 AUTH: Starting logout...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // ✅ Set force login flag FIRST
      await prefs.setBool('forceLogin', true);
      await prefs.remove('role');
      await prefs.remove('user_role');
      
      print('✅ AUTH: Cleared SharedPrefs');
      
      // ✅ Sign out from Firebase
      await _auth.signOut();
      await _authService.logout();
      
      print('✅ AUTH: Signed out from Firebase');
      
      // ✅ Update state
      isLoggedIn.value = false;
      role.value = 'user';
      
      print('👋 AUTH: User logged out, navigating to login...');
      
      // ✅ Navigate to login (close all previous screens)
      Get.offAllNamed(AppRoutes.login);
      
    } catch (e) {
      print('❌ AUTH: Logout error: $e');
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
      
      print('✅ AUTH: Session initialized with role: ${role.value}');
    } catch (e) {
      print('❌ AUTH: Session init error: $e');
      throw e;
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
      Get.offAllNamed('/admin'); // or AdminRoutes.adminDashboard
    } else {
      print('➡️ AUTH: Going to User Home');
      Get.offAllNamed(AppRoutes.userHome);
    }
  }
}