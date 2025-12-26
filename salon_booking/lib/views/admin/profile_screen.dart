import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/employee_screen.dart';
import 'package:salon_booking/views/admin/services_screen.dart';
import 'package:salon_booking/views/admin/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // THEME COLORS (LOCAL — SAFE)
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Admin Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Get.to(() => const SettingsScreen());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👤 PROFILE HEADER
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ],
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

            const SizedBox(height: 20),

            // 🤖 ASK AI
            _cardBox(
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, color: accent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ask AI: Create an offer for next Tuesday...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Icon(Icons.mic, color: accent),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📊 BUSINESS SNAPSHOT
            _sectionTitle("Business Snapshot"),
            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: _SnapshotCard(
                    title: "Revenue",
                    value: "\$4.2k",
                    footer: "+12%",
                    footerColor: Colors.greenAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SnapshotCard(
                    title: "Retention",
                    value: "88%",
                    footer: "AI",
                    footerColor: accent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SnapshotCard(
                    title: "Inventory",
                    value: "2 Low",
                    footer: "!",
                    footerColor: Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🧠 AI INSIGHT
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: accent),
                      SizedBox(width: 8),
                      Text(
                        "AI Insight",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tuesday afternoon demand is predicted to be low. "
                    "A 10% flash offer could improve occupancy.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🚨 SMART ALERTS
            _sectionTitle("Smart Alerts"),
            const SizedBox(height: 12),

            _alertTile(
              icon: Icons.inventory,
              title: "Low Stock",
              subtitle: "Argan Oil below 15%",
              color: Colors.redAccent,
            ),
            _alertTile(
              icon: Icons.event_busy,
              title: "Overbooking Risk",
              subtitle: "Friday 4 PM is congested",
              color: Colors.orangeAccent,
            ),

            const SizedBox(height: 24),

            // ⚡ QUICK ACTIONS
            _sectionTitle("Quick Actions"),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2, // 🔥 2 items per row
              shrinkWrap: true, // important inside scroll
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2, // card shape
              children: [
                _QuickAction(
                  icon: Icons.people,
                  label: "Staff",
                  onTap: () {
                    Get.to(() => const EmployeeScreen());
                  },
                ),
                _QuickAction(
                  icon: Icons.cut,
                  label: "Services",
                  onTap: () {
                    Get.to(() => const ServicesScreen());
                  },
                ),
                _QuickAction(
                  icon: Icons.payments,
                  label: "Billing",
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.settings,
                  label: "Settings",
                  onTap: () {
                    Get.to(() => const SettingsScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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

  Widget _alertTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _cardBox(
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────── SUB WIDGETS ─────────

class _SnapshotCard extends StatelessWidget {
  final String title;
  final String value;
  final String footer;
  final Color footerColor;

  const _SnapshotCard({
    required this.title,
    required this.value,
    required this.footer,
    required this.footerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProfileScreen.card,
        borderRadius: BorderRadius.circular(16),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(footer, style: TextStyle(color: footerColor)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: ProfileScreen.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ProfileScreen.accent, size: 26),
            const SizedBox(height: 10),
            Text(
              label,
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
