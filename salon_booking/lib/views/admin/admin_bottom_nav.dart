import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmotion_navbar/glassmotion_navbar.dart';

import 'dashboard_screen.dart';
import 'admin_bookings_screen.dart';
import 'services_screen.dart';
import 'employee_screen.dart';
import 'profile_screen.dart';

class AdminBottomNav extends StatefulWidget {
  final int currentIndex;
  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  late int selected;

  static const adminItems = <GlassNavItem>[
    GlassNavItem(icon: Icons.home_rounded, label: 'Home'),
    GlassNavItem(icon: Icons.calendar_month_rounded, label: 'Bookings'),
    GlassNavItem(icon: Icons.cut_rounded, label: 'Services'),
    GlassNavItem(icon: Icons.people_rounded, label: 'Staff'),
    GlassNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GlassMotionNavBar(
      items: adminItems,
      selectedIndex: selected,
      onItemTapped: _onNavigate,

      onCenterTap: () {},

      accentColor: const Color(0xFF19F6E8),
      inactiveColor: Colors.white54,
      backgroundColor: Colors.black.withOpacity(0.08),
    );
  }

  // ───────────────── NAVIGATION ─────────────────

  void _onNavigate(int index) {
    if (index == selected) return;

    final pages = [
      const DashboardScreen(),
      const AdminBookingsScreen(salonId: ''),
      const ServicesScreen(),
      const EmployeeScreen(),
      const ProfileScreen(),
    ];

    setState(() => selected = index);

    Get.off(
      pages[index],
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }
}
