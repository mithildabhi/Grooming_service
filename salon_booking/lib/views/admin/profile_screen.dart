import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/employee_screen.dart';
import 'package:salon_booking/views/admin/services_screen.dart';
import 'package:salon_booking/views/admin/settings_screen.dart';
import '../../controllers/admin_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    final AdminController adminCtrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Admin Profile",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: adminCtrl.startEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 PROFILE IMAGE
            const CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),
            const SizedBox(height: 12),

            const Text(
              "Sarah Jenkins",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Salon Owner • AI Active",
              style: TextStyle(color: accent),
            ),

            const SizedBox(height: 24),

            _infoCard("Salon Name", "Glow Studio"),
            _infoCard("Email", "sarah@salon.com"),
            _infoCard("Phone", "+91 98765 43210"),
            _infoCard("Location", "Ahmedabad, India"),

            const SizedBox(height: 24),

            _infoCard("Revenue", "₹4.2K / month"),
            _infoCard("Retention", "88%"),
            _infoCard("Inventory Alerts", "2 Low Stock"),

            const SizedBox(height: 32),

            // ⚡ QUICK ACTIONS TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Quick Actions",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _actionCard(
                  icon: Icons.people,
                  title: "Staff Management",
                  onTap: () => Get.to(EmployeeScreen()),
                ),
                _actionCard(
                  icon: Icons.local_florist,
                  title: "Services",
                  onTap: () => Get.to(ServicesScreen()),
                ),
                _actionCard(
                  icon: Icons.account_balance_wallet,
                  title: "Billing & Payouts",
                  onTap: () => Get.toNamed('/billing'),
                ),
                _actionCard(
                  icon: Icons.settings,
                  title: "App Settings",
                  onTap: () => Get.to(SettingsScreen()),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 🚪 LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: card,
                      title: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        "Are you sure you want to logout?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: Get.back,
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            adminCtrl.logout();
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── HELPER WIDGET ─────────
  Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accent, size: 30),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
