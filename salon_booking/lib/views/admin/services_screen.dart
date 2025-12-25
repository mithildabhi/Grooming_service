// lib/views/admin/services_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/service_model.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        title: const Text("Services", style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (ctrl.isLoadingServices.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.servicesList.isEmpty) {
          return const Center(child: Text("No services"));
        }

        return ListView.builder(
          itemCount: ctrl.servicesList.length,
          itemBuilder: (_, i) {
            final ServiceModel service = ctrl.servicesList[i];
            return ListTile(
              title: Text(
                service.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "₹${service.price} • ${service.duration} min",
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () =>
                    Get.to(() => EditServiceScreen(service: service)),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddServiceScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
