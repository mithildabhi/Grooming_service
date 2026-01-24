// lib/services/revenue_api.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class RevenueApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final token = await user.getIdToken();
    if (token == null) throw Exception('Failed to get authentication token');
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Get complete revenue overview
  static Future<Map<String, dynamic>> getRevenueOverview() async {
    try {
      final headers = await _getHeaders();
      
      print('💰 Fetching revenue overview...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/revenue/'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📊 Revenue response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Revenue data loaded');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load revenue: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Revenue overview error: $e');
      rethrow;
    }
  }

  /// Get daily revenue breakdown
  static Future<Map<String, dynamic>> getDailyRevenue({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      
      String url = '$baseUrl/bookings/revenue/daily/';
      List<String> params = [];
      
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load daily revenue');
      }
    } catch (e) {
      print('❌ Daily revenue error: $e');
      rethrow;
    }
  }

  /// Get weekly revenue breakdown
  static Future<Map<String, dynamic>> getWeeklyRevenue({int weeks = 12}) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/revenue/weekly/?weeks=$weeks'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load weekly revenue');
      }
    } catch (e) {
      print('❌ Weekly revenue error: $e');
      rethrow;
    }
  }

  /// Get monthly revenue breakdown
  static Future<Map<String, dynamic>> getMonthlyRevenue({int months = 12}) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/revenue/monthly/?months=$months'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load monthly revenue');
      }
    } catch (e) {
      print('❌ Monthly revenue error: $e');
      rethrow;
    }
  }

  /// Get service-wise revenue
  static Future<Map<String, dynamic>> getServiceRevenue() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/revenue/services/'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load service revenue');
      }
    } catch (e) {
      print('❌ Service revenue error: $e');
      rethrow;
    }
  }

  /// Get staff performance
  static Future<Map<String, dynamic>> getStaffPerformance() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/revenue/staff/'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load staff performance');
      }
    } catch (e) {
      print('❌ Staff performance error: $e');
      rethrow;
    }
  }

  /// Get revenue by category
  static Future<Map<String, dynamic>> getCategoryRevenue() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/revenue/categories/'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load category revenue');
      }
    } catch (e) {
      print('❌ Category revenue error: $e');
      rethrow;
    }
  }

  /// Get peak hours revenue
  static Future<Map<String, dynamic>> getPeakHours() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/revenue/peak-hours/'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load peak hours');
      }
    } catch (e) {
      print('❌ Peak hours error: $e');
      rethrow;
    }
  }
}