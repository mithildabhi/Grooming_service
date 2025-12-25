import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/service_model.dart';

class EditServiceScreen extends StatelessWidget {
  final ServiceModel service;

  const EditServiceScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    final nameCtrl = TextEditingController(text: service.name);
    final priceCtrl = TextEditingController(text: service.price.toString());
    final durationCtrl = TextEditingController(
      text: service.duration.toString(),
    );
    final descCtrl = TextEditingController(text: service.description);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        title: const Text("Edit Service"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field("Name", nameCtrl),
            _field("Description", descCtrl),
            _field("Price", priceCtrl),
            _field("Duration (min)", durationCtrl),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // UI only — backend update can be added later
                Get.back();
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                ctrl.deleteService(token: '', serviceId: service.id);
                Get.back();
              },
              child: const Text(
                "Delete Service",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
