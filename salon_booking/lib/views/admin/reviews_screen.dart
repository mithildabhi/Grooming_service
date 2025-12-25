import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  // Local safe colors
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
          "AI Reviews Analysis",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧠 SENTIMENT OVERVIEW
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: accent),
                      SizedBox(width: 8),
                      Text(
                        "Sentiment Overview",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Overall customer sentiment is strongly positive. "
                    "AI detected high satisfaction in recent grooming services.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📊 SENTIMENT STATS
            Row(
              children: const [
                Expanded(
                  child: _SentimentStat(
                    label: "Positive",
                    value: "72%",
                    color: Colors.greenAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SentimentStat(
                    label: "Neutral",
                    value: "18%",
                    color: Colors.amberAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SentimentStat(
                    label: "Negative",
                    value: "10%",
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 🔍 AI INSIGHTS
            _sectionTitle("AI Insights"),
            const SizedBox(height: 12),

            _insightTile(
              icon: Icons.star,
              title: "Top Performing Service",
              subtitle: "Hair Styling – highest positive feedback",
              color: Colors.greenAccent,
            ),

            _insightTile(
              icon: Icons.warning,
              title: "Service Needing Attention",
              subtitle: "Beard Trim – slow service complaints detected",
              color: Colors.orangeAccent,
            ),

            const SizedBox(height: 28),

            // 📝 RECENT REVIEWS
            _sectionTitle("Recent Reviews"),
            const SizedBox(height: 12),

            _reviewCard(
              name: "Rohit Sharma",
              service: "Haircut",
              review:
                  "Amazing service! The stylist was very professional and friendly.",
              sentiment: "Positive",
              sentimentColor: Colors.greenAccent,
            ),

            _reviewCard(
              name: "Amit Patel",
              service: "Beard Trim",
              review: "Service was okay but took longer than expected.",
              sentiment: "Neutral",
              sentimentColor: Colors.amberAccent,
            ),

            _reviewCard(
              name: "Neha Verma",
              service: "Facial",
              review:
                  "Not satisfied with the results. Room cleanliness can improve.",
              sentiment: "Negative",
              sentimentColor: Colors.redAccent,
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

  Widget _insightTile({
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

  Widget _reviewCard({
    required String name,
    required String service,
    required String review,
    required String sentiment,
    required Color sentimentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _cardBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent.withOpacity(0.2),
                  child: const Icon(Icons.person, color: accent),
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
                        service,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sentimentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sentiment,
                    style: TextStyle(
                      color: sentimentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(review, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ───────── SUB WIDGET ─────────

class _SentimentStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SentimentStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ReviewsScreen.card,
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
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
