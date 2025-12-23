import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import 'dashboard_screen.dart';
import 'admin_bookings_screen.dart';
import 'employee_screen.dart';
import 'services_screen.dart';
import 'profile_screen.dart';

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
          backgroundColor: Color(0xFF0F1E1E),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF22E6D3)),
          ),
        );
      }

      final screens = [
        const AdminDashboardScreen(),
        AdminBookingsScreen(salonId: salonId),
        const EmployeeScreen(),
        const ServicesScreen(),
        ProfileScreen(),
      ];

      return Scaffold(
        backgroundColor: const Color(0xFF0F1E1E),
        body: IndexedStack(index: _index, children: screens),

        // ---------------- BOTTOM NAV ----------------
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F1E1E),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: const Color(0xFF0F1E1E),
            selectedItemColor: const Color(0xFF22E6D3),
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                label: 'Hub',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
              BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Services'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    });
  }
}
