import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/ui/glass_card.dart';
import '../../theme/app_spacing.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Safe local colors
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
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧠 AI CONFIGURATION
            _sectionTitle("AI Configuration"),
            const SizedBox(height: 12),

            _cardBox(
              child: Column(
                children: [
                  _toggleTile(
                    icon: Icons.smart_toy,
                    title: "Enable AI Insights",
                    subtitle: "Show predictions and recommendations",
                    value: true,
                  ),
                  _divider(),
                  _toggleTile(
                    icon: Icons.analytics,
                    title: "Demand Forecasting",
                    subtitle: "Predict bookings and busy hours",
                    value: true,
                  ),
                  _divider(),
                  _toggleTile(
                    icon: Icons.person_search,
                    title: "Customer Behavior Analysis",
                    subtitle: "Detect churn and loyalty trends",
                    value: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🏢 SALON SETTINGS
            _sectionTitle("Salon Settings"),
            const SizedBox(height: 12),

            _cardBox(
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.store,
                    title: "Salon Profile",
                    subtitle: "Name, address, working hours",
                    onPressed: () {},
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.receipt_long,
                    title: "Business Policies",
                    subtitle: "Taxes, commission, cancellation",
                    onPressed: () {},
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.payment,
                    title: "Payment Settings",
                    subtitle: "UPI, card, bank accounts",
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔔 NOTIFICATIONS
            _sectionTitle("Notifications"),
            const SizedBox(height: 12),

            _cardBox(
              child: Column(
                children: [
                  _toggleTile(
                    icon: Icons.notifications_active,
                    title: "Push Notifications",
                    subtitle: "Booking and payment alerts",
                    value: true,
                  ),
                  _divider(),
                  _toggleTile(
                    icon: Icons.email,
                    title: "Email Notifications",
                    subtitle: "Reports and summaries",
                    value: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔐 SECURITY
            _sectionTitle("Security"),
            const SizedBox(height: 12),

            _cardBox(
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.lock,
                    title: "Change Password",
                    subtitle: "Update admin password",
                    onPressed: () {},
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.logout,
                    title: "Logout",
                    subtitle: "Sign out from admin panel",
                    danger: true,
                    onPressed: () {
                      Get.dialog(
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: GlassCard(
                              color: card,
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      color: Colors.redAccent,
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  const Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    "Are you sure you want to logout?",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Get.back(),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white70,
                                            side: const BorderSide(
                                              color: Colors.white24,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text("Cancel"),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                            adminCtrl.logout();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text("Logout"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _cardBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _divider() {
    return const Divider(color: Colors.white12, height: 24);
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: accent.withOpacity(0.2),
          child: Icon(icon, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        Switch(value: value, activeColor: accent, onChanged: (_) {}),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool danger = false,
    required VoidCallback onPressed,
  }) {
    final Color color = danger ? Colors.redAccent : accent;

    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: danger ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}
