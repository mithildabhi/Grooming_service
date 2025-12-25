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
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        title: const Text("Add New Service"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field("Service Name", nameCtrl),
            _field("Description", descCtrl, maxLines: 3),
            _field("Price", priceCtrl),
            _field("Duration (min)", durationCtrl),
            const SizedBox(height: 16),

            Obx(
              () => DropdownButtonFormField<String>(
                value: category.value,
                dropdownColor: Colors.black,
                items: const [
                  DropdownMenuItem(value: 'hair', child: Text("Hair")),
                  DropdownMenuItem(value: 'spa', child: Text("Spa")),
                  DropdownMenuItem(value: 'facial', child: Text("Facial")),
                  DropdownMenuItem(value: 'massage', child: Text("Massage")),
                ],
                onChanged: (v) => category.value = v!,
                decoration: _inputDecoration("Category"),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22E6D3),
                ),
                onPressed: () {
                  ctrl.addService(
                    token: "YOUR_JWT_TOKEN_HERE",
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    price: double.parse(priceCtrl.text),
                    duration: int.parse(durationCtrl.text),
                    category: category.value,
                  );
                },
                child: const Text(
                  "Save Service",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
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
