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

  void openEditProfile() {
    Get.toNamed('/edit-profile');
  }

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

      final profile = await SalonApiService.getMyProfile();

      if (profile != null) {
        salonProfile.value = profile;
        activeSalonId.value = profile.id;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load salon profile');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Create OR overwrite salon profile
  Future<void> saveSalonProfile(SalonProfile profile) async {
    try {
      isLoadingProfile.value = true;

      final savedProfile = await SalonApiService.saveProfile(profile);

      salonProfile.value = savedProfile;
      activeSalonId.value = savedProfile.id;

      Get.snackbar(
        'Success',
        'Salon profile saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22E6D3),
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // =========================
  // SERVICES (DJANGO)
  // =========================

  Future<void> fetchServices() async {
    try {
      isLoadingServices.value = true;
      servicesList.assignAll(await ServiceApi.fetchServices());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services');
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
    Get.snackbar('Success', 'Service added');
  }

  Future<void> deleteService({
    required String token,
    required int serviceId,
  }) async {
    await ServiceApi.deleteService(token: token, serviceId: serviceId);
    servicesList.removeWhere((s) => s.id == serviceId);
    Get.snackbar('Deleted', 'Service removed');
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
    // OPTIONAL: clear admin data
    salonProfile.value = null;
    activeSalonId.value = '';
    bookingsList.clear();
    employeesList.clear();
    servicesList.clear();

    // OPTIONAL: clear auth token / firebase later
    // await FirebaseAuth.instance.signOut();

    // ✅ REMOVE ALL SCREENS & GO TO LOGIN
    Get.offAllNamed('/login');
  }

  // =========================
  // DELETE BOOKING
  // =========================
  Future<void> deleteBooking(dynamic bookingId) async {
    try {
      // Optional: call backend later
      // await SalonApiService.deleteBooking(bookingId.toString());

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
}
