import 'package:get/get.dart';
import 'package:salon_booking/views/user/user_appointments_screen.dart';
import 'package:salon_booking/views/user/user_explore_screen.dart';
import 'package:salon_booking/views/user/user_home_screen.dart';
import 'package:salon_booking/views/user/user_profile_screen.dart';


class UserNavController extends GetxController {
  final currentIndex = 0.obs;

  final pages = const [
    UserHomeScreen(),
    UserExploreScreen(),
    UserAppointmentsScreen(),
    UserProfileScreen(),
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
