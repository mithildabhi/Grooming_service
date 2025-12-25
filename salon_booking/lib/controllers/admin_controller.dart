// lib/controllers/admin_controller.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/booking_model.dart';
import '../models/salon_profile.dart';
import '../models/service_model.dart';
<<<<<<< Updated upstream
=======
import '../services/service_api.dart';
import '../services/salon_api_service.dart'; // ADD THIS
>>>>>>> Stashed changes

class AdminController extends GetxController {
  // =========================
  // CORE STATE
  // =========================
<<<<<<< Updated upstream

  final RxString activeSalonId = ''.obs;
  final Rxn<SalonProfile> salonProfile = Rxn<SalonProfile>();
=======
  final RxString activeSalonId = '1'.obs;
  final Rxn<SalonProfile> salonProfile = Rxn<SalonProfile>();
  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingProfile = false.obs; // ADD THIS
>>>>>>> Stashed changes

  // =========================
  // BOOKINGS
  // =========================
  final RxList<Map<String, dynamic>> bookingsList =
      <Map<String, dynamic>>[].obs;

  /// ✅ REQUIRED BY DASHBOARD
  List<Map<String, dynamic>> get todayBookings =>
      bookingsList.where((b) => b['status'] == 'created').toList();

  List<Map<String, dynamic>> get pendingBookings =>
      bookingsList.where((b) => b['status'] == 'created').toList();

  List<Map<String, dynamic>> get completedBookings =>
      bookingsList.where((b) => b['status'] == 'completed').toList();

  List<Map<String, dynamic>> get weeklyBookings => bookingsList;

  // =========================
  // STAFF
  // =========================
  final RxList<Map<String, dynamic>> employeesList =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> filteredEmployees =
      <Map<String, dynamic>>[].obs;

  // =========================
<<<<<<< Updated upstream
  // SERVICES / OFFERS / INVENTORY / GALLERY / REVIEWS
  // =========================

  final RxList<Map<String, dynamic>> servicesList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> offersList = <Map<String, dynamic>>[].obs;
=======
  // SERVICES (DJANGO)
  // =========================
  final RxList<ServiceModel> servicesList = <ServiceModel>[].obs;

  // =========================
  // OTHER MODULES (UI)
  // =========================
>>>>>>> Stashed changes
  final RxList<Map<String, dynamic>> inventoryList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> galleryList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> reviewsList = <Map<String, dynamic>>[].obs;

  // =========================
  // DASHBOARD HELPERS
  // =========================

  List<Map<String, dynamic>> get topStaff => employeesList;
  List<Map<String, dynamic>> get popularServices => servicesList;

  // =========================
  // INIT
  // =========================
<<<<<<< Updated upstream
@override
void onInit() {
  super.onInit();

  // TEMP: assume admin owns salon with id = 1
  activeSalonId.value = '1';

  filteredEmployees.assignAll(employeesList);
}

  // @override
  // void onInit() {
  //   super.onInit();
  //   filteredEmployees.assignAll(employeesList);
  // }
=======
  @override
  void onInit() {
    super.onInit();
    fetchServices();
    loadSalonProfile(); // ADD THIS - Load profile on init
    filteredEmployees.assignAll(employeesList);
  }
>>>>>>> Stashed changes

  // =========================
  // SALON PROFILE (NEW - DJANGO CONNECTED)
  // =========================

  /// Load salon profile from Django
  Future<void> loadSalonProfile() async {
    try {
      isLoadingProfile.value = true;
      print('🔄 Loading salon profile...');
      
      final profile = await SalonApiService.getMyProfile();
      
      if (profile != null) {
        salonProfile.value = profile;
        activeSalonId.value = profile.id;
        print('✅ Profile loaded: ${profile.name}');
      } else {
        print('⚠️ No profile found - user needs to create one');
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load salon profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Save salon profile to Django
  Future<void> saveSalonProfile(SalonProfile profile) async {
    try {
      isLoadingProfile.value = true;
      print('💾 Saving salon profile...');
      
      final savedProfile = await SalonApiService.saveProfile(profile);
      
      salonProfile.value = savedProfile;
      activeSalonId.value = savedProfile.id;
      
      print('✅ Profile saved successfully!');
      Get.snackbar(
        'Success',
        'Salon profile saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22E6D3),
        colorText: Colors.black,
      );
    } catch (e) {
      print('❌ Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Update existing salon profile
  Future<void> updateSalonProfile(SalonProfile profile) async {
    try {
      isLoadingProfile.value = true;
      print('📝 Updating salon profile...');
      
      final updatedProfile = await SalonApiService.updateProfile(profile);
      
      salonProfile.value = updatedProfile;
      
      print('✅ Profile updated successfully!');
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22E6D3),
        colorText: Colors.black,
      );
    } catch (e) {
      print('❌ Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // =========================
  // SALON
  // =========================
  void setActiveSalon(String salonId) {
    activeSalonId.value = salonId;
  }

  // =========================
<<<<<<< Updated upstream
  // BOOKINGS
=======
  // SERVICES (DJANGO CONNECTED)
  // =========================
  Future<void> fetchServices() async {
    try {
      isLoadingServices.value = true;
      servicesList.assignAll(await ServiceApi.fetchServices());
    } catch (e) {
      Get.snackbar("Error", "Failed to load services");
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> addService({
    required String token,
    required String name,
    required String description,
    required double price,
    required int duration,
    required String category,
  }) async {
    await ServiceApi.createService(
      token: token,
      name: name,
      description: description,
      price: price,
      duration: duration,
      category: category,
    );

    await fetchServices();
    Get.back();
    Get.snackbar("Success", "Service added");
  }

  Future<void> deleteService({
    required String token,
    required int serviceId,
  }) async {
    await ServiceApi.deleteService(token: token, serviceId: serviceId);
    servicesList.removeWhere((s) => s.id == serviceId);
    Get.snackbar("Deleted", "Service removed");
  }

  // =========================
  // BOOKINGS (ADMIN + USER)
>>>>>>> Stashed changes
  // =========================
  Future<void> addBooking(BookingModel booking) async {
    bookingsList.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'customerName': booking.customerName,
      'serviceName': booking.serviceName,
      'price': booking.price,
      'status': booking.status,
    });
  }

  Future<void> approveBooking(String bookingId, String staffId) async {
    updateBookingStatus(bookingId, 'approved');
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    updateBookingStatus(bookingId, 'cancelled');
  }

  Future<void> completeBooking(String bookingId) async {
    updateBookingStatus(bookingId, 'completed');
  }

  /// ✅ MUST BE PUBLIC (USED BY WIDGETS)
  void updateBookingStatus(String id, String status) {
    final index = bookingsList.indexWhere((b) => b['id'] == id);
    if (index != -1) {
      bookingsList[index]['status'] = status;
      bookingsList.refresh();
    }
  }

  // =========================
  // EMPLOYEES
  // =========================
<<<<<<< Updated upstream

  Future<void> addEmployee(Map<String, dynamic> employee) async {
    employeesList.add(employee);
    filteredEmployees.assignAll(employeesList);
=======
  Future<void> addInventory(Map<String, dynamic> item) async {
    inventoryList.add(item);
>>>>>>> Stashed changes
  }

  Future<void> deleteEmployee(String id) async {
    employeesList.removeWhere((e) => e['id'] == id);
    filteredEmployees.assignAll(employeesList);
  }

  void searchEmployee(String query) {
    if (query.isEmpty) {
      filteredEmployees.assignAll(employeesList);
    } else {
      filteredEmployees.assignAll(
        employeesList.where(
          (e) =>
              e['name'].toString().toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  // =========================
  // SERVICES
  // =========================

  Future<void> addService(ServiceModel service) async {
    servicesList.add(service.toJson());
  }

  Future<void> deleteService(String serviceId) async {
    servicesList.removeWhere((s) => s['id'] == serviceId);
  }

  // =========================
  // OFFERS
  // =========================
  Future<void> addOffer(Map<String, dynamic> offer) async {
    offersList.add(offer);
  }

  Future<void> deleteOffer(String offerId) async {
    offersList.removeWhere((o) => o['id'] == offerId);
  }

  // =========================
  // INVENTORY
  // =========================

  Future<void> addInventory(Map<String, dynamic> item) async {
    inventoryList.add(item);
  }

  Future<void> deleteInventory(String itemId) async {
    inventoryList.removeWhere((i) => i['id'] == itemId);
  }

  // =========================
  // GALLERY
  // =========================
  Future<void> deleteGalleryImage(String id) async {
    galleryList.removeWhere((g) => g['id'] == id);
  }

  Future<void> pickAndUploadGalleryImage({required bool fromCamera}) async {}
<<<<<<< Updated upstream

  // =========================
  // PROFILE
  // =========================

  Future<void> saveSalonProfile(SalonProfile profile) async {
    salonProfile.value = profile;
  }
=======
>>>>>>> Stashed changes

  // =========================
  // REVIEWS
  // =========================
<<<<<<< Updated upstream

  Future<void> deleteReview(String reviewId) async {
    reviewsList.removeWhere((r) => r['id'] == reviewId);
=======
  Future<void> deleteReview(String id) async {
    reviewsList.removeWhere((r) => r['id'] == id);
  }

  // =========================
  // STAFF
  // =========================
  Future<void> deleteStaff(dynamic staff) async {
    employeesList.remove(staff);
    filteredEmployees.assignAll(employeesList);
  }

  // =========================
  // PROFILE (IMAGE UPLOAD - TO BE IMPLEMENTED)
  // =========================
  Future<String?> pickAndUploadImage({
    required bool fromCamera,
    int imageQuality = 80,
    String? pathPrefix,
  }) async {
    // TODO: Implement image upload to server/cloud storage
    return null;
>>>>>>> Stashed changes
  }

  // =========================
  // AUTH
  // =========================
  Future<void> logout() async {
    Get.snackbar("Logged out", "Session ended");
  }
<<<<<<< Updated upstream

  Future<String?> pickAndUploadImage({
    required bool fromCamera,
    int imageQuality = 80,
    String? pathPrefix,
  }) async {
    // MOCK implementation (backend will replace)
    return null;
  }

  Future<void> deleteBooking(String bookingId, booking) async {
    bookingsList.removeWhere((b) => b['id'] == bookingId);
  }

  void deleteStaff(dynamic staff) {
    employeesList.remove(staff);
    filteredEmployees.assignAll(employeesList);
  }
}
=======
}
>>>>>>> Stashed changes
