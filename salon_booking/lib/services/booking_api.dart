// lib/services/booking_api.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class BookingApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    print('🔵 _getHeaders: Starting...');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('🔵 _getHeaders: Current user: ${user?.uid ?? "null"}');
      
      if (user == null) {
        print('❌ _getHeaders: No user authenticated');
        throw Exception('User not authenticated');
      }
      
      print('🔵 _getHeaders: Getting ID token...');
      final token = await user.getIdToken();
      print('✅ _getHeaders: Token obtained (length: ${token?.length ?? 0})');
      
      if (token == null || token.isEmpty) {
        print('❌ _getHeaders: Token is null or empty');
        throw Exception('Failed to get authentication token');
      }
      
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      print('✅ _getHeaders: Headers created successfully');
      return headers;
    } catch (e, stackTrace) {
      print('❌ _getHeaders: Exception: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
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
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> bookings = jsonDecode(response.body);
        print('✅ Found ${bookings.length} bookings');
        return bookings;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['detail'] ?? 'Failed to load bookings: ${response.statusCode}');
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
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Booking created successfully');
        return result;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['detail'] ?? 'Invalid booking data');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['detail'] ?? 'Failed to create booking');
      }
    } catch (e) {
      print('❌ Create booking error: $e');
      rethrow;
    }
  }

  /// Update booking status - FIXED VERSION
  static Future<void> updateBookingStatus(dynamic bookingId, String status) async {
    print('🔵 API: updateBookingStatus called');
    print('   Input ID: $bookingId (${bookingId.runtimeType})');
    print('   Input Status: $status');
    
    try {
      print('🔵 API: Getting headers...');
      final headers = await _getHeaders();
      print('✅ API: Headers obtained');
      print('   Headers: $headers');
      
      // Convert bookingId to int if it's a string
      print('🔵 API: Converting ID to int...');
      final int id = bookingId is int ? bookingId : int.parse(bookingId.toString());
      print('✅ API: ID converted to $id');
      
      final url = '$baseUrl/bookings/$id/status/';
      final body = jsonEncode({'status': status});
      
      print('🔄 API: Updating booking status:');
      print('   Base URL: $baseUrl');
      print('   Full URL: $url');
      print('   Booking ID: $id (${id.runtimeType})');
      print('   Status: $status');
      print('   Body: $body');
      print('   Headers: $headers');
      
      print('🔵 API: Making HTTP PUT request...');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ API: Request timeout!');
          throw Exception('Request timeout - please check your connection');
        },
      );

      print('📥 API: Response received!');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');
      print('   Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ API: Status updated successfully to $status');
        return;
      } else if (response.statusCode == 401) {
        print('🔐 API: Unauthorized error');
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        print('🔍 API: Not found error');
        throw Exception('Booking not found (ID: $id)');
      } else if (response.statusCode == 400) {
        print('❌ API: Bad request');
        try {
          final error = jsonDecode(response.body);
          print('   Error details: $error');
          throw Exception(error['error'] ?? error['detail'] ?? error.toString());
        } catch (e) {
          print('   Could not parse error: $e');
          throw Exception('Invalid status value');
        }
      } else {
        print('❌ API: Unknown error status ${response.statusCode}');
        try {
          final error = jsonDecode(response.body);
          print('   Error details: $error');
          throw Exception(error['error'] ?? error['detail'] ?? error.toString());
        } catch (e) {
          print('   Could not parse error: $e');
          throw Exception('Failed to update status (${response.statusCode})');
        }
      }
    } catch (e, stackTrace) {
      print('❌ API: Exception caught in updateBookingStatus');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete booking
  static Future<void> deleteBooking(int bookingId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/bookings/$bookingId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📥 Delete response: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Booking deleted successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        throw Exception('Failed to delete booking');
      }
    } catch (e) {
      print('❌ Delete booking error: $e');
      rethrow;
    }
  }
}