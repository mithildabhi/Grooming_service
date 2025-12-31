import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../controllers/booking_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AdminController>(AdminController());
    Get.put<BookingController>( BookingController());
  }
}