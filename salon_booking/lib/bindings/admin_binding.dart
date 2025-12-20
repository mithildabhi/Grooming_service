import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminController(), permanent: true);
  }
}
