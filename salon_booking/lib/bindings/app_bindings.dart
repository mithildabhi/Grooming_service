import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/django_auth_service.dart';
import '../controllers/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(DjangoAuthService());
    Get.put(AuthController());
  }
}
