// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';
import '../models/customer_model.dart';
import 'auth_controller.dart';
import 'booking_controller.dart';
import '../widgets/custom_snackbar.dart';

class UserController extends GetxController {
  // ========================
  // CUSTOMER PROFILE STATE (Rx for reactivity)
  // ========================
  final Rxn<CustomerModel> customerProfile = Rxn<CustomerModel>();
  
  // Rx wrappers for compatibility with existing code
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;
  final RxString userCity = ''.obs;
  final RxString userPincode = ''.obs;
  final RxString userGender = ''.obs;
  final RxString userDateOfBirth = ''.obs;
  
  // Statistics as Rx
  final RxInt totalBookings = 0.obs;
  final RxInt completedBookings = 0.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxString loyaltyTier = 'NEW'.obs;

  // ========================
  // LOADING STATE
  // ========================
  final RxBool isDataLoaded = false.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();

    // ✅ ONLY load if user is already logged in
    final user = FirebaseAuth.instance.currentUser;
    final auth = Get.find<AuthController>();
    
    if (user != null && auth.isLoggedIn.value == true) {
      print('✅ USER: User already logged in, loading profile');
      loadCustomerProfile();
    } else {
      print('⚠️ USER: Waiting for login before loading data');
    }
  }

  // ========================
  // SYNC Rx VARS FROM CUSTOMER PROFILE
  // ========================
  void _syncRxVarsFromProfile() {
    if (customerProfile.value != null) {
      final profile = customerProfile.value!;
      
      print('🔄 USER: Syncing Rx vars from profile...');
      print('   Full Name: "${profile.fullName}"');
      print('   Email: "${profile.email}"');
      print('   Phone: "${profile.phone}"');
      
      userName.value = profile.fullName;
      userEmail.value = profile.email;
      userPhone.value = profile.phone;
      userAddress.value = profile.address;
      userCity.value = profile.city;
      userPincode.value = profile.pincode;
      userGender.value = profile.gender;
      userDateOfBirth.value = profile.dateOfBirth ?? '';
      
      totalBookings.value = profile.totalBookings;
      completedBookings.value = profile.completedBookings;
      totalSpent.value = profile.totalSpent;
      loyaltyTier.value = profile.loyaltyTier;
      
      print('✅ USER: Sync complete');
      print('   userName.value: "${userName.value}"');
      print('   userEmail.value: "${userEmail.value}"');
      print('   userPhone.value: "${userPhone.value}"');
    }
  }

  // ========================
  // LOAD CUSTOMER PROFILE FROM BACKEND
  // ========================
  Future<void> loadCustomerProfile() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        print('⚠️ USER: No Firebase user found');
        isDataLoaded.value = false;
        return;
      }

      // Get Firebase ID token for authentication
      final idToken = await firebaseUser.getIdToken();

      print('🔥 USER: Fetching customer profile from backend...');
      print('   URL: ${ApiConfig.baseUrl}/customers/me/');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customers/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 USER: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📦 USER: Raw response data: $data');
        
        customerProfile.value = CustomerModel.fromJson(data);
        
        // Sync Rx vars for existing code compatibility
        _syncRxVarsFromProfile();
        
        isDataLoaded.value = true;
        print('✅ USER: Customer profile loaded successfully');
      } else if (response.statusCode == 404) {
        print('⚠️ USER: Profile not found (404) - will be auto-created on next request');
        print('   Response body: ${response.body}');
        isDataLoaded.value = false;
      } else {
        print('❌ USER: Failed to load profile: ${response.statusCode}');
        print('   Response: ${response.body}');
        isDataLoaded.value = false;
      }
    } catch (e, stackTrace) {
      print('❌ USER: Error loading customer profile: $e');
      print('   Stack trace: $stackTrace');
      isDataLoaded.value = false;
    }
  }

  // ========================
  // LEGACY METHOD NAMES (for compatibility)
  // ========================
  Future<void> loadUserData() async {
    await loadCustomerProfile();
  }

  Future<void> loadUserStatistics() async {
    // Statistics are loaded with profile, so just refresh bookings
    if (Get.isRegistered<BookingController>()) {
      await Get.find<BookingController>().fetchUserBookings();
    }
  }

  // ========================
  // REFRESH USER DATA
  // ========================
  Future<void> refreshUserData() async {
    print('🔄 USER: Refreshing customer profile...');
    await loadCustomerProfile();
    
    // Also refresh bookings for statistics
    if (Get.isRegistered<BookingController>()) {
      await Get.find<BookingController>().fetchUserBookings();
    }
    
    print('✅ USER: Profile refreshed');
  }

  // ========================
  // UPDATE CUSTOMER PROFILE
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
      isUpdating.value = true;
      
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ USER: No Firebase user found');
        print('❌ USER: No Firebase user found');
        CustomSnackbar.show(title: 'Error', message: 'Please log in again', isError: true);
        return false;
      }

      final idToken = await firebaseUser.getIdToken();

      print('📤 USER: Updating customer profile...');

      // Build update payload - only include changed fields
      final Map<String, dynamic> updateData = {};
      
      if (name != null && name.trim().isNotEmpty) {
        updateData['full_name'] = name.trim();
      }
      
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
      }
      
      if (address != null) {
        updateData['address'] = address.trim();
      }
      
      if (city != null) {
        updateData['city'] = city.trim();
      }
      
      if (pincode != null) {
        updateData['pincode'] = pincode.trim();
      }
      
      if (gender != null) {
        updateData['gender'] = gender;
      }
      
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        // Extract date only (YYYY-MM-DD) from ISO string or datetime
        final datePart = dateOfBirth.split('T')[0];
        updateData['date_of_birth'] = datePart;
      }

      if (updateData.isEmpty) {
        print('⚠️ USER: No changes to update');
        CustomSnackbar.show(title: 'Info', message: 'No changes to save');
        return false;
      }

      print('📝 Update data: $updateData');

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/customers/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(updateData),
      ).timeout(const Duration(seconds: 15));

      print('📊 Update response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        customerProfile.value = CustomerModel.fromJson(data);
        
        // Sync Rx vars
        _syncRxVarsFromProfile();
        
        print('✅ USER: Profile updated successfully');
        
        print('✅ USER: Profile updated successfully');
        
        CustomSnackbar.show(
          title: 'Success',
          message: 'Profile updated successfully',
          isSuccess: true,
        );
        
        return true;
      } else {
        final errorBody = response.body;
        print('❌ USER: Update failed: ${response.statusCode}');
        print('   Response: $errorBody');
        
        // Try to parse error message
        String errorMessage = 'Failed to update profile';
        try {
          final errorData = jsonDecode(errorBody);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData is Map) {
            // Show first validation error
            final firstError = errorData.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        } catch (_) {}
        
        CustomSnackbar.show(
          title: 'Error',
          message: errorMessage,
          isError: true,
        );
        
        return false;
      }
    } catch (e) {
      print('❌ USER: Update error: $e');
      
      CustomSnackbar.show(
        title: 'Error', 
        message: 'Network error. Please check your connection.', 
        isError: true,
      );
      
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ========================
  // LOGOUT
  // ========================
  Future<void> logout() async {
    try {
      print('👋 USER: Logout requested');
      
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.logout();
      } else {
        clearUserData();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('❌ USER: Logout error: $e');
      Get.offAllNamed('/login');
    }
  }

  // ========================
  // CLEAR DATA
  // ========================
  void clearUserData() {
    customerProfile.value = null;
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
    loyaltyTier.value = 'NEW';
    isDataLoaded.value = false;
    print('🧹 USER: User data cleared');
  }
}