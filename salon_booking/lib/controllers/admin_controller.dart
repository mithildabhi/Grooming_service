import 'package:get/get.dart';
import 'package:salon_booking/views/admin/edit_profile_screen.dart';
import '../models/booking_model.dart';
import '../models/salon_profile.dart';
import '../models/service_model.dart';
import '../services/service_api.dart';

class AdminController extends GetxController {
  // =========================
  // CORE
  // =========================

  final RxString activeSalonId = '1'.obs;
  final Rxn<SalonProfile> salonProfile = Rxn<SalonProfile>();
  final RxBool isLoadingServices = false.obs;

  // =========================
  // BOOKINGS (UI + USER)
  // =========================

  final RxList<Map<String, dynamic>> bookingsList =
      <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get todayBookings =>
      bookingsList.where((b) => b['status'] == 'created').toList();

  List<Map<String, dynamic>> get completedBookings =>
      bookingsList.where((b) => b['status'] == 'completed').toList();

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

  final RxList<Map<String, dynamic>> offersList = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> galleryList = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> reviewsList = <Map<String, dynamic>>[].obs;

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    filteredEmployees.assignAll(employeesList);
  }

  // =========================
  // SALON
  // =========================

  void setActiveSalon(String salonId) {
    activeSalonId.value = salonId;
  }

  // =========================
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

  Future<void> deleteBooking(String bookingId) async {
    bookingsList.removeWhere((b) => b['id'] == bookingId);
  }

  void updateBookingStatus(String id, String status) {
    final index = bookingsList.indexWhere((b) => b['id'] == id);
    if (index != -1) {
      bookingsList[index]['status'] = status;
      bookingsList.refresh();
    }
  }

  // =========================
  // INVENTORY
  // =========================

  Future<void> addInventory(Map<String, dynamic> item) async {
    inventoryList.add(item);
  }

  Future<void> deleteInventory(String id) async {
    inventoryList.removeWhere((i) => i['id'] == id);
  }

  // =========================
  // OFFERS
  // =========================

  Future<void> addOffer(Map<String, dynamic> offer) async {
    offersList.add(offer);
  }

  Future<void> deleteOffer(String id) async {
    offersList.removeWhere((o) => o['id'] == id);
  }

  // =========================
  // GALLERY
  // =========================

  Future<void> deleteGalleryImage(String id) async {
    galleryList.removeWhere((g) => g['id'] == id);
  }

  Future<void> pickAndUploadGalleryImage({required bool fromCamera}) async {
    // backend later
  }

  // =========================
  // REVIEWS
  // =========================

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
  // PROFILE
  // =========================

  Future<String?> pickAndUploadImage({
    required bool fromCamera,
    int imageQuality = 80,
    String? pathPrefix,
  }) async {
    return null;
  }

  Future<void> saveSalonProfile(SalonProfile profile) async {
    salonProfile.value = profile;
  }

  // =========================
  // AUTH
  // =========================

  // =========================
  // PROFILE NAVIGATION
  // =========================

  void startEditProfile() {
    Get.to(() => const EditProfileScreen());
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    try {
      // 🔐 later: call Django logout API if required

      // ❌ DO NOT delete controllers blindly here
      // Get.deleteAll(force: true);  // <- REMOVE this if you added it

      // ✅ Clear only admin-related state if needed
      activeSalonId.value = '';
      salonProfile.value = null;

      // 🚀 Navigate to login & remove all previous routes
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", "Logout failed");
    }
  }
}
