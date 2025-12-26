import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';
import '../controllers/admin_controller.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Card(
      child: ListTile(
        title: Text(service.name),
        subtitle: Text("₹${service.price} • ${service.duration} min"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => ctrl.deleteService(token: "", serviceId: service.id),
        ),
      ),
    );
  }
}
