import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'admin_bookings_screen.dart';
import 'services_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(),
      AdminBookingsScreen(salonId: '1'), // ✅ safe default
      ServicesScreen(),
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

        // ✅ NO REFRESH, NO REBUILD
        body: IndexedStack(index: _currentIndex, children: _pages),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF111827),
          selectedItemColor: const Color(0xFF19F6E8),
          unselectedItemColor: Colors.white54,

          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
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
        ),
      ),
    );
  }
}
