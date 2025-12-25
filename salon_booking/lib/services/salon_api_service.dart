// lib/services/salon_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/salon_profile.dart';

class SalonApiService {
<<<<<<< Updated upstream
  static const String baseUrl = 'http://192.168.29.87:8000/api';
  // static const String baseUrl = 'http://10.94.179.16:8000/api';
=======
  static const String baseUrl = 'http://10.97.98.16:8000/api';
  // static const String baseUrl = 'http://192.168.29.87:8000/api';
>>>>>>> Stashed changes

  /// Get auth headers with Firebase token
  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Get all salons (public)
  static Future<List<dynamic>> fetchSalons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/salons/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load salons: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching salons: $e');
      throw Exception('Error fetching salons: $e');
    }
  }

  /// Get my salon profile
  static Future<SalonProfile?> getMyProfile() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/salons/my-salon/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('🟢 Get Profile Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SalonProfile.fromMap(data, data['id'].toString());
      } else if (response.statusCode == 404) {
        // No salon found yet
        return null;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting profile: $e');
      throw Exception('Error getting profile: $e');
    }
  }

  /// Create or update salon profile
  static Future<SalonProfile> saveProfile(SalonProfile profile) async {
    try {
      final headers = await _getHeaders();
      
      // Convert Flutter model to Django format
      final body = jsonEncode({
        'name': profile.name,
        'salon_type': profile.type.toLowerCase(), // Male -> male
        'address': profile.address,
        'phone': profile.phone,
        'about': profile.about,
        'image_url': profile.imageUrl,
        'hours': profile.hours,
      });

      print('📤 Saving profile to: $baseUrl/salons/create/');
      print('📦 Request Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/salons/create/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('✅ Save Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SalonProfile.fromMap(data, data['id'].toString());
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to save: $error');
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      throw Exception('Error saving profile: $e');
    }
  }

  /// Update existing salon profile
  static Future<SalonProfile> updateProfile(SalonProfile profile) async {
    try {
      final headers = await _getHeaders();
      
      final body = jsonEncode({
        'name': profile.name,
        'salon_type': profile.type.toLowerCase(),
        'address': profile.address,
        'phone': profile.phone,
        'about': profile.about,
        'image_url': profile.imageUrl,
        'hours': profile.hours,
      });

      print('📤 Updating profile...');

      final response = await http.put(
        Uri.parse('$baseUrl/salons/update/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('✅ Update Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SalonProfile.fromMap(data, data['id'].toString());
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to update: $error');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  /// Delete/deactivate salon
  static Future<bool> deleteProfile() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/salons/delete/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete');
      }
    } catch (e) {
      print('❌ Error deleting profile: $e');
      return false;
    }
  }
}