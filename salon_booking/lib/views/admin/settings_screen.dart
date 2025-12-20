// lib/views/admin/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5F2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 10),

          //--------------------- ACCOUNT SETTINGS ---------------------
          _sectionTitle("Account Settings"),

          _settingsTile(
            icon: Icons.store,
            title: "Salon Profile",
            onTap: () => Get.toNamed("/admin/profile"),
          ),
          _settingsTile(
            icon: Icons.notifications_active,
            title: "Notification Settings",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.receipt_long,
            title: "Tax & Commission",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          //--------------------- APP SETTINGS ---------------------
          _sectionTitle("App Preferences"),

          _settingsTile(
            icon: Icons.color_lens_outlined,
            title: "Theme & Appearance",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.shield_outlined,
            title: "Privacy & Security",
            onTap: () {},
          ),

          const SizedBox(height: 40),

          //--------------------- LOGOUT BUTTON ---------------------
          ElevatedButton(
            onPressed: ctrl.logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  // ---------------- SETTINGS TILE ----------------
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.pink.shade50,
              child: Icon(icon, color: Colors.pinkAccent),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
