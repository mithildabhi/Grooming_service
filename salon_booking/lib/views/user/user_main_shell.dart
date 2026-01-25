import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmotion_navbar/glassmotion_navbar.dart';

import '../../theme/app_colors.dart';

import 'user_home_screen.dart';
import 'user_explore_screen.dart';
import 'user_appointments_screen.dart';
import 'user_ai_assistant_screen.dart';
import 'user_profile_screen.dart';

class UserMainShell extends StatefulWidget {
  const UserMainShell({super.key});

  @override
  State<UserMainShell> createState() => _UserMainShellState();
}

class _UserMainShellState extends State<UserMainShell> {
  int _currentIndex = 0;

  /// ✅ Reordered: Home, Explore, AI (center +), Appointments, Profile
  static const List<Widget> _pages = [
    UserHomeScreen(),
    UserExploreScreen(),
    UserAiAssistantScreen(),      // AI is now at index 2 (center)
    UserAppointmentsScreen(),     // Appointments moved to index 3
    UserProfileScreen(),
  ];

  static const List<GlassNavItem> _navItems = [
    GlassNavItem(icon: Icons.home_rounded, label: 'Home'),
    GlassNavItem(icon: Icons.search_rounded, label: 'Explore'),
    GlassNavItem(icon: Icons.auto_awesome_rounded, label: 'AI'),  // Center + button
    GlassNavItem(icon: Icons.calendar_month_rounded, label: 'Bookings'),
    GlassNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();

    /// ✅ Deep link support
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args['tab'] is int) {
        final tab = (args['tab'] as int).clamp(0, _pages.length - 1);
        if (mounted) {
          setState(() => _currentIndex = tab);
        }
      }
    });
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
        backgroundColor: AppColors.background,

        /// ✅ KEEP STATE ALIVE
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),

        /// ✅ GLASS NAVBAR with AI at center (+)
        bottomNavigationBar: GlassMotionNavBar(
          items: _navItems,
          selectedIndex: _currentIndex,
          onItemTapped: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
            }
          },

          onCenterTap: () {
            setState(() => _currentIndex = 2); // AI is now at index 2
          },

          accentColor: AppColors.primary,
          inactiveColor: Colors.white54,
          backgroundColor: Colors.black.withOpacity(0.08),
        ),
      ),
    );
  }
}
