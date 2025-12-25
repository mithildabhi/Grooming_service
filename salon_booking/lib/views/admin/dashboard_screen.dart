import 'package:flutter/material.dart';
import 'package:salon_booking/widgets/ai_badge.dart';
import 'package:salon_booking/widgets/ai_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      appBar: AppBar(
        title: const Text("AI Command Center"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔮 AI Optimization Card
            AICard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF19F6E8)),
                      const SizedBox(width: 8),
                      const Text(
                        "AI Optimization",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                        onPressed: () {},
                        child: const Text("Details"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 Insight Metrics
            const Text(
              "Insight Metrics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _metricCard("Busy Prediction", "2pm – 5pm", "98% CONF"),
                _metricCard("Revenue Est.", "\$18.2k", "TREND"),
                _metricCard("Low Demand", "Tue Morning", "ALERT"),
                _metricCard("Churn Risk", "12 Clients", "RISK"),
              ],
            ),

            const SizedBox(height: 24),

            /// 📈 Booking Forecast
            AICard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Booking Forecast",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      aiBadge("AI Model v2.1"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E141B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("📊 Forecast Chart Placeholder"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🚨 Live Alerts
            AICard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inventory Low: Shampoos",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
            ),
          ],
        ),
      ),
    );
  }

  static Widget _metricCard(String title, String value, String tag) {
    return AICard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          aiBadge(tag),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
