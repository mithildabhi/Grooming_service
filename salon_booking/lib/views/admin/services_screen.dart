// lib/views/admin/services_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
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
        elevation: 0,
        leading: const BackButton(color: Colors.white),

        title: const Text(
          "Services",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),

      body: Obx(() {
        final services = ctrl.servicesList;

        if (services.isEmpty) {
          return const Center(
            child: Text(
              "No services added",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final service = services[i];
            return _ServiceTile(
              service: service,
              onTap: () {
                Get.to(() => EditServiceScreen(service: service));
              },
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF22E6D3),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Service", style: TextStyle(color: Colors.black)),
        onPressed: () => Get.to(() => const AddServiceScreen()),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF162B2B),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF22E6D3),
              child: const Icon(Icons.cut, color: Colors.black),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${service['price']} • ${service['duration']} mins",
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
