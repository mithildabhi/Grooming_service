// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_controller.dart';
import 'booking_controller.dart';

class UserController extends GetxController {
  // ========================
  // USER PROFILE STATE
  // ========================
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;
  final RxString userCity = ''.obs;
  final RxString userPincode = ''.obs;
  final RxString userGender = ''.obs;
  final RxString userDateOfBirth = ''.obs;

  // ========================
  // USER STATISTICS
  // ========================
  final RxInt totalBookings = 0.obs;
  final RxInt completedBookings = 0.obs;
  final RxDouble totalSpent = 0.0.obs;

  // ========================
  // INITIALIZATION FLAG
  // ========================
  final RxBool isDataLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ USER: Skipping init (not logged in yet - will load after login)');
      return;
    }

    // User already logged in (e.g., app restart with valid session)
    loadUserData();
    loadUserStatistics();
  }

  // ========================
  // LOAD USER DATA
  // ========================
  void loadUserData() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        print('⚠️ USER: No Firebase user found');
        isDataLoaded.value = false;
        return;
      }

      // Refresh token to ensure session is valid
      await firebaseUser.getIdToken(true);

      userName.value = firebaseUser.displayName ?? 'Guest User';
      userEmail.value = firebaseUser.email ?? '';
      userPhone.value = firebaseUser.phoneNumber ?? '';

      // Load additional profile data from local storage
      final prefs = await SharedPreferences.getInstance();
      final uid = firebaseUser.uid;
      
      userAddress.value = prefs.getString('${uid}_address') ?? '';
      userCity.value = prefs.getString('${uid}_city') ?? '';
      userPincode.value = prefs.getString('${uid}_pincode') ?? '';
      userGender.value = prefs.getString('${uid}_gender') ?? '';
      userDateOfBirth.value = prefs.getString('${uid}_dob') ?? '';
      
      // Load saved name if displayName is empty
      if (userName.value.isEmpty || userName.value == 'Guest User') {
        final savedName = prefs.getString('${uid}_name');
        if (savedName != null && savedName.isNotEmpty) {
          userName.value = savedName;
        }
      }
      
      // Load saved phone if phoneNumber is empty
      if (userPhone.value.isEmpty) {
        final savedPhone = prefs.getString('${uid}_phone');
        if (savedPhone != null && savedPhone.isNotEmpty) {
          userPhone.value = savedPhone;
        }
      }

      isDataLoaded.value = true;
      print('✅ USER: Data loaded for ${userEmail.value}');
      print('   Name: ${userName.value}');
      print('   Phone: ${userPhone.value}');
      print('   Gender: ${userGender.value}');
    } catch (e) {
      print('❌ USER: Error loading user data: $e');
      isDataLoaded.value = false;
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
    print('🔄 USER: Refreshing user data...');
    loadUserData();
    await loadUserStatistics();
    print('✅ USER: User data refreshed');
  }

  // ========================
  // UPDATE PROFILE
  // ========================
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? pincode,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ USER: updateProfile - No Firebase user found');
        Get.snackbar(
          'Error',
          'Please log in again to update your profile',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Refresh token to ensure session is valid
      await firebaseUser.getIdToken(true);

      final prefs = await SharedPreferences.getInstance();
      final uid = firebaseUser.uid;

      print('📝 USER: Updating profile for UID: $uid');

      // Update local state and save to SharedPreferences
      if (name != null) {
        userName.value = name;
        await prefs.setString('${uid}_name', name);
        print('   ✅ Name updated: $name');
      }
      if (phone != null) {
        userPhone.value = phone;
        await prefs.setString('${uid}_phone', phone);
        print('   ✅ Phone updated: $phone');
      }
      if (address != null) {
        userAddress.value = address;
        await prefs.setString('${uid}_address', address);
        print('   ✅ Address updated: $address');
      }
      if (city != null) {
        userCity.value = city;
        await prefs.setString('${uid}_city', city);
        print('   ✅ City updated: $city');
      }
      if (pincode != null) {
        userPincode.value = pincode;
        await prefs.setString('${uid}_pincode', pincode);
        print('   ✅ Pincode updated: $pincode');
      }
      if (gender != null) {
        userGender.value = gender;
        await prefs.setString('${uid}_gender', gender);
        print('   ✅ Gender updated: $gender');
      }
      if (dateOfBirth != null) {
        userDateOfBirth.value = dateOfBirth;
        await prefs.setString('${uid}_dob', dateOfBirth);
        print('   ✅ DOB updated: $dateOfBirth');
      }

      print('✅ USER: Profile updated successfully');

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
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ========================
  // LOGOUT
  // ========================
  // Delegates to centralized AuthController.logout() which handles all cleanup
  Future<void> logout() async {
    try {
      print('👋 USER: Logout requested, delegating to AuthController...');
      
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.logout();
      } else {
        // Fallback: clear own data and navigate
        clearUserData();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('❌ USER: Logout error: $e');
      Get.offAllNamed('/login');
    }
  }

  // ========================
  // CLEAR DATA (for logout without navigation)
  // ========================
  void clearUserData() {
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    userAddress.value = '';
    userCity.value = '';
    userPincode.value = '';
    userGender.value = '';
    userDateOfBirth.value = '';
    totalBookings.value = 0;
    completedBookings.value = 0;
    totalSpent.value = 0.0;
    isDataLoaded.value = false;
    print('🧹 USER: User data cleared');
  }
}
