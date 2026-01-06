// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'auth_controller.dart';
import 'booking_controller.dart';

class UserController extends GetxController {
  // User profile state
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  
  // Statistics
  final RxInt totalBookings = 0.obs;
  final RxInt completedBookings = 0.obs;
  final RxDouble totalSpent = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadUserStatistics();
  }

  // ========================
  // LOAD USER DATA
  // ========================
  void loadUserData() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.user.value;
      
      if (user != null) {
        userName.value = user.fullName;
        userEmail.value = user.email;
        userPhone.value = user.phone ?? '';
        
        print('✅ USER: Data loaded for ${user.fullName}');
      }
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
  // UPDATE PROFILE
  // ========================
  Future<bool> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      print('📝 USER: Updating profile...');
      
      // TODO: Call your API to update profile
      // final response = await UserApi.updateProfile(name, phone);
      
      if (name != null) userName.value = name;
      if (phone != null) userPhone.value = phone;
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      print('✅ USER: Profile updated');
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
      
      // Clear user-specific data
      userName.value = '';
      userEmail.value = '';
      userPhone.value = '';
      totalBookings.value = 0;
      completedBookings.value = 0;
      totalSpent.value = 0.0;
      
      print('✅ USER: User data cleared');
      
      // Clear booking controller data
      try {
        final bookingController = Get.find<BookingController>();
        bookingController.userBookings.clear();
        bookingController.bookings.clear();
        print('✅ USER: Booking data cleared');
      } catch (e) {
        print('⚠️ USER: Booking controller not found: $e');
      }
      
      // Logout from auth
      final authController = Get.find<AuthController>();
      await authController.logout();
      
      print('✅ USER: Logout complete');
      
    } catch (e) {
      print('❌ USER: Logout error: $e');
      Get.offAllNamed('/login');
    }
  }
}