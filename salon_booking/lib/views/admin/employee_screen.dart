import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:salon_booking/views/admin/new_staff_member_screen.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  // Safe local colors
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
          "AI Staff Intelligence",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Get.to(() => const NewStaffMemberScreen());
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧠 AI OVERVIEW
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: accent),
                      SizedBox(width: 8),
                      Text(
                        "AI Staff Insights",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Alex and Sarah are top performers this week. "
                    "John shows signs of overload on Friday evenings.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📊 STAFF STATS
            Row(
              children: const [
                Expanded(
                  child: _StaffStat(
                    title: "Top Performers",
                    value: "2",
                    color: Colors.greenAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StaffStat(
                    title: "Overloaded",
                    value: "1",
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StaffStat(
                    title: "Available",
                    value: "4",
                    color: accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 🔎 FILTERS
            _sectionTitle("Filters"),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _filterChip("All", active: true),
                _filterChip("Top Performer"),
                _filterChip("Overloaded"),
                _filterChip("Available"),
              ],
            ),

            const SizedBox(height: 28),

            // 👨‍🔧 STAFF LIST
            _sectionTitle("Staff Members"),
            const SizedBox(height: 12),

            _staffTile(
              name: "Alex Johnson",
              role: "Senior Stylist",
              score: "92%",
              tag: "Top Performer",
              tagColor: Colors.greenAccent,
            ),

            _staffTile(
              name: "Sarah Lee",
              role: "Hair Specialist",
              score: "89%",
              tag: "Top Performer",
              tagColor: Colors.greenAccent,
            ),

            _staffTile(
              name: "John Miller",
              role: "Beard Expert",
              score: "68%",
              tag: "Overloaded",
              tagColor: Colors.orangeAccent,
            ),

            _staffTile(
              name: "Emily Davis",
              role: "Junior Stylist",
              score: "Available",
              tag: "Available",
              tagColor: accent,
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

  Widget _filterChip(String label, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? accent.withOpacity(0.2) : card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? accent : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? accent : Colors.white70,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _staffTile({
    required String name,
    required String role,
    required String score,
    required String tag,
    required Color tagColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _cardBox(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: tagColor.withOpacity(0.2),
              child: Icon(Icons.person, color: tagColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(role, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    "Performance: $score",
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: tagColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────── SUB WIDGET ─────────

class _StaffStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StaffStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EmployeeScreen.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
