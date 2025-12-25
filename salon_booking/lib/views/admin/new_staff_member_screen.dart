import 'package:flutter/material.dart';

class NewStaffMemberScreen extends StatelessWidget {
  const NewStaffMemberScreen({super.key});

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
          "Add Staff Member",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧠 AI SUGGESTION
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: accent),
                      SizedBox(width: 8),
                      Text(
                        "AI Hiring Suggestion",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Based on booking trends, hiring a part-time stylist "
                    "for weekends can reduce overload by 23%.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 👤 BASIC INFO
            _sectionTitle("Basic Information"),
            const SizedBox(height: 12),

            _inputField(label: "Full Name"),
            _inputField(label: "Email"),
            _inputField(label: "Phone Number"),

            const SizedBox(height: 20),

            // 🎭 ROLE & SKILLS
            _sectionTitle("Role & Skills"),
            const SizedBox(height: 12),

            _dropdownField(label: "Role", value: "Stylist"),
            _dropdownField(label: "Primary Skill", value: "Hair Styling"),

            const SizedBox(height: 20),

            // ⏰ WORKING HOURS
            _sectionTitle("Working Hours"),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _dayChip("Mon", active: true),
                _dayChip("Tue", active: true),
                _dayChip("Wed"),
                _dayChip("Thu"),
                _dayChip("Fri", active: true),
                _dayChip("Sat", active: true),
                _dayChip("Sun"),
              ],
            ),

            const SizedBox(height: 20),

            // 🤖 AI RECOMMENDATION
            _cardBox(
              child: Row(
                children: const [
                  Icon(Icons.lightbulb, color: accent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "AI recommends assigning Hair Styling and Beard Trim services.",
                      style: TextStyle(color: Colors.white70),
                    ),
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
                  "Save Staff Member",
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

  Widget _inputField({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$label: $value",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _dayChip(String label, {bool active = false}) {
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
