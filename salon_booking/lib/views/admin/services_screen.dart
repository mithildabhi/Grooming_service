import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/add_service_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

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
          "AI Service Performance",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Get.to(() => const AddServiceScreen());
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
                        "AI Service Insights",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Hair Styling and Spa services are trending this week. "
                    "Beard Trim shows a drop in satisfaction.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📊 PERFORMANCE STATS
            Row(
              children: const [
                Expanded(
                  child: _ServiceStat(
                    title: "Trending",
                    value: "3",
                    color: Colors.greenAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ServiceStat(
                    title: "Needs Attention",
                    value: "2",
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ServiceStat(
                    title: "Inactive",
                    value: "1",
                    color: Colors.redAccent,
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
                _filterChip("Trending"),
                _filterChip("Low Performance"),
                _filterChip("Inactive"),
              ],
            ),

            const SizedBox(height: 28),

            // ✂️ SERVICE LIST
            _sectionTitle("Services"),
            const SizedBox(height: 12),

            _serviceTile(
              name: "Hair Styling",
              duration: "45 mins",
              price: "\$30",
              performance: "Trending",
              performanceColor: Colors.greenAccent,
            ),

            _serviceTile(
              name: "Spa Therapy",
              duration: "60 mins",
              price: "\$50",
              performance: "Trending",
              performanceColor: Colors.greenAccent,
            ),

            _serviceTile(
              name: "Beard Trim",
              duration: "20 mins",
              price: "\$15",
              performance: "Needs Attention",
              performanceColor: Colors.orangeAccent,
            ),

            _serviceTile(
              name: "Facial",
              duration: "40 mins",
              price: "\$35",
              performance: "Inactive",
              performanceColor: Colors.redAccent,
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

  Widget _serviceTile({
    required String name,
    required String duration,
    required String price,
    required String performance,
    required Color performanceColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _cardBox(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: performanceColor.withOpacity(0.2),
              child: Icon(Icons.cut, color: performanceColor),
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
                  Text(
                    "$duration • $price",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: performanceColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                performance,
                style: TextStyle(
                  color: performanceColor,
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

class _ServiceStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ServiceStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ServicesScreen.card,
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
