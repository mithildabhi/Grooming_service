import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_nav_controller.dart';
import '../../theme/user_colors.dart';
import 'user_bottom_nav.dart';

class UserMainShell extends StatelessWidget {
  const UserMainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final UserNavController controller =
        Get.put(UserNavController(), permanent: true);

    return Obx(
      () => Scaffold(
        backgroundColor: userBg,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),
        bottomNavigationBar: const UserBottomNav(),
      ),
    );
  }
}
