import 'package:flutter/material.dart';
import 'admin_home_screen.dart';

/// DEPRECATED: This screen has been merged into AdminHomeScreen
/// This file now redirects to the new merged dashboard
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new merged dashboard
    return const AdminHomeScreen();
  }
}
