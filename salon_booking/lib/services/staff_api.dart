// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/employee_model.dart';
import '../config/api_config.dart';

class StaffApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<EmployeeModel>> fetchStaff() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/staff/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EmployeeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch staff: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<EmployeeModel> createStaff({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String primarySkill,
    required List<String> workingDays,
    required bool isActive,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // ✅ NORMALIZE VALUES TO MATCH BACKEND
      String normalizeRole(String role) {
        return role.toLowerCase(); // Stylist → stylist
      }
      
      String normalizeSkill(String skill) {
        return skill.toLowerCase().replaceAll(' ', '_'); // Hair Cutting → hair_cutting
      }
      
      final normalizedRole = normalizeRole(role);
      final normalizedSkill = normalizeSkill(primarySkill);
      
      final body = jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': normalizedRole,
        'primary_skill': normalizedSkill,
        'working_days': workingDays,
        'is_active': isActive,
      });

      print('📤 POST: $baseUrl/staff/create/');
      print('📦 Sending Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/staff/create/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('📥 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmployeeModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Create failed: $error');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<EmployeeModel> updateStaff({
    required int staffId,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String primarySkill,
    required List<String> workingDays,
    required bool isActive,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // ✅ NORMALIZE VALUES
      final normalizedRole = role.toLowerCase();
      final normalizedSkill = primarySkill.toLowerCase().replaceAll(' ', '_');
      
      final body = jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': normalizedRole,
        'primary_skill': normalizedSkill,
        'working_days': workingDays,
        'is_active': isActive,

      });

      final response = await http.patch(
        Uri.parse('$baseUrl/staff/$staffId/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmployeeModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Update failed: $error');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteStaff({required int staffId}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/staff/$staffId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception('Delete failed: $error');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<EmployeeModel> getStaff({required int staffId}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/staff/$staffId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmployeeModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch staff: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}