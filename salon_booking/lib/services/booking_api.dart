// lib/services/booking_api.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class BookingApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Get all bookings for salon owner
  static Future<List<dynamic>> getBookings({String? date, String? status}) async {
    try {
      final headers = await _getHeaders();
      
      String url = '$baseUrl/bookings/';
      List<String> queryParams = [];
      
      if (date != null) queryParams.add('date=$date');
      if (status != null) queryParams.add('status=$status');
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      print('📥 Fetching bookings from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📊 Bookings response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> bookings = jsonDecode(response.body);
        print('✅ Found ${bookings.length} bookings');
        return bookings;
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Booking fetch error: $e');
      rethrow;
    }
  }

  /// Get booking statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/statistics/'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      print('❌ Statistics error: $e');
      return {};
    }
  }

  /// Get available time slots for booking
  static Future<Map<String, dynamic>> getAvailableSlots({
    required String date,
    required int serviceId,
    int? staffId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      String url = '$baseUrl/bookings/available-slots/?date=$date&service_id=$serviceId';
      if (staffId != null) url += '&staff_id=$staffId';
      
      print('🕐 Fetching slots: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load slots');
      }
    } catch (e) {
      print('❌ Slots error: $e');
      rethrow;
    }
  }

  /// Create new booking
  static Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    required String bookingDate,
    required String bookingTime,
    int? staffId,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final body = {
        'service': serviceId,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
        if (staffId != null) 'staff': staffId,
        if (customerName != null) 'customer_name': customerName,
        if (customerPhone != null) 'customer_phone': customerPhone,
        if (notes != null) 'notes': notes,
      };
      
      print('📝 Creating booking: $body');
      
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/create/'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📥 Create response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('✅ Booking created successfully');
        return result;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create booking');
      }
    } catch (e) {
      print('❌ Create booking error: $e');
      rethrow;
    }
  }

  /// Update booking status
  static Future<void> updateBookingStatus(int bookingId, String status) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/status/'),
        headers: headers,
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      print('❌ Update status error: $e');
      rethrow;
    }
  }
}