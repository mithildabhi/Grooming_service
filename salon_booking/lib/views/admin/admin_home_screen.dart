import 'package:flutter/material.dart';
import 'package:salon_booking/views/admin/admin_bottom_nav.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text("Welcome Admin", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),

      // ✅ THIS WAS MISSING
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }
}
