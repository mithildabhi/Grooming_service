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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        title: const Text(
          "Edit Service",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _field("Name", nameCtrl),
              _field("Description", descCtrl, maxLines: 3),
              _field("Price", priceCtrl),
              _field("Duration (min)", durationCtrl),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Save"),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  ctrl.deleteService(token: '', serviceId: service.id);
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
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
