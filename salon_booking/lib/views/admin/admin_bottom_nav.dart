import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_routes.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF111827),
      selectedItemColor: const Color(0xFF19F6E8),
      unselectedItemColor: Colors.white54,

      onTap: (index) {
        switch (index) {
          case 0:
            Get.offNamed(AppRoutes.adminDashboard);
            break;
          case 1:
            Get.offNamed(AppRoutes.adminBookings);
            break;
          case 2:
            Get.offNamed(AppRoutes.adminServices);
            break;
          case 3:
            Get.offNamed(AppRoutes.adminEmployees);
            break;
          case 4:
            Get.offNamed(AppRoutes.adminProfile);
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.cut), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
