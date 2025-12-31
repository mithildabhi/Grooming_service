// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class BookingController extends GetxController {
  // Selection fields
  final RxString selectedDate = ''.obs;
  final RxString selectedTime = ''.obs;
  final RxString selectedService = ''.obs;

  // Data fields
  final RxList<Map<String, dynamic>> bookings = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> statistics = <String, dynamic>{}.obs;

  // Computed property for today's bookings
  List<Map<String, dynamic>> get todayBookings {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return bookings.where((booking) {
      final bookingDate = booking['booking_date'] ?? '';
      return bookingDate == todayStr;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  // Fetch all bookings
  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bookings/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bookings.value = List<Map<String, dynamic>>.from(data);
        _calculateStatistics();
      } else {
        Get.snackbar('Error', 'Failed to fetch bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      Get.snackbar('Error', 'Failed to fetch bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update booking status
  Future<void> updateStatus(int bookingId, String newStatus) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      final token = await user.getIdToken();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Booking status updated');
        await fetchBookings(); // Refresh the list
      } else {
        Get.snackbar('Error', 'Failed to update status');
      }
    } catch (e) {
      print('Error updating status: $e');
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  // Calculate statistics
  void _calculateStatistics() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final todayBookingsList = bookings.where((b) => b['booking_date'] == todayStr).toList();
    
    statistics.value = {
      'today': {
        'total': todayBookingsList.length,
        'confirmed': todayBookingsList.where((b) => b['status'] == 'CONFIRMED').length,
        'completed': todayBookingsList.where((b) => b['status'] == 'COMPLETED').length,
        'pending': todayBookingsList.where((b) => b['status'] == 'PENDING').length,
        'cancelled': todayBookingsList.where((b) => b['status'] == 'CANCELLED').length,
      },
      'all': {
        'total': bookings.length,
        'confirmed': bookings.where((b) => b['status'] == 'CONFIRMED').length,
        'completed': bookings.where((b) => b['status'] == 'COMPLETED').length,
        'pending': bookings.where((b) => b['status'] == 'PENDING').length,
        'cancelled': bookings.where((b) => b['status'] == 'CANCELLED').length,
      }
    };
  }

  // Clear selection
  void clear() {
    selectedDate.value = '';
    selectedTime.value = '';
    selectedService.value = '';
  }
}