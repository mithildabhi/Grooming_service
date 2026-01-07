import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/user/user_home_screen.dart';
import '../views/user/user_explore_screen.dart';
import '../views/user/user_appointments_screen.dart';
import '../views/user/user_ai_assistant_screen.dart';
import '../views/user/user_profile_screen.dart';

class UserNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  /// IMPORTANT:
  /// Pages must be LAZY and NOT created in onInit
  List<Widget> get pages => [
        const UserHomeScreen(),
        const UserExploreScreen(),
        const UserAppointmentsScreen(),
        const UserAIAssistantScreen(),
        const UserProfileScreen(),
      ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
