import 'package:flutter/material.dart';

class AssignServicesScreen extends StatelessWidget {
  const AssignServicesScreen({super.key});

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
          "Assign Services",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧠 AI RECOMMENDATION
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: accent),
                      SizedBox(width: 8),
                      Text(
                        "AI Assignment Recommendation",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "AI suggests assigning Hair Styling and Beard Trim services "
                    "to Alex Johnson to balance workload and improve efficiency.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 👤 SELECT STAFF
            _sectionTitle("Select Staff"),
            const SizedBox(height: 12),

            _staffTile(
              name: "Alex Johnson",
              role: "Senior Stylist",
              selected: true,
            ),
            _staffTile(name: "Sarah Lee", role: "Hair Specialist"),
            _staffTile(name: "John Miller", role: "Beard Expert"),

            const SizedBox(height: 24),

            // ✂️ SELECT SERVICES
            _sectionTitle("Assign Services"),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _serviceChip("Hair Styling", active: true),
                _serviceChip("Beard Trim", active: true),
                _serviceChip("Facial"),
                _serviceChip("Spa Therapy"),
                _serviceChip("Hair Color"),
              ],
            ),

            const SizedBox(height: 24),

            // 📊 ASSIGNMENT SUMMARY
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Assignment Summary",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Staff: Alex Johnson\n"
                    "• Services: Hair Styling, Beard Trim\n"
                    "• Estimated Load: Balanced",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ✅ SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Save Assignment",
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

  Widget _staffTile({
    required String name,
    required String role,
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.15) : card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? accent : Colors.transparent),
        ),
        child: Row(
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
                  Text(role, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: accent),
          ],
        ),
      ),
    );
  }

  Widget _serviceChip(String label, {bool active = false}) {
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
}
