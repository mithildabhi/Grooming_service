import 'package:get/get.dart';

import '../controllers/user_nav_controller.dart';
import '../controllers/user_home_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Core user data - only register if not already registered (registered in main.dart)
    if (!Get.isRegistered<UserController>()) {
      Get.put<UserController>(UserController(), permanent: true);
    }

    // Booking & appointments - only register if not already registered
    if (!Get.isRegistered<BookingController>()) {
      Get.put<BookingController>(BookingController(), permanent: true);
    }
    if (!Get.isRegistered<AppointmentController>()) {
      Get.put<AppointmentController>(AppointmentController(), permanent: true);
    }

    // Screens - only register if not already registered
    if (!Get.isRegistered<UserHomeController>()) {
      Get.put<UserHomeController>(UserHomeController(), permanent: true);
    }

    // Navigation (LAST) - only register if not already registered
    if (!Get.isRegistered<UserNavController>()) {
      Get.put<UserNavController>(UserNavController(), permanent: true);
    }
  }
}
