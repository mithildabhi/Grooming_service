import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_nav_controller.dart';

class UserBottomNav extends StatelessWidget {
  const UserBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final UserNavController controller = Get.find();

    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
