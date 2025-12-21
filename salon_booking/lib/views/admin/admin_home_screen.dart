// lib/views/admin/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/profile_screen.dart';
import '../../controllers/admin_controller.dart';
import 'dashboard_screen.dart';
import 'admin_bookings_screen.dart';
import 'employee_screen.dart';
import 'services_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;
  late final AdminController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<AdminController>();
  }

@override
Widget build(BuildContext context) {
  return Obx(() {
    final salonId = ctrl.activeSalonId.value;

    if (salonId.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      const DashboardScreen(),
      AdminBookingsScreen(salonId: salonId),
      EmployeesScreen(),
      const ServicesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  });
}
}