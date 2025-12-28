// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';
import '../config/api_config.dart';

class ServiceApi {
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

  /// Fetch all services for the salon owner
  static Future<List<ServiceModel>> fetchServices() async {
    try {
      final headers = await _getHeaders();

      print('📤 GET: $baseUrl/services/my-services/');

      final response = await http.get(
        Uri.parse('$baseUrl/services/my-services/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('📥 Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Fetched ${data.length} services');
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch services: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching services: $e');
      rethrow;
    }
  }

  /// Create a new service
  static Future<ServiceModel> createService({
    required String name,
    required String description,
    required double price,
    required int duration,
    required String category,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        'name': name,
        'description': description,
        'price': price.toString(),
        'duration': duration,
        'category': category.toLowerCase(),
        'is_active': true,
      });

      print('📤 POST: $baseUrl/services/create/');
      print('📦 Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/services/create/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('📥 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Service created successfully!');
        return ServiceModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ Server error: $error');
        throw Exception('Create failed: $error');
      }
    } catch (e) {
      print('❌ Error creating service: $e');
      rethrow;
    }
  }

  /// Update an existing service
  static Future<ServiceModel> updateService({
    required int serviceId,
    required String name,
    required String description,
    required double price,
    required int duration,
    required String category,
    required bool isActive,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        'name': name,
        'description': description,
        'price': price.toString(),
        'duration': duration,
        'category': category.toLowerCase(),
        'is_active': isActive,
      });

      print('📤 PATCH: $baseUrl/services/$serviceId/');
      print('📦 Body: $body');

      final response = await http.patch(
        Uri.parse('$baseUrl/services/$serviceId/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('📥 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Service updated successfully!');
        return ServiceModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ Update error: $error');
        throw Exception('Update failed: $error');
      }
    } catch (e) {
      print('❌ Error updating service: $e');
      rethrow;
    }
  }

  /// Delete/deactivate a service
  static Future<void> deleteService({
    required int serviceId,
  }) async {
    try {
      final headers = await _getHeaders();

      print('📤 DELETE: $baseUrl/services/$serviceId/');

      final response = await http.delete(
        Uri.parse('$baseUrl/services/$serviceId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('📥 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Service deactivated successfully');
      } else {
        final error = jsonDecode(response.body);
        print('❌ Delete error: $error');
        throw Exception('Delete failed: $error');
      }
    } catch (e) {
      print('❌ Error deleting service: $e');
      rethrow;
    }
  }

  /// Toggle service active status only (partial update)
  static Future<ServiceModel> toggleServiceStatus({
    required int serviceId,
    required bool isActive,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        'is_active': isActive,
      });

      print('📤 PATCH: $baseUrl/services/$serviceId/ (toggle status)');
      print('📦 Body: $body');

      final response = await http.patch(
        Uri.parse('$baseUrl/services/$serviceId/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      print('📥 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Service status toggled successfully!');
        return ServiceModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ Toggle error: $error');
        throw Exception('Toggle failed: $error');
      }
    } catch (e) {
      print('❌ Error toggling service status: $e');
      rethrow;
    }
  }

  /// Get a single service by ID
  static Future<ServiceModel> getService({
    required int serviceId,
  }) async {
    try {
      final headers = await _getHeaders();

      print('📤 GET: $baseUrl/services/$serviceId/');

      final response = await http.get(
        Uri.parse('$baseUrl/services/$serviceId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('📥 Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Fetched service successfully');
        return ServiceModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch service: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching service: $e');
      rethrow;
    }
  }

  /// Search/filter public services
  static Future<List<ServiceModel>> searchServices({
    int? salonId,
    String? category,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (salonId != null) queryParams['salon'] = salonId.toString();
      if (category != null) queryParams['category'] = category.toLowerCase();
      if (searchQuery != null) queryParams['search'] = searchQuery;

      final uri = Uri.parse('$baseUrl/services/').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      print('📤 GET: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('📥 Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Fetched ${data.length} services');
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search services: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error searching services: $e');
      rethrow;
    }
  }
}