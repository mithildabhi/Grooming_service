import 'package:get/get.dart';

import '../controllers/user_nav_controller.dart';
import '../controllers/user_home_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Core user data
    Get.put<UserController>(UserController(), permanent: true);

    // Booking & appointments
    Get.put<BookingController>(BookingController(), permanent: true);
    Get.put<AppointmentController>(AppointmentController(), permanent: true);

    // Screens
    Get.put<UserHomeController>(UserHomeController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);

    // Navigation (LAST)
    Get.put<UserNavController>(UserNavController(), permanent: true);
  }
}
