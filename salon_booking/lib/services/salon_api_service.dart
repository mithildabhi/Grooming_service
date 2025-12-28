// ignore_for_file: avoid_print


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/salon_profile.dart';
import '../config/api_config.dart';

class SalonApiService {
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
  static Future<SalonProfile?> getMyProfile() async {
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
        final data = jsonDecode(response.body);
        return SalonProfile.fromJson(data);
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

  /// Save salon profile (create or update)
  static Future<SalonProfile> saveProfile(SalonProfile profile) async {
    try {
      final headers = await _getHeaders();

      // Build request body
      // IMPORTANT: Don't send 'owner' or 'email' - backend handles these
      final body = jsonEncode({
        'name': profile.name,
        'salon_type': profile.salonType ?? 'unisex',
        'address': profile.address,
        'phone': profile.phone,
        'about': profile.about ?? '',
        'image_url': profile.imageUrl ?? '',
        'hours': profile.hours ?? {
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
        return SalonProfile.fromJson(data);
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

  /// Update existing profile
  static Future<SalonProfile> updateProfile(SalonProfile profile) async {
    try {
      final headers = await _getHeaders();

      final bodyMap = <String, dynamic>{
        'name': profile.name,
        'address': profile.address,
        'phone': profile.phone,
      };

      if (profile.about != null) bodyMap['about'] = profile.about;
      if (profile.imageUrl != null && profile.imageUrl!.isNotEmpty) {
        bodyMap['image_url'] = profile.imageUrl;
      }
      if (profile.salonType != null) bodyMap['salon_type'] = profile.salonType;
      if (profile.hours != null) bodyMap['hours'] = profile.hours;

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
        return SalonProfile.fromJson(data);
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