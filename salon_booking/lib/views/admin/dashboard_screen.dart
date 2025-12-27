import 'package:flutter/material.dart';
import 'package:salon_booking/widgets/ai_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // 🔒 ADMIN COLOR SYSTEM (SAME AS BOOKINGS)
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
          "Dashboard Screen",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔮 AI Optimization Card
            _aiOptimizationCard(),

            const SizedBox(height: 20),

            /// 📊 Insight Metrics
            const Text(
              "Insight Metrics",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: const [
                _MetricCard("Busy Prediction", "2pm – 5pm", "98% CONF"),
                _MetricCard("Revenue Est.", "\$18.2k", "TREND"),
                _MetricCard("Low Demand", "Tue Morning", "ALERT"),
                _MetricCard("Churn Risk", "12 Clients", "RISK"),
              ],
            ),

            const SizedBox(height: 24),

            /// 📈 Booking Forecast
            _forecastCard(),

            const SizedBox(height: 24),

            /// 🚨 Live Alerts
            _alertCard(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── CARDS ─────────────────────────

  Widget _aiOptimizationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: accent),
              const SizedBox(width: 8),
              const Text(
                "AI Optimization",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              aiBadge("BETA v2.4"),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Friday afternoons are understaffed. Adding 1 stylist could increase revenue by 15%.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                child: const Text("Apply"),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: () {},
                child: const Text("Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _forecastCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Booking Forecast",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              aiBadge("AI Model v2.1"),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "📊 Forecast Chart Placeholder",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Inventory Low: Shampoos",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "AI detected stock below 10%. Auto-reorder recommended.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: () {},
                child: const Text("Dismiss"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {},
                child: const Text("Reorder"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── METRIC CARD ─────────────────────────

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String tag;

  const _MetricCard(this.title, this.value, this.tag);

  static const Color card = Color(0xFF121A22);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          aiBadge(tag),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
