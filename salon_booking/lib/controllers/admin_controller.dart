import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/booking_model.dart';
import '../models/salon_profile.dart';
import '../models/service_model.dart';

import '../services/service_api.dart';
import '../services/salon_api_service.dart';

class AdminController extends GetxController {
  // =========================
  // CORE STATE
  // =========================
  final RxString activeSalonId = ''.obs;
  final Rxn<SalonProfile> salonProfile = Rxn<SalonProfile>();

  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingProfile = false.obs;

  // =========================
  // BOOKINGS
  // =========================
  final RxList<Map<String, dynamic>> bookingsList =
      <Map<String, dynamic>>[].obs;

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
  // SERVICES (DJANGO)
  // =========================
  final RxList<ServiceModel> servicesList = <ServiceModel>[].obs;

  // =========================
  // OTHER MODULES (UI)
  // =========================
  final RxList<Map<String, dynamic>> inventoryList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> galleryList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> reviewsList = <Map<String, dynamic>>[].obs;

  // =========================
  // GETTERS FOR PROFILE DATA
  // =========================
  String get salonName => salonProfile.value?.name ?? 'Not Set';
  String get ownerEmail => salonProfile.value?.ownerEmail ?? 'No email';
  String get phone => salonProfile.value?.phone ?? 'Not Set';
  String get location => salonProfile.value?.address ?? 'Not Set';
  String get imageUrl => salonProfile.value?.imageUrl ?? '';
  bool get hasProfile => salonProfile.value != null;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    filteredEmployees.assignAll(employeesList);
    fetchServices();
    loadSalonProfile();
  }

  // =========================
  // SALON PROFILE (DJANGO)
  // =========================

  /// Load salon profile
  Future<void> loadSalonProfile() async {
    try {
      isLoadingProfile.value = true;
      print('📄 Loading salon profile...');

      final profile = await SalonApiService.getMyProfile();

      if (profile != null) {
        salonProfile.value = profile;
        activeSalonId.value = profile.id;
        print('✅ Profile loaded: ${profile.name}');
      } else {
        print('ℹ️ No profile found - user needs to create one');
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

  /// Create OR update salon profile
  Future<void> saveSalonProfile(SalonProfile profile) async {
    try {
      isLoadingProfile.value = true;
      print('💾 Saving salon profile...');

      final savedProfile = await SalonApiService.saveProfile(profile);

      salonProfile.value = savedProfile;
      activeSalonId.value = savedProfile.id;

      print('✅ Profile saved successfully: ${savedProfile.name}');

      Get.snackbar(
        'Success',
        'Salon profile saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22E6D3),
        colorText: Colors.black,
      );

      // Return to previous screen
      Get.back();
    } catch (e) {
      print('❌ Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Open edit profile screen
  void openEditProfile() {
    Get.toNamed(
      '/edit-profile',
      arguments: salonProfile.value,
    );
  }

  // =========================
  // SERVICES (DJANGO)
  // =========================

  Future<void> fetchServices() async {
    try {
      isLoadingServices.value = true;
      print('📥 Fetching services...');
      servicesList.assignAll(await ServiceApi.fetchServices());
      print('✅ Loaded ${servicesList.length} services');
    } catch (e) {
      print('❌ Error fetching services: $e');
      Get.snackbar(
        'Error',
        'Failed to load services',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> addService({
    required String name,
    required String description,
    required double price,
    required int duration,
    required String category,
  }) async {
    try {
      isLoadingServices.value = true;
      print('➕ Adding service: $name');

      await ServiceApi.createService(
        name: name,
        description: description,
        price: price,
        duration: duration,
        category: category,
      );

      await fetchServices();
      
      Get.back(); // Close the add screen
      
      Get.snackbar(
        'Success',
        'Service added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22E6D3),
        colorText: Colors.black,
      );
    } catch (e) {
      print('❌ Error adding service: $e');
      Get.snackbar(
        'Error',
        'Failed to add service: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> updateService({
    required int serviceId,
    required String name,
    required String description,
    required double price,
    required int duration,
    required String category,
    required bool isActive,
  }) async {
    try {
      isLoadingServices.value = true;
      print('🔄 Updating service: $name');

      await ServiceApi.updateService(
        serviceId: serviceId,
        name: name,
        description: description,
        price: price,
        duration: duration,
        category: category,
        isActive: isActive,
      );

      await fetchServices();
      
      Get.back(); // Close the edit screen
      
      Get.snackbar(
        'Success',
        'Service updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22E6D3),
        colorText: Colors.black,
      );
    } catch (e) {
      print('❌ Error updating service: $e');
      Get.snackbar(
        'Error',
        'Failed to update service: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> deleteService({
    required int serviceId,
  }) async {
    try {
      isLoadingServices.value = true;
      print('🗑️ Deleting service ID: $serviceId');

      await ServiceApi.deleteService(serviceId: serviceId);
      
      servicesList.removeWhere((s) => s.id == serviceId);
      
      Get.back(); // Close the edit screen
      
      Get.snackbar(
        'Deleted',
        'Service removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22E6D3),
        colorText: Colors.black,
      );
    } catch (e) {
      print('❌ Error deleting service: $e');
      Get.snackbar(
        'Error',
        'Failed to delete service: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> toggleServiceStatus({
    required int serviceId,
    required bool isActive,
  }) async {
    try {
      print('🔄 Toggling service $serviceId status to: $isActive');

      final updatedService = await ServiceApi.toggleServiceStatus(
        serviceId: serviceId,
        isActive: isActive,
      );

      // Update in local list
      final index = servicesList.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        servicesList[index] = updatedService;
        servicesList.refresh();
      }

      print('✅ Service status toggled successfully');
    } catch (e) {
      print('❌ Error toggling service status: $e');
      rethrow;
    }
  }

  // =========================
  // BOOKINGS
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

  void updateBookingStatus(String id, String status) {
    final index = bookingsList.indexWhere((b) => b['id'] == id);
    if (index != -1) {
      bookingsList[index]['status'] = status;
      bookingsList.refresh();
    }
  }

  Future<void> deleteBooking(dynamic bookingId) async {
    try {
      bookingsList.removeWhere((b) => b['id'] == bookingId);
      Get.snackbar(
        'Deleted',
        'Booking deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete booking',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // STAFF
  // =========================

  void deleteStaff(dynamic staff) {
    employeesList.remove(staff);
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
  // INVENTORY
  // =========================

  void addInventory(Map<String, dynamic> item) {
    inventoryList.add(item);
  }

  void deleteInventory(String itemId) {
    inventoryList.removeWhere((i) => i['id'] == itemId);
  }

  // =========================
  // REVIEWS
  // =========================

  void deleteReview(String id) {
    reviewsList.removeWhere((r) => r['id'] == id);
  }

  // =========================
  // IMAGE UPLOAD (PLACEHOLDER)
  // =========================

  Future<String?> pickAndUploadImage({
    required bool fromCamera,
    int imageQuality = 80,
    String? pathPrefix,
  }) async {
    return null; // Implement later
  }

  // =========================
  // AUTH
  // =========================

  Future<void> logout() async {
    // Clear admin data
    salonProfile.value = null;
    activeSalonId.value = '';
    bookingsList.clear();
    employeesList.clear();
    servicesList.clear();

    // Clear auth token / firebase
    // await FirebaseAuth.instance.signOut();

    // Remove all screens & go to login
    Get.offAllNamed('/login');
  }
}