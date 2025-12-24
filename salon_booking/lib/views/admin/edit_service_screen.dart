// lib/views/admin/edit_service_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class EditServiceScreen extends StatelessWidget {
  final Map<String, dynamic> service;
  const EditServiceScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    final nameCtrl = TextEditingController(text: service['name']);
    final priceCtrl = TextEditingController(text: service['price']);
    final durationCtrl = TextEditingController(text: service['duration']);
    final descCtrl = TextEditingController(text: service['description']);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Edit Service",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field("Service Name", nameCtrl),
            _field("Description", descCtrl, maxLines: 3),
            Row(
              children: [
                Expanded(child: _field("Price", priceCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field("Duration", durationCtrl)),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22E6D3),
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () {
                service['name'] = nameCtrl.text;
                service['price'] = priceCtrl.text;
                service['duration'] = durationCtrl.text;
                service['description'] = descCtrl.text;
                ctrl.servicesList.refresh();
                Get.back();
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ctrl.servicesList.remove(service);
                Get.back();
              },
              child: const Text(
                "Delete Service",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String l, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: l,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
