import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),
            const SizedBox(height: 24),

            _input("Full Name", "Sarah Jenkins"),
            _input("Email", "sarah@salon.com"),
            _input("Phone", "+91 98765 43210"),
            _input("Salon Name", "Glow Studio"),
            _input("Location", "Ahmedabad"),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // 🔗 Django API later
                  Get.back();
                  Get.snackbar("Saved", "Profile updated");
                },
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        initialValue: value,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
