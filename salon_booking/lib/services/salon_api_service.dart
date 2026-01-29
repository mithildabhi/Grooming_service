// lib/services/salon_api_service.dart
// ✅ FIXED: Comprehensive salon API service with proper state/pincode handling

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/salon_profile.dart';

class SalonApiService {
  /// Get current user's salon profile
  static Future<SalonProfile?> getMyProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ SALON_API: No authenticated user');
        throw Exception('Not authenticated');
      }

      final token = await user.getIdToken();

      print('📥 SALON_API: Fetching profile from /salons/my-salon/');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/salons/my-salon/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 SALON_API: GET response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ DEBUG: Verify data contains state/pincode
        print('📦 SALON_API: Response data:');
        print('   City: ${data['city']}');
        print('   State: ${data['state']}');
        print('   Pincode: ${data['pincode']}');
        
        final profile = SalonProfile.fromJson(data);
        print('✅ SALON_API: Profile loaded successfully');
        
        return profile;
      } else if (response.statusCode == 404) {
        print('ℹ️ SALON_API: No salon profile found (404)');
        return null;
      } else {
        print('❌ SALON_API: Failed to load profile: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SALON_API: Error in getMyProfile: $e');
      rethrow;
    }
  }

  /// Save (create or update) salon profile
  static Future<SalonProfile> saveProfile(SalonProfile profile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ SALON_API: No authenticated user');
        throw Exception('Not authenticated');
      }

      final token = await user.getIdToken();
      
      // ✅ CRITICAL: Convert profile to JSON
      final requestBody = profile.toJson();
      
      // ✅ DEBUG: Print EXACTLY what we're sending
      print('\n' + '='*60);
      print('🔥 SALON_API: SAVING PROFILE');
      print('='*60);
      print('📤 Endpoint: ${ApiConfig.baseUrl}/salons/create/');
      print('📦 Request Body:');
      print(const JsonEncoder.withIndent('  ').convert(requestBody));
      print('\n🔍 Location Fields:');
      print('   address: "${requestBody['address']}"');
      print('   city: "${requestBody['city']}"');
      print('   state: "${requestBody['state']}"');      // ✅ CRITICAL
      print('   pincode: "${requestBody['pincode']}"');  // ✅ CRITICAL
      print('='*60);

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/salons/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('\n📊 SALON_API: Response Status: ${response.statusCode}');
      print('📦 Response Body:');
      print(const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body)));
      print('='*60 + '\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // ✅ Verify saved data includes state/pincode
        print('✅ SALON_API: Profile saved successfully!');
        print('🔍 Saved data verification:');
        print('   City: ${data['city']}');
        print('   State: ${data['state']}');
        print('   Pincode: ${data['pincode']}');
        
        return SalonProfile.fromJson(data);
      } else {
        print('❌ SALON_API: Save failed with status ${response.statusCode}');
        print('   Error response: ${response.body}');
        
        // Try to extract meaningful error message
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            final errorMessage = errorData.toString();
            throw Exception('Save failed: $errorMessage');
          }
        } catch (_) {
          // If can't parse error, use raw body
          throw Exception('Save failed: ${response.body}');
        }
        
        throw Exception('Failed to save profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SALON_API: Error in saveProfile: $e');
      rethrow;
    }
  }

  /// Delete salon profile
  static Future<void> deleteProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await user.getIdToken();

      print('🗑️ SALON_API: Deleting profile');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/salons/delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 SALON_API: DELETE response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ SALON_API: Profile deleted successfully');
      } else {
        print('❌ SALON_API: Delete failed: ${response.statusCode}');
        throw Exception('Failed to delete profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SALON_API: Error in deleteProfile: $e');
      rethrow;
    }
  }

  /// Get all salons (public endpoint)
  static Future<List<SalonProfile>> getAllSalons({
    String? city,
    String? state,
    String? search,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (state != null && state.isNotEmpty) queryParams['state'] = state;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('${ApiConfig.baseUrl}/salons/').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('📥 SALON_API: Fetching all salons from $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('📊 SALON_API: GET all salons response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final salons = data.map((json) => SalonProfile.fromJson(json)).toList();
        
        print('✅ SALON_API: Loaded ${salons.length} salons');
        return salons;
      } else {
        print('❌ SALON_API: Failed to load salons: ${response.statusCode}');
        throw Exception('Failed to load salons: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SALON_API: Error in getAllSalons: $e');
      rethrow;
    }
  }

  /// Get salon by ID
  static Future<SalonProfile?> getSalonById(String salonId) async {
    try {
      print('📥 SALON_API: Fetching salon ID: $salonId');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/salons/$salonId/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('📊 SALON_API: GET salon response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SalonProfile.fromJson(data);
      } else if (response.statusCode == 404) {
        print('ℹ️ SALON_API: Salon not found');
        return null;
      } else {
        throw Exception('Failed to load salon: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SALON_API: Error in getSalonById: $e');
      rethrow;
    }
  }
}