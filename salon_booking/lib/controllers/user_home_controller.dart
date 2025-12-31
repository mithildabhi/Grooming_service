import 'package:get/get.dart';

class UserHomeController extends GetxController {
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHome();
  }

  Future<void> _loadHome() async {
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }
}
