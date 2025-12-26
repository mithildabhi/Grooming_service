import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final category = 'Hair'.obs;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text("Add Service", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aiHint(),
            const SizedBox(height: 24),

            _sectionTitle("Service Details"),
            const SizedBox(height: 12),

            _input("Service Name", nameCtrl),
            _input("Price (₹)", priceCtrl),
            _input("Duration (minutes)", durationCtrl),
            _dropdown(category),
            _multiline("Description", descCtrl),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ctrl.addService(
                    token: "JWT_TOKEN",
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    duration: int.tryParse(durationCtrl.text) ?? 0,
                    category: category.value,
                  );
                },
                child: const Text(
                  "Save Service",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── UI PARTS ─────────

  Widget _aiHint() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      children: [
        Icon(Icons.psychology, color: accent),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            "AI suggests services under 30 mins get more bookings.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _input(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: _dec(label),
    ),
  );

  Widget _multiline(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: _dec(label),
    ),
  );

  Widget _dropdown(RxString value) => Obx(
    () => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Category: ${value.value}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        ],
      ),
    ),
  );

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}
