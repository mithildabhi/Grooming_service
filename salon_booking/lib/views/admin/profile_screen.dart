import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/employee_screen.dart';
import 'package:salon_booking/views/admin/services_screen.dart';
import 'package:salon_booking/views/admin/settings_screen.dart';
import '../../controllers/admin_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  @override
  void initState() {
    super.initState();
    // ✅ Load profile automatically when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminCtrl = Get.find<AdminController>();
      if (!adminCtrl.hasProfile && !adminCtrl.isLoadingProfile.value) {
        adminCtrl.loadSalonProfile();
      }
    });
  }

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
            onPressed: adminCtrl.openEditProfile,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: adminCtrl.loadSalonProfile,
          ),
        ],
      ),
      body: Obx(() {
        // ✅ Show loading indicator
        if (adminCtrl.isLoadingProfile.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        // ✅ ALWAYS show content with Quick Actions
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ✅ Profile Section (show if available)
              if (adminCtrl.hasProfile) ...[
                // Profile Image
                CircleAvatar(
                  radius: 48,
                  backgroundImage: adminCtrl.imageUrl.isNotEmpty
                      ? NetworkImage(adminCtrl.imageUrl)
                      : const NetworkImage("https://i.pravatar.cc/300"),
                ),
                const SizedBox(height: 12),

                Text(
                  adminCtrl.salonName,
                  style: const TextStyle(
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

                // Profile Info Cards
                _infoCard("Salon Name", adminCtrl.salonName),
                _infoCard("Email", adminCtrl.ownerEmail),
                _infoCard("Phone", adminCtrl.phone),
                _infoCard("Location", adminCtrl.location),

                const SizedBox(height: 24),

                _infoCard("Revenue", "₹4.2K / month"),
                _infoCard("Retention", "88%"),
                _infoCard("Inventory Alerts", "2 Low Stock"),

                const SizedBox(height: 32),
              ] else ...[
                // ✅ No Profile - Show Simple Message
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 64,
                        color: accent.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Salon Profile Yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your salon profile to unlock all features',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: adminCtrl.openEditProfile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // ✅ QUICK ACTIONS - ALWAYS VISIBLE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Quick Action Grid - ALWAYS VISIBLE
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
                    onTap: () => Get.to(() => const EmployeeScreen()),
                  ),
                  _actionCard(
                    icon: Icons.local_florist,
                    title: "Services",
                    onTap: () => Get.to(() => const ServicesScreen()),
                  ),
                  _actionCard(
                    icon: Icons.account_balance_wallet,
                    title: "Billing & Payouts",
                    onTap: () => Get.toNamed('/billing'),
                  ),
                  _actionCard(
                    icon: Icons.settings,
                    title: "App Settings",
                    onTap: () => Get.to(() => const SettingsScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ✅ LOGOUT BUTTON - ALWAYS VISIBLE
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
                            onPressed: () => Get.back(), // Close dialog
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Get.back(); // Close dialog first
                              
                              // ✅ Show loading indicator
                              Get.dialog(
                                const Center(
                                  child: CircularProgressIndicator(color: accent),
                                ),
                                barrierDismissible: false,
                              );
                              
                              // ✅ Call logout
                              await adminCtrl.logout();
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
        );
      }),
    );
  }

  // ════════════ HELPER WIDGETS ════════════
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