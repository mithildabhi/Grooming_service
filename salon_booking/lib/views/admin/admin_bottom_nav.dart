import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/admin_bookings_screen.dart';
import 'package:salon_booking/views/admin/dashboard_screen.dart';
import 'package:salon_booking/views/admin/employee_screen.dart';
import 'package:salon_booking/views/admin/profile_screen.dart';
import 'package:salon_booking/views/admin/services_screen.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  const AdminBottomNav({super.key, required this.currentIndex});

  // 🔒 ADMIN COLORS
  static const Color bg = Color(0xFF0B0F14);
  static const Color accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: bg,
        selectedItemColor: accent,
        unselectedItemColor: Colors.white54,
        enableFeedback: false,

        onTap: _onNavigate,

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
      ),
    );
  }

  // ───────────────────────── NAVIGATION ─────────────────────────

  void _onNavigate(int index) {
    if (index == currentIndex) return;

    final pages = [
      const DashboardScreen(),
      const AdminBookingsScreen(salonId: ''),
      const ServicesScreen(),
      const EmployeeScreen(),
      const ProfileScreen(),
    ];

    Get.off(
      pages[index],
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }
}
