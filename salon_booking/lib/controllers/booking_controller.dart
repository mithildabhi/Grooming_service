// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../models/salon_model.dart';
import '../models/service_model.dart';
import '../models/employee_model.dart';
import '../services/booking_api.dart';

class BookingController extends GetxController {
  // ========================
  // BOOKING CREATION STATE
  // ========================
  final Rxn<BookingModel> currentBooking = Rxn<BookingModel>();
  final Rxn<SalonModel> selectedSalon = Rxn<SalonModel>();
  final Rxn<ServiceModel> selectedService = Rxn<ServiceModel>();
  final Rxn<EmployeeModel> selectedStaff = Rxn<EmployeeModel>();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxString selectedTime = ''.obs;

  // ========================
  // BOOKING LIST STATE
  // ========================
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxList<BookingModel> userBookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreatingBooking = false.obs;

  // ========================
  // TIME SLOTS
  // ========================
  final RxList<String> availableTimeSlots = <String>[].obs;
  final RxBool isLoadingSlots = false.obs;

  /// Cancelled bookings
  List<BookingModel> get cancelledBookings {
    return bookings.where((b) => b.status == 'CANCELLED').toList();
  }
  // ========================
  // COMPUTED PROPERTIES
  // ========================
  
  /// Today's bookings
  List<BookingModel> get todayBookings {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return bookings.where((b) => b.date == todayStr).toList();
  }

  /// Remaining bookings (PENDING + CONFIRMED, not past)
  List<BookingModel> get remainingBookings {
    final now = DateTime.now();
    return bookings.where((b) {
      if (b.status == 'COMPLETED' || b.status == 'CANCELLED') {
        return false;
      }
      
      try {
        final bookingDate = DateTime.parse(b.date);
        final timeParts = b.time.split(':');
        final bookingDateTime = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        
        // Add duration to get end time
        final endTime = bookingDateTime.add(Duration(minutes: b.durationMinutes));
        
        // Only show if not past
        return endTime.isAfter(now);
      } catch (e) {
        print('Error parsing booking date/time: $e');
        return true; // Show if can't parse
      }
    }).toList();
  }

  /// Completed bookings
  List<BookingModel> get completedBookings {
    return bookings.where((b) => b.status == 'COMPLETED').toList();
  }

  /// Upcoming user bookings
  List<BookingModel> get upcomingBookings {
    final now = DateTime.now();
    return userBookings.where((b) {
      final d = DateTime.tryParse(b.date);
      return d != null &&
          d.isAfter(now) &&
          b.status != 'CANCELLED' &&
          b.status != 'COMPLETED';
    }).toList();
  }

  /// Past user bookings
  List<BookingModel> get pastBookings {
    final now = DateTime.now();
    return userBookings.where((b) {
      final d = DateTime.tryParse(b.date);
      return d != null &&
          (d.isBefore(now) || b.status == 'CANCELLED' || b.status == 'COMPLETED');
    }).toList();
  }

  // ========================
  // 💰 REVENUE CALCULATIONS
  // ========================
  
  /// Total revenue from all completed bookings
  double get totalRevenue {
    return completedBookings.fold(0.0, (sum, b) => sum + b.price);
  }

  /// Today's revenue from completed bookings
  double get todayRevenue {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return bookings
        .where((b) => b.date == todayStr && b.status == 'COMPLETED')
        .fold(0.0, (sum, b) => sum + b.price);
  }

  /// This month's revenue from completed bookings
  double get monthRevenue {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    return bookings
        .where((b) => b.date.startsWith(monthStr) && b.status == 'COMPLETED')
        .fold(0.0, (sum, b) => sum + b.price);
  }

  /// Pending revenue (confirmed but not completed)
  double get pendingRevenue {
    return bookings
        .where((b) => b.status == 'CONFIRMED' || b.status == 'PENDING')
        .fold(0.0, (sum, b) => sum + b.price);
  }

  // ========================
  // STATISTICS
  // ========================
  
  int get totalBookingsCount => bookings.length;
  int get confirmedCount => bookings.where((b) => b.status == 'CONFIRMED').length;
  int get completedCount => bookings.where((b) => b.status == 'COMPLETED').length;
  int get cancelledCount => bookings.where((b) => b.status == 'CANCELLED').length;
  int get pendingCount => bookings.where((b) => b.status == 'PENDING').length;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
    fetchUserBookings();
    
    // Auto-refresh every 60 seconds to update time-based filters
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  // Auto-refresh timer
  var _autoRefreshTimer;
  
  void _startAutoRefresh() {
    _autoRefreshTimer = Stream.periodic(const Duration(seconds: 60)).listen((_) {
      // Silently refresh bookings
      fetchBookings();
    });
  }

  // ========================
  // INITIALIZE BOOKING
  // ========================
  void initializeBooking({
    required SalonModel salon,
    required ServiceModel service,
  }) {
    selectedSalon.value = salon;
    selectedService.value = service;
    selectedDate.value = null;
    selectedTime.value = '';
    selectedStaff.value = null;

    print('✅ Booking initialized: ${salon.name} - ${service.name}');
  }

  // ========================
  // DATE / TIME / STAFF
  // ========================
  void selectDate(DateTime date) {
    selectedDate.value = date;
    generateTimeSlots(date);
    print('📅 Date selected: $date');
  }

  void selectTime(String time) {
    selectedTime.value = time;
    print('⏰ Time selected: $time');
  }

  void selectStaff(EmployeeModel? staff) {
    selectedStaff.value = staff;
    print(staff != null
        ? '👤 Staff selected: ${staff.fullName}'
        : '👤 No staff selected');
  }

  // ========================
  // TIME SLOTS (UI ONLY)
  // ========================
  void generateTimeSlots(DateTime date) {
    isLoadingSlots.value = true;
    availableTimeSlots.clear();

    for (int h = 9; h <= 21; h++) {
      for (int m = 0; m < 60; m += 30) {
        availableTimeSlots.add(
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      }
    }

    isLoadingSlots.value = false;
  }

  // ========================
  // VALIDATION
  // ========================
  bool validateBooking() {
    if (selectedSalon.value == null ||
        selectedService.value == null ||
        selectedDate.value == null ||
        selectedTime.value.isEmpty) {
      Get.snackbar('Error', 'Please complete all booking details');
      return false;
    }
    return true;
  }

  // ========================
  // CREATE BOOKING
  // ========================
  Future<bool> createBooking({
    required String customerName,
    required String customerPhone,
  }) async {
    if (!validateBooking()) return false;

    try {
      isCreatingBooking.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Please login');

      final d = selectedDate.value!;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final result = await BookingApi.createBooking(
        serviceId: selectedService.value!.id,
        bookingDate: dateStr,
        bookingTime: '${selectedTime.value}:00',
        staffId: selectedStaff.value?.id,
        customerName: customerName.isEmpty ? null : customerName,
        customerPhone: customerPhone.isEmpty ? null : customerPhone,
      );

      print('✅ Booking created: $result');

      if (result.containsKey('booking')) {
        currentBooking.value = BookingModel.fromJson(result['booking']);
      }

      Get.snackbar('Success', 'Booking created successfully');
      await fetchUserBookings();
      await fetchBookings();
      return true;
    } catch (e) {
      print('❌ Create booking error: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isCreatingBooking.value = false;
    }
  }

  // ========================
  // FETCH BOOKINGS
  // ========================
  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      final data = await BookingApi.getBookings();
      bookings.value = data.map((e) => BookingModel.fromJson(e)).toList();
      
      print('📋 Fetched ${bookings.length} bookings');
      print('✅ Completed: ${completedCount}');
      print('⏳ Remaining: ${remainingBookings.length}');
    } catch (e) {
      print('❌ Fetch bookings error: $e');
      Get.snackbar('Error', 'Failed to load bookings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserBookings() async {
    try {
      isLoading.value = true;
      final data = await BookingApi.getBookings();
      userBookings.value = data.map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Fetch user bookings error: $e');
    } finally {
      isLoading.value = false;
    }
  }

// Replace the STATUS UPDATES section in your BookingController with this:

  // ========================
  // STATUS UPDATES - FIXED
  // ========================
  Future<void> updateStatus(dynamic id, String status) async {
    print('═══════════════════════════════════════');
    print('🔄 CONTROLLER: updateStatus called');
    print('   Booking ID: $id (${id.runtimeType})');
    print('   New Status: $status');
    print('═══════════════════════════════════════');
    
    try {
      // Validate booking ID
      if (id == null) {
        print('❌ CONTROLLER: ID is null');
        throw Exception('Invalid booking ID');
      }

      // Convert to int if needed
      print('🔵 CONTROLLER: Converting ID...');
      final int bookingId = id is int ? id : int.parse(id.toString());
      print('✅ CONTROLLER: ID converted to $bookingId');
      
      print('🔵 CONTROLLER: Showing loading dialog...');
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      print('✅ CONTROLLER: Loading dialog shown');

      print('🔵 CONTROLLER: Calling BookingApi.updateBookingStatus...');
      // Call API
      await BookingApi.updateBookingStatus(bookingId, status);
      print('✅ CONTROLLER: API call completed successfully');

      print('🔵 CONTROLLER: Closing loading dialog...');
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      print('✅ CONTROLLER: Dialog closed');

      print('✅ CONTROLLER: Status updated successfully');

      print('🔵 CONTROLLER: Updating local state...');
      // Update local state
      _updateLocalBookingStatus(bookingId, status);
      print('✅ CONTROLLER: Local state updated');

      print('🔵 CONTROLLER: Refreshing bookings from server...');
      // Refresh bookings from server
      await fetchBookings();
      print('✅ CONTROLLER: Bookings refreshed');

      // Show success message
      Get.snackbar(
        'Success',
        'Booking status updated to $status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        duration: const Duration(seconds: 2),
      );
      
      print('═══════════════════════════════════════');
      print('✅ CONTROLLER: updateStatus completed successfully');
      print('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌ CONTROLLER: Exception in updateStatus');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('   Stack trace:');
      print(stackTrace);
      print('═══════════════════════════════════════');
      
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('❌ CONTROLLER: Update status error: $e');
      
      // Show error message
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        duration: const Duration(seconds: 4),
      );

      // Don't rethrow - we've handled the error
    }
  }

  /// Update booking status in local state without API call
  void _updateLocalBookingStatus(int bookingId, String status) {
    try {
      // Update in bookings list
      final bookingIndex = bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        bookings[bookingIndex] = bookings[bookingIndex].copyWith(status: status);
        bookings.refresh();
        print('✅ Updated booking $bookingId in bookings list');
      }

      // Update in userBookings list
      final userBookingIndex = userBookings.indexWhere((b) => b.id == bookingId);
      if (userBookingIndex != -1) {
        userBookings[userBookingIndex] = userBookings[userBookingIndex].copyWith(status: status);
        userBookings.refresh();
        print('✅ Updated booking $bookingId in userBookings list');
      }
    } catch (e) {
      print('⚠️ Error updating local booking status: $e');
    }
  }

  Future<void> cancelBooking(dynamic id) async {
    print('🚫 CONTROLLER: Cancelling booking $id');
    await updateStatus(id, 'CANCELLED');
  }

  Future<void> completeBooking(dynamic id) async {
    print('✅ CONTROLLER: Completing booking $id');
    await updateStatus(id, 'COMPLETED');
  }

  Future<void> confirmBooking(dynamic id) async {
    print('✔️ CONTROLLER: Confirming booking $id');
    await updateStatus(id, 'CONFIRMED');
  }
  
  
  // ========================
  // HELPER: Check if booking is past
  // ========================
  bool isBookingPast(BookingModel booking) {
    try {
      final bookingDate = DateTime.parse(booking.date);
      final timeParts = booking.time.split(':');
      final bookingDateTime = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      
      final endTime = bookingDateTime.add(Duration(minutes: booking.durationMinutes));
      return endTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}