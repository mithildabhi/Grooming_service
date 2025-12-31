import 'package:get/get.dart';

import '../controllers/user_nav_controller.dart';
import '../controllers/user_home_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/profile_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserNavController(), permanent: true);
    Get.put(UserHomeController(), permanent: true);
    Get.put(BookingController(), permanent: true);
    Get.put(AppointmentController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}
