import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxString name = 'John Doe'.obs;
  final RxString email = 'john@example.com'.obs;

  void logout() {
    // handled by auth controller
  }
}
