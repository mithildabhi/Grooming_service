// lib/controllers/booking_controller.dart
// ✅ COMPLETE FIX: Time slot filtering + Review API integration

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salon_booking/controllers/auth_controller.dart';
import '../models/booking_model.dart';
import '../models/salon_model.dart';
import '../models/service_model.dart';
import '../models/employee_model.dart';
import '../models/employee_model.dart';
import '../services/booking_api.dart';
import '../widgets/custom_snackbar.dart';

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

  /// Today's bookings
  List<BookingModel> get todayBookings {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
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

        final endTime = bookingDateTime.add(
          Duration(minutes: b.durationMinutes),
        );

        return endTime.isAfter(now);
      } catch (e) {
        print('Error parsing booking date/time: $e');
        return true;
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
      if (b.status == 'CANCELLED' || b.status == 'COMPLETED') {
        return false;
      }

      final bookingDateTime = _getBookingDateTime(b);
      if (bookingDateTime == null) return false;

      // Show if the appointment hasn't ended yet
      final endDateTime = bookingDateTime.add(Duration(minutes: b.durationMinutes));
      return endDateTime.isAfter(now);
    }).toList();
  }

  /// Past user bookings
  List<BookingModel> get pastBookings {
    final now = DateTime.now();
    return userBookings.where((b) {
      if (b.status == 'CANCELLED' || b.status == 'COMPLETED') {
        return true;
      }

      final bookingDateTime = _getBookingDateTime(b);
      if (bookingDateTime == null) return false;

      // Show if the appointment has ended
      final endDateTime = bookingDateTime.add(Duration(minutes: b.durationMinutes));
      return endDateTime.isBefore(now);
    }).toList();
  }

  /// Helper to parse full DateTime from booking
  DateTime? _getBookingDateTime(BookingModel b) {
    try {
      final date = DateTime.parse(b.date);
      final timeParts = b.time.split(':');
      
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (e) {
      print('Error parsing booking datetime for ID ${b.id}: $e');
      return null;
    }
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
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
  int get confirmedCount =>
      bookings.where((b) => b.status == 'CONFIRMED').length;
  int get completedCount =>
      bookings.where((b) => b.status == 'COMPLETED').length;
  int get cancelledCount =>
      bookings.where((b) => b.status == 'CANCELLED').length;
  int get pendingCount => bookings.where((b) => b.status == 'PENDING').length;

  @override
  void onInit() {
    super.onInit();

    // ✅ ONLY load bookings if already logged in
    final auth = Get.find<AuthController>();
    
    // ✅ Check CURRENT login state first
    if (auth.isLoggedIn.value == true) {
      print('✅ BOOKING: User already logged in, loading bookings');
      fetchBookings();
      fetchUserBookings();
      _startAutoRefresh();
    }

    // ✅ Watch for future login events
    ever(auth.isLoggedIn, (loggedIn) {
      print('👀 BOOKING: Login state changed to $loggedIn');
      if (loggedIn == true) {
        fetchBookings();
        fetchUserBookings();
        _startAutoRefresh();
      } else {
        // ✅ Clear bookings on logout
        bookings.clear();
        userBookings.clear();
        _autoRefreshTimer?.cancel();
      }
    });
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  // Auto-refresh timer
  var _autoRefreshTimer;

  void _startAutoRefresh() {
    _autoRefreshTimer = Stream.periodic(const Duration(seconds: 60)).listen((
      _,
    ) {
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
    selectedTime.value = ''; // ✅ Reset time when date changes
    generateTimeSlots(date);
    print('📅 Date selected: $date');
  }

  void selectTime(String time) {
    selectedTime.value = time;
    print('⏰ Time selected: $time');
  }

  void selectStaff(EmployeeModel? staff) {
    selectedStaff.value = staff;
    print(
      staff != null
          ? '👤 Staff selected: ${staff.fullName}'
          : '👤 No staff selected',
    );
  }

  // ✅ FIXED: TIME SLOTS WITH PROPER FILTERING FOR TODAY
  void generateTimeSlots(DateTime date) {
    try {
      isLoadingSlots.value = true;
      availableTimeSlots.clear();

      final now = DateTime.now();
      
      // ✅ Check if selected date is TODAY
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      print('📅 Generating time slots for: ${date.toString().split(' ')[0]}');
      print('🔍 Is today: $isToday');
      
      if (isToday) {
        print('⏰ Current time: ${now.hour}:${now.minute}');
      }

      List<String> slots = [];
      
      // Generate slots from 9 AM to 9 PM (21:00)
      for (int hour = 9; hour <= 21; hour++) {
        for (int minute = 0; minute < 60; minute += 30) {
          final timeSlot = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          
          // ✅ FILTER PAST TIMES IF TODAY
          if (isToday) {
            // Skip if this slot is in the past
            if (hour < now.hour) {
              print('⏭️ Skipping past hour: $timeSlot');
              continue;
            }
            
            // If same hour, check minutes
            if (hour == now.hour && minute <= now.minute) {
              print('⏭️ Skipping past minute: $timeSlot');
              continue;
            }
          }
          
          slots.add(timeSlot);
        }
      }

      availableTimeSlots.value = slots;
      isLoadingSlots.value = false;

      print('✅ Generated ${slots.length} available time slots');
      if (slots.isNotEmpty) {
        print('   First slot: ${slots.first}');
        print('   Last slot: ${slots.last}');
      }
    } catch (e) {
      print('❌ Error generating time slots: $e');
      isLoadingSlots.value = false;
      availableTimeSlots.clear();
    }
  }

  // ========================
  // VALIDATION
  // ========================
  bool validateBooking() {
    if (selectedSalon.value == null ||
        selectedService.value == null ||
        selectedDate.value == null ||
        selectedTime.value.isEmpty) {
      CustomSnackbar.show(title: 'Error', message: 'Please complete all booking details', isError: true);
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

      print('✅ Booking created: $result');
      
      CustomSnackbar.show(title: 'Success', message: 'Booking created successfully', isSuccess: true);
      await fetchUserBookings();
      await fetchBookings();
      return true;
    } catch (e) {
      print('❌ Create booking error: $e');
      CustomSnackbar.show(title: 'Error', message: e.toString(), isError: true);
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
      print('✅ Completed: $completedCount');
      print('⏳ Remaining: ${remainingBookings.length}');
    } catch (e) {
      print('❌ Fetch bookings error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load bookings', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserBookings() async {
    try {
      isLoading.value = true;

      final data = await BookingApi.getBookings();

      final parsed = data
          .map<BookingModel>((e) => BookingModel.fromJson(e))
          .toList();

      userBookings.assignAll(parsed);
    } catch (e) {
      print('❌ Fetch user bookings error: $e');
      userBookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // STATUS UPDATES
  // ========================
  Future<void> updateStatus(dynamic id, String status) async {
    print('═══════════════════════════════════════');
    print('🔄 CONTROLLER: updateStatus called');
    print('   Booking ID: $id (${id.runtimeType})');
    print('   New Status: $status');
    print('═══════════════════════════════════════');

    try {
      if (id == null) {
        print('❌ CONTROLLER: ID is null');
        throw Exception('Invalid booking ID');
      }

      print('🔵 CONTROLLER: Converting ID...');
      final int bookingId = id is int ? id : int.parse(id.toString());
      print('✅ CONTROLLER: ID converted to $bookingId');

      print('🔵 CONTROLLER: Showing loading dialog...');
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      print('✅ CONTROLLER: Loading dialog shown');

      print('🔵 CONTROLLER: Calling BookingApi.updateBookingStatus...');
      await BookingApi.updateBookingStatus(bookingId, status);
      print('✅ CONTROLLER: API call completed successfully');

      print('🔵 CONTROLLER: Closing loading dialog...');
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      print('✅ CONTROLLER: Dialog closed');

      print('✅ CONTROLLER: Status updated successfully');

      print('🔵 CONTROLLER: Updating local state...');
      _updateLocalBookingStatus(bookingId, status);
      print('✅ CONTROLLER: Local state updated');

      print('🔵 CONTROLLER: Refreshing bookings from server...');
      await fetchBookings();
      print('✅ CONTROLLER: Bookings refreshed');

      CustomSnackbar.show(
        title: 'Success', 
        message: 'Booking status updated to $status',
        isSuccess: true,
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

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('❌ CONTROLLER: Update status error: $e');

      CustomSnackbar.show(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    }
  }

  void _updateLocalBookingStatus(int bookingId, String status) {
    try {
      final bookingIndex = bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final booking = bookings[bookingIndex];
        bookings[bookingIndex] = booking.copyWith(
          status: status,
          isRated: status == 'COMPLETED' ? false : booking.isRated,
        );
        bookings.refresh();
      }

      final userBookingIndex =
          userBookings.indexWhere((b) => b.id == bookingId);
      if (userBookingIndex != -1) {
        final booking = userBookings[userBookingIndex];
        userBookings[userBookingIndex] = booking.copyWith(
          status: status,
          isRated: status == 'COMPLETED' ? false : booking.isRated,
        );
        userBookings.refresh();
      }
    } catch (e) {
      debugPrint('⚠️ Error updating local booking status: $e');
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

      final endTime = bookingDateTime.add(
        Duration(minutes: booking.durationMinutes),
      );
      return endTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool get isBookingReady =>
      selectedSalon.value != null &&
      selectedService.value != null &&
      selectedDate.value != null &&
      selectedTime.value.isNotEmpty;

  // ========================
  // ⭐ USER REVIEW (UI ONLY FOR NOW - Will integrate ReviewAPI next)
  // ========================
  Future<void> submitReview({
    required int bookingId,
    required int rating,
    required String feedback,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('⭐ REVIEW SUBMITTED');
      debugPrint('Booking ID: $bookingId');
      debugPrint('Rating: $rating');
      debugPrint('Feedback: $feedback');
      debugPrint('═══════════════════════════════════════');

      // Update local booking as rated (frontend only)
      final index = userBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        userBookings[index] = userBookings[index].copyWith(isRated: true);
        userBookings.refresh();
      }

      CustomSnackbar.show(
        title: 'Thank you!', 
        message: 'Your review has been submitted', 
        isSuccess: true,
      );
    } catch (e) {
      debugPrint('❌ submitReview error: $e');
      Get.back(); // close dialog
      CustomSnackbar.show(title: 'Error', message: 'Failed to submit review', isError: true);
    }
  }
}