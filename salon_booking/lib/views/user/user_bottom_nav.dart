import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_nav_controller.dart';
import '../../theme/user_colors.dart';

class UserBottomNav extends StatelessWidget {
  const UserBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final UserNavController controller = Get.find();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: userCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  isSelected: controller.currentIndex.value == 0,
                  onTap: () => controller.changeIndex(0),
                ),
                _buildNavItem(
                  icon: Icons.search_rounded,
                  label: 'Explore',
                  index: 1,
                  isSelected: controller.currentIndex.value == 1,
                  onTap: () => controller.changeIndex(1),
                ),
                _buildNavItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Bookings',
                  index: 2,
                  isSelected: controller.currentIndex.value == 2,
                  onTap: () => controller.changeIndex(2),
                ),
                _buildNavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI',
                  index: 3,
                  isSelected: controller.currentIndex.value == 3,
                  onTap: () => controller.changeIndex(3),
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                  isSelected: controller.currentIndex.value == 4,
                  onTap: () => controller.changeIndex(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? userPrimary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected ? userPrimary : Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? userPrimary : Colors.grey.shade600,
                    letterSpacing: -0.2,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
