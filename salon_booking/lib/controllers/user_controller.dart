// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'booking_controller.dart';

class UserController extends GetxController {
  // ========================
  // USER PROFILE STATE
  // ========================
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;

  // ========================
  // USER STATISTICS
  // ========================
  final RxInt totalBookings = 0.obs;
  final RxInt completedBookings = 0.obs;
  final RxDouble totalSpent = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ USER: Skipping init (not logged in)');
      return;
    }

    loadUserData();
    loadUserStatistics();
  }

  // ========================
  // LOAD USER DATA
  // ========================
  void loadUserData() {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        print('⚠️ USER: No Firebase user found');
        return;
      }

      userName.value = firebaseUser.displayName ?? 'Guest User';
      userEmail.value = firebaseUser.email ?? '';
      userPhone.value = firebaseUser.phoneNumber ?? '';

      print('✅ USER: Data loaded for ${userEmail.value}');
    } catch (e) {
      print('❌ USER: Error loading user data: $e');
    }
  }

  // ========================
  // LOAD USER STATISTICS
  // ========================
  Future<void> loadUserStatistics() async {
    try {
      final bookingController = Get.find<BookingController>();

      await bookingController.fetchUserBookings();

      final bookings = bookingController.userBookings;

      totalBookings.value = bookings.length;
      completedBookings.value = bookings
          .where((b) => b.status == 'COMPLETED')
          .length;

      totalSpent.value = bookings
          .where((b) => b.status == 'COMPLETED')
          .fold(0.0, (sum, b) => sum + b.price);

      print('✅ USER: Statistics loaded');
      print('   Total bookings: ${totalBookings.value}');
      print('   Completed: ${completedBookings.value}');
      print('   Total spent: ₹${totalSpent.value}');
    } catch (e) {
      print('❌ USER: Error loading statistics: $e');
    }
  }

  // ========================
  // REFRESH USER DATA
  // ========================
  Future<void> refreshUserData() async {
    loadUserData();
    await loadUserStatistics();
  }

  // ========================
  // UPDATE PROFILE (UI ONLY)
  // ========================
  Future<bool> updateProfile({String? name, String? phone}) async {
    try {
      if (name != null) userName.value = name;
      if (phone != null) userPhone.value = phone;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('❌ USER: Update profile error: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ========================
  // LOGOUT
  // ========================
  Future<void> logout() async {
    try {
      print('👋 USER: Logging out...');

      userName.value = '';
      userEmail.value = '';
      userPhone.value = '';
      totalBookings.value = 0;
      completedBookings.value = 0;
      totalSpent.value = 0.0;

      final bookingController = Get.find<BookingController>();
      bookingController.userBookings.clear();
      bookingController.bookings.clear();

      final authController = Get.find<AuthController>();
      await authController.logout();
    } catch (e) {
      print('❌ USER: Logout error: $e');
      Get.offAllNamed('/login');
    }
  }
}
