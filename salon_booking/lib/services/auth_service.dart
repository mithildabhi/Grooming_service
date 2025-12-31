// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Register with role sync to Django
  Future<void> register(String email, String password, String role) async {
    try {
      print('📝 Registering user: $email, Role: $role');
      
      // 1. Create Firebase user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase user created: ${credential.user?.uid}');

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
            'role': role,  // 'user' or 'admin'
            'firebase_uid': credential.user?.uid,
          }),
        ).timeout(const Duration(seconds: 30));

        print('📥 Django response status: ${response.statusCode}');
        print('📥 Django response body: ${response.body}');

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          print('✅ Django user created with role: ${data['role']}');
          
          // Save role locally
          await saveRole(role);
        } else {
          throw Exception('Django registration failed: ${response.body}');
        }
      }

    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  // ✅ Login and fetch role from Django
  Future<void> login(String email, String password) async {
    try {
      print('🔐 Logging in: $email');
      
      // 1. Firebase login
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase login successful');

      // 2. Get Firebase token
      final token = await credential.user?.getIdToken();
      
      // 3. Fetch user role from Django
      if (token != null) {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/auth/me/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));

        print('📥 Django profile response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final djangoRole = data['role'];
          
          print('✅ User role from Django: $djangoRole');
          
          // Map Django role to Flutter role
          final flutterRole = djangoRole == 'SALON_OWNER' ? 'admin' : 'user';
          await saveRole(flutterRole);
          
          print('✅ Saved Flutter role: $flutterRole');
        }
      }

    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  // Save role to SharedPreferences
  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    print('💾 Saved role: $role');
  }

  // Get saved role
  String getRole() {
    // This is synchronous - you'll need to load it async first
    return 'user'; // Temporary - see restoreRole() below
  }

  // Restore role from storage
  Future<String> restoreRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    print('📂 Restored role: $role');
    return role;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    print('👋 Logged out');
  }
}