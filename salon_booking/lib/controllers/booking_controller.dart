import 'package:get/get.dart';

class BookingController extends GetxController {
  final RxString selectedDate = ''.obs;
  final RxString selectedTime = ''.obs;
  final RxString selectedService = ''.obs;

  void clear() {
    selectedDate.value = '';
    selectedTime.value = '';
    selectedService.value = '';
  }
}
