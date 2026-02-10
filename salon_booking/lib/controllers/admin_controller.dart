// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:salon_booking/controllers/auth_controller.dart';
import 'package:salon_booking/models/employee_model.dart';
import 'package:salon_booking/services/auth_service.dart';
import 'package:salon_booking/services/staff_api.dart';

import '../models/booking_model.dart';
import '../models/salon_profile.dart';
import '../models/service_model.dart';

import '../services/service_api.dart';
import '../services/salon_api_service.dart';
import '../widgets/custom_snackbar.dart';

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
// ✅ REPLACE ONLY THE onInit AND _initIfAdmin METHODS IN YOUR ADMIN_CONTROLLER.DART

@override
void onInit() {
  super.onInit();
  
  // ✅ No delay needed - initialize immediately
  _initIfAdmin();
}

Future<void> _initIfAdmin() async {
  try {
    // ✅ Check if AuthService is registered
    if (!Get.isRegistered<AuthService>()) {
      print('⚠️ AuthService not registered yet, skipping init');
      return;
    }

    final authService = Get.find<AuthService>();
    
    // ✅ Restore role from storage
    final role = await authService.restoreRole();

    print('🔍 AdminController: Role = $role');

    if (role != 'admin') {
      print('🟡 AdminController skipped (not admin)');
      return;
    }

    print('🟢 AdminController initializing (admin)');
    
    // ✅ Load data with proper error handling
    await Future.wait([
      loadSalonProfile().catchError((e) {
        print('⚠️ Profile load failed: $e');
      }),
      fetchServices().catchError((e) {
        print('⚠️ Services load failed: $e');
      }),
      fetchStaff().catchError((e) {
        print('⚠️ Staff load failed: $e');
      }),
    ]);
    
    print('✅ AdminController initialization complete');
    
  } catch (e) {
    print('❌ AdminController init error: $e');
  }
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
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to load salon profile',
        isError: true,
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

      CustomSnackbar.show(
        title: 'Success',
        message: 'Salon profile saved successfully',
        isSuccess: true,
      );

      // Return to previous screen
      Get.back();
    } catch (e) {
      print('❌ Error saving profile: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to save profile: $e',
        isError: true,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Open edit profile screen
  void openEditProfile() {
    Get.toNamed('/admin/edit-profile', arguments: salonProfile.value);
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
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to load services',
        isError: true,
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

      CustomSnackbar.show(
        title: 'Success',
        message: 'Service added successfully',
        isSuccess: true,
      );
    } catch (e) {
      print('❌ Error adding service: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to add service: $e',
        isError: true,
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

      CustomSnackbar.show(
        title: 'Success',
        message: 'Service updated successfully',
        isSuccess: true,
      );
    } catch (e) {
      print('❌ Error updating service: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to update service: $e',
        isError: true,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> deleteService({required int serviceId}) async {
    try {
      isLoadingServices.value = true;
      print('🗑️ Deleting service ID: $serviceId');

      await ServiceApi.deleteService(serviceId: serviceId);

      servicesList.removeWhere((s) => s.id == serviceId);

      Get.back(); // Close the edit screen

      CustomSnackbar.show(
        title: 'Deleted',
        message: 'Service removed successfully',
        isSuccess: true,
      );
    } catch (e) {
      print('❌ Error deleting service: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to delete service: $e',
        isError: true,
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
      CustomSnackbar.show(
        title: 'Deleted',
        message: 'Booking deleted successfully',
        isSuccess: true,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to delete booking',
        isError: true,
      );
    }
  }

  // =========================
  // STAFF
  // =========================
  final RxBool isLoadingStaff = false.obs;
  final RxList<EmployeeModel> staffList = <EmployeeModel>[].obs;

  Future<void> fetchStaff() async {
    try {
      isLoadingStaff.value = true;
      print('📥 Fetching staff...');
      staffList.assignAll(await StaffApi.fetchStaff());
      print('✅ Loaded ${staffList.length} staff members');
    } catch (e) {
      print('❌ Error fetching staff: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to load staff',
        isError: true,
      );
    } finally {
      isLoadingStaff.value = false;
    }
  }

  Future<void> addStaff({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String primarySkill,
    required List<String> workingDays,
    required bool isActive,
  }) async {
    try {
      isLoadingStaff.value = true;
      print('➕ Adding staff: $fullName');

      await StaffApi.createStaff(
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        primarySkill: primarySkill,
        workingDays: workingDays,
        isActive: isActive,
      );

      await fetchStaff();

      Get.back(); // Close the add screen

      CustomSnackbar.show(
        title: 'Success',
        message: 'Staff member added successfully',
        isSuccess: true,
      );
    } catch (e) {
      print('❌ Error adding staff: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to add staff: $e',
        isError: true,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingStaff.value = false;
    }
  }

  Future<void> updateStaff({
    required int staffId,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String primarySkill,
    required List<String> workingDays,
    required bool isActive,
  }) async {
    try {
      isLoadingStaff.value = true;
      print('🔄 Updating staff: $fullName');

      await StaffApi.updateStaff(
        staffId: staffId,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        primarySkill: primarySkill,
        workingDays: workingDays,
        isActive: isActive, // ← ADD THIS LINE
      );

      await fetchStaff();

      Get.back(); // Close the edit screen

      CustomSnackbar.show(
        title: 'Success',
        message: 'Staff member updated successfully',
        isSuccess: true,
      );
    } catch (e) {
      print('❌ Error updating staff: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to update staff: $e',
        isError: true,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingStaff.value = false;
    }
  }

  Future<void> deleteStaffMember({required int staffId}) async {
    try {
      isLoadingStaff.value = true;
      print('🗑️ Deleting staff ID: $staffId');

      await StaffApi.deleteStaff(staffId: staffId);

      staffList.removeWhere((s) => s.id == staffId);

      Get.back(); // Close the edit screen

      CustomSnackbar.show(
        title: 'Deleted',
        message: 'Staff member removed successfully',
        isSuccess: true,
      );
    } catch (e) {
      print('❌ Error deleting staff: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to delete staff: $e',
        isError: true,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    } finally {
      isLoadingStaff.value = false;
    }
  }

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
  // CLEAR ADMIN DATA (called by AuthController during centralized logout)
  // =========================
  void clearAdminData() {
    salonProfile.value = null;
    activeSalonId.value = '';
    bookingsList.clear();
    employeesList.clear();
    filteredEmployees.clear();
    servicesList.clear();
    staffList.clear();
    inventoryList.clear();
    galleryList.clear();
    reviewsList.clear();
    isLoadingServices.value = false;
    isLoadingProfile.value = false;
    isLoadingStaff.value = false;
    print('🧹 ADMIN: Admin data cleared');
  }

  // =========================
  // AUTH
  // =========================
  // Delegates to centralized AuthController.logout() which handles all cleanup
  Future<void> logout() async {
    try {
      print('👋 ADMIN: Logout requested, delegating to AuthController...');
      
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.logout();
      } else {
        // Fallback: clear own data and navigate
        clearAdminData();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('❌ ADMIN: Logout error: $e');
      Get.offAllNamed('/login');
    }
  }
}