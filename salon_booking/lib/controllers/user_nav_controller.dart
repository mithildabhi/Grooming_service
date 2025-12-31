import 'package:get/get.dart';

import '../views/user/user_home_screen.dart';
import '../views/user/user_explore_screen.dart';
import '../views/user/user_appointments_screen.dart';
import '../views/user/user_ai_assistant_screen.dart';
import '../views/user/user_profile_screen.dart';

class UserNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final pages = const [
    UserHomeScreen(),
    UserExploreScreen(),
    UserAppointmentsScreen(),
    UserAIAssistantScreen(),
    UserProfileScreen(),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
