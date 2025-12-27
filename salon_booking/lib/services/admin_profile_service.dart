import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class AdminProfileService {
static String get baseUrl => ApiConfig.baseUrl;

  /// Get Firebase token and headers
  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    final token = await user.getIdToken();
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Get my salon profile
  static Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final headers = await _getHeaders();
      
      print('📤 GET: $baseUrl/salons/my-salon/');
      
      final response = await http.get(
        Uri.parse('$baseUrl/salons/my-salon/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('📥 Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('ℹ️ No salon found yet');
        return null;
      } else {
        throw Exception('Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting profile: $e');
      rethrow;
    }
  }

  /// Save admin profile (create or update salon)
  /// This endpoint handles BOTH create and update automatically
  static Future<Map<String, dynamic>> saveProfile({
    required String salonName,
    required String phone,
    required String location,
    String? about,
    String? imageUrl,
    String salonType = 'unisex',
    Map<String, dynamic>? hours,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Prepare data matching Django model
      // DO NOT send 'owner' field - it's set automatically by backend
      // DO NOT send 'email' field - Salon model doesn't have it
      final body = jsonEncode({
        'name': salonName,
        'salon_type': salonType,
        'address': location,
        'phone': phone,
        'about': about ?? '',
        'image_url': imageUrl ?? '',
        'hours': hours ?? {
          'Mon': '09:00-19:00',
          'Tue': '09:00-19:00',
          'Wed': '09:00-19:00',
          'Thu': '09:00-19:00',
          'Fri': '09:00-19:00',
          'Sat': '09:00-19:00',
          'Sun': 'Closed',
        },
      });

      print('📤 POST: $baseUrl/salons/create/');
      print('📦 Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/salons/create/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('📥 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Salon saved successfully!');
        return data;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Server error: $error');
        throw Exception('Save failed: $error');
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      rethrow;
    }
  }

  /// Update existing profile (alternative method if you prefer separate update)
  static Future<Map<String, dynamic>> updateProfile({
    required String salonName,
    required String phone,
    required String location,
    String? about,
    String? imageUrl,
    String? salonType,
    Map<String, dynamic>? hours,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final bodyMap = <String, dynamic>{
        'name': salonName,
        'address': location,
        'phone': phone,
      };

      // Add optional fields only if provided
      if (about != null) bodyMap['about'] = about;
      if (imageUrl != null && imageUrl.isNotEmpty) bodyMap['image_url'] = imageUrl;
      if (salonType != null) bodyMap['salon_type'] = salonType;
      if (hours != null) bodyMap['hours'] = hours;

      final body = jsonEncode(bodyMap);

      print('📤 PUT: $baseUrl/salons/update/');
      print('📦 Body: $body');

      final response = await http.put(
        Uri.parse('$baseUrl/salons/update/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('📥 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Profile updated successfully!');
        return data;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Update error: $error');
        throw Exception('Update failed: $error');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  /// Delete/deactivate salon
  static Future<void> deleteSalon() async {
    try {
      final headers = await _getHeaders();
      
      print('📤 DELETE: $baseUrl/salons/delete/');

      final response = await http.delete(
        Uri.parse('$baseUrl/salons/delete/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Salon deactivated');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting salon: $e');
      rethrow;
    }
  }
}