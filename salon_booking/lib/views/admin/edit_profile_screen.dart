import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  // Same admin colors
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    Get.find<AdminController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 PROFILE PHOTO
            _cardBox(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 46,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: accent, size: 18),
                    label: const Text(
                      "Change Photo",
                      style: TextStyle(color: accent),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🧾 BASIC INFO
            _sectionTitle("Basic Information"),
            const SizedBox(height: 12),

            _inputField(label: "Full Name", value: "Sarah Jenkins"),
            _inputField(label: "Email", value: "sarah@salon.com"),
            _inputField(label: "Phone Number", value: "+91 98765 43210"),

            const SizedBox(height: 20),

            // 🏢 SALON INFO
            _sectionTitle("Salon Information"),
            const SizedBox(height: 12),

            _inputField(label: "Salon Name", value: "Glow Studio"),
            _inputField(label: "Location", value: "Ahmedabad"),

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
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    "Saved",
                    "Profile updated successfully",
                    backgroundColor: card,
                    colorText: Colors.white,
                  );
                },
                child: const Text(
                  "Save Changes",
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

  // ───────── UI HELPERS (SAME AS NewStaffMemberScreen) ─────────

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

  Widget _inputField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
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
}
