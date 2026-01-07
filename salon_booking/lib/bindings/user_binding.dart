import 'package:get/get.dart';

import '../controllers/user_nav_controller.dart';
import '../controllers/user_home_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/profile_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Controllers USED by screens FIRST
    Get.put<BookingController>(BookingController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
    Get.put<UserHomeController>(UserHomeController(), permanent: true);

    // ✅ Navigation controller LAST
    Get.put<UserNavController>(UserNavController(), permanent: true);
  }
}
