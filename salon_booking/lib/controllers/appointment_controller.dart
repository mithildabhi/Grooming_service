import 'package:get/get.dart';

class AppointmentController extends GetxController {
  final RxList<Map<String, dynamic>> appointments =
      <Map<String, dynamic>>[].obs;

  void loadAppointments() {
    appointments.assignAll([
      {
        'salonName': 'Luxe Studio & Spa',
        'serviceName': 'Haircut',
        'date': '24 Oct 2025',
        'time': '05:30 PM',
        'completed': false,
      },
    ]);
  }
}
