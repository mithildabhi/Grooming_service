import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_nav_controller.dart';
import 'user_bottom_nav.dart';

class UserMainShell extends StatelessWidget {
  const UserMainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final UserNavController controller =
        Get.put(UserNavController(), permanent: true);

    return Obx(
      () => Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: controller.pages[controller.currentIndex.value],
        ),
        bottomNavigationBar: const UserBottomNav(),
      ),
    );
  }
}
