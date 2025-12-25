import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

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
          "AI Visual Performance",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧠 VISUAL INSIGHT
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.visibility, color: accent),
                      SizedBox(width: 8),
                      Text(
                        "AI Visual Insight",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Images with brighter lighting and close-up angles "
                    "generate 32% more engagement. Consider reordering your gallery.",
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
                  child: _VisualStat(
                    title: "Engagement",
                    value: "+32%",
                    color: Colors.greenAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _VisualStat(
                    title: "Click Rate",
                    value: "18%",
                    color: accent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _VisualStat(
                    title: "Low Performers",
                    value: "4",
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 🖼 GALLERY GRID (SAFE)
            _sectionTitle("Gallery Performance"),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _imageCard("Hair Styling", "High", Colors.greenAccent),
                _imageCard("Beard Trim", "Medium", Colors.amberAccent),
                _imageCard("Facial", "Low", Colors.redAccent),
                _imageCard("Spa Therapy", "High", Colors.greenAccent),
                _imageCard("Hair Color", "Medium", Colors.amberAccent),
                _imageCard("Bridal Look", "High", Colors.greenAccent),
              ],
            ),

            const SizedBox(height: 28),

            // 🧠 AI RECOMMENDATIONS
            _sectionTitle("AI Recommendations"),
            const SizedBox(height: 12),

            _recommendationTile(
              icon: Icons.trending_up,
              title: "Promote High Performers",
              subtitle:
                  "Move high-engagement images to the top of your gallery.",
              color: Colors.greenAccent,
            ),

            _recommendationTile(
              icon: Icons.photo_filter,
              title: "Improve Low Performers",
              subtitle:
                  "Replace low-performing images with brighter, close-up shots.",
              color: Colors.orangeAccent,
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

  Widget _imageCard(String title, String status, Color statusColor) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image, color: Colors.white38, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text("Performance: $status", style: TextStyle(color: statusColor)),
        ],
      ),
    );
  }

  Widget _recommendationTile({
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

// ───────── SUB WIDGET ─────────

class _VisualStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _VisualStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GalleryScreen.card,
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
