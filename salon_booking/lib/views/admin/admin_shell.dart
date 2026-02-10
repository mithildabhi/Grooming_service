import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmotion_navbar/glassmotion_navbar.dart';

import 'admin_home_screen.dart';
import 'admin_bookings_screen.dart';
import 'chatbot_screen.dart';
import 'employee_screen.dart';
import 'profile_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  static const _navItems = <GlassNavItem>[
    GlassNavItem(icon: Icons.home_rounded, label: 'Home'),
    GlassNavItem(icon: Icons.calendar_month_rounded, label: 'Bookings'),
    GlassNavItem(
      icon: Icons.psychology_rounded,
      label: 'AI Assistant',
    ), // Changed from Services
    GlassNavItem(icon: Icons.people_rounded, label: 'Staff'),
    GlassNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminHomeScreen(),
      AdminBookingsScreen(),
      SizedBox(),
      EmployeeScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F14),

        // ✅ NO REBUILD
        body: IndexedStack(index: _currentIndex, children: _pages),

        bottomNavigationBar: GlassMotionNavBar(
          items: _navItems,
          selectedIndex: _currentIndex,
          onItemTapped: (index) {
            if (index == 2) {
              Get.to(() => const ChatbotScreen());
              return;
            }
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
            }
          },

          // Center tap can still do something else if needed
          onCenterTap: () {
            // Open chatbot on center tap too
            Get.to(() => const ChatbotScreen());
          },

          accentColor: const Color(0xFF19F6E8),
          inactiveColor: Colors.white54,
          backgroundColor: Colors.black.withOpacity(0.08),
        ),
      ),
    );
  }
}
