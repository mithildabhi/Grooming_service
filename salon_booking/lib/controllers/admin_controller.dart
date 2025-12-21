import 'package:get/get.dart';
import '../models/booking_model.dart';
import '../models/salon_profile.dart';
import '../models/service_model.dart';

class AdminController extends GetxController {
  // =========================
  // CORE STATE
  // =========================

  final RxString activeSalonId = ''.obs;
  final Rxn<SalonProfile> salonProfile = Rxn<SalonProfile>();

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
  // SERVICES / OFFERS / INVENTORY / GALLERY / REVIEWS
  // =========================

  final RxList<Map<String, dynamic>> servicesList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> offersList = <Map<String, dynamic>>[].obs;
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

  // =========================
  // SALON
  // =========================

  void setActiveSalon(String salonId) {
    activeSalonId.value = salonId;
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

  Future<void> addEmployee(Map<String, dynamic> employee) async {
    employeesList.add(employee);
    filteredEmployees.assignAll(employeesList);
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

  // =========================
  // PROFILE
  // =========================

  Future<void> saveSalonProfile(SalonProfile profile) async {
    salonProfile.value = profile;
  }

  // =========================
  // REVIEWS
  // =========================

  Future<void> deleteReview(String reviewId) async {
    reviewsList.removeWhere((r) => r['id'] == reviewId);
  }

  // =========================
  // AUTH
  // =========================

  Future<void> logout() async {
    Get.snackbar("Logged out", "Session ended");
  }

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
