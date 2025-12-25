import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final ctrl = Get.find<AdminController>();

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final durationCtrl = TextEditingController(text: "45");

  final category = 'hair'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ keyboard fix
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        title: const Text(
          "Add New Service",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field("Service Name", nameCtrl),
              _field("Description", descCtrl, maxLines: 3),
              _field("Price", priceCtrl, keyboard: TextInputType.number),
              _field(
                "Duration (min)",
                durationCtrl,
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 16),

              /// CATEGORY DROPDOWN (FIXED TEXT COLOR)
              Obx(
                () => DropdownButtonFormField<String>(
                  value: category.value,
                  dropdownColor: const Color(0xFF1E3535),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'hair',
                      child: Text(
                        "Hair",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'spa',
                      child: Text("Spa", style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'facial',
                      child: Text(
                        "Facial",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'massage',
                      child: Text(
                        "Massage",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (v) => category.value = v!,
                  decoration: _inputDecoration("Category"),
                ),
              ),

              const SizedBox(height: 28),

              /// SAVE BUTTON
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22E6D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ctrl.addService(
                      token: "YOUR_JWT_TOKEN_HERE",
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      price: double.tryParse(priceCtrl.text) ?? 0,
                      duration: int.tryParse(durationCtrl.text) ?? 0,
                      category: category.value,
                    );
                  },
                  child: const Text(
                    "Save Service",
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
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        cursorColor: Colors.white, // ✅ cursor visible
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white10,
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
