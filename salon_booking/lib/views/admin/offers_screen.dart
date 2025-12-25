import 'package:flutter/material.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  static const _bg = Color(0xFF0B0F14);
  static const _card = Color(0xFF121A22);
  static const _accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: const BackButton(),
        title: const Text("AI Offer Generator"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔮 Predicted Slow Day
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.smart_toy, color: _accent),
                      SizedBox(width: 8),
                      Text(
                        "Predicted Slow Day: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Tuesday",
                        style: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "AI Insight: Bookings are down 40% for next Tuesday. "
                    "Suggested action: Launch a 15% flash sale for styling services.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Auto-Create Offer",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✨ AI Recommendations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "AI Recommendations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("View All", style: TextStyle(color: _accent)),
              ],
            ),
            const SizedBox(height: 12),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip("Smart Pick", active: true),
                  _chip("Low Retention"),
                  _chip("High Spend"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recommendation cards
            _recommendationCard(
              title: "Revive Dormant Clients",
              subtitle:
                  "Target: 50 clients inactive > 3 months with a personalized “We Miss You” offer.",
              tag: "High Impact",
              buttonText: "Customize Template",
            ),

            const SizedBox(height: 12),

            _recommendationCard(
              title: "Fill Tuesday Slots",
              subtitle:
                  "Target: Open slots next Tuesday. Boost occupancy with limited-time discounts.",
              tag: "Quick Win",
              buttonText: "Use Recommendation",
            ),

            const SizedBox(height: 24),

            // 🎯 Targeting Preview
            const Text(
              "Targeting Preview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Potential Reach",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _accent, width: 4),
                        ),
                        child: const Center(
                          child: Icon(Icons.people, color: _accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "142 Clients",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "+12% vs last campaign",
                    style: TextStyle(color: _accent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _miniStat(
                    icon: Icons.schedule,
                    title: "Best Send Time",
                    value: "Tue, 10:00 AM",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniStat(
                    icon: Icons.attach_money,
                    title: "Est. Revenue",
                    value: "\$1,200 – \$1,500",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 🚀 Generate CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "✨ Generate New Offer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────────

  Widget _cardBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _chip(String label, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? _accent.withOpacity(0.2) : _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _accent : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? _accent : Colors.white70,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _recommendationCard({
    required String title,
    required String subtitle,
    required String tag,
    required String buttonText,
  }) {
    return _cardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: () {}, child: Text(buttonText)),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return _cardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _accent),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
