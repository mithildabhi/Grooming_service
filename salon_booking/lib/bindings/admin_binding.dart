import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../controllers/booking_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ AdminController already exists from main.dart, just ensure it's available
    if (!Get.isRegistered<AdminController>()) {
      Get.put<AdminController>(AdminController());
    }
    
    // ✅ Only initialize BookingController here
    Get.lazyPut<BookingController>(() => BookingController());
  }
}