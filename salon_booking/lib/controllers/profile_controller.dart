import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final RxString name = 'John Doe'.obs;
  final RxString email = 'john@example.com'.obs;
  final RxString phone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    // Load from Firebase Auth
    // This will be populated from Firebase Auth when needed
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      print('📝 PROFILE: Updating profile...');
      
      if (name != null) this.name.value = name;
      if (phone != null) this.phone.value = phone;
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF121A22),
        colorText: const Color(0xFF19F6E8),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      
      print('✅ PROFILE: Profile updated');
      return true;
    } catch (e) {
      print('❌ PROFILE: Update profile error: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  void logout() {
    // handled by auth controller
  }
}
