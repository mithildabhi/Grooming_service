import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  const ServiceCard({
    super.key,
    required this.service,
    required Future<Null> Function() onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: service['image'] != null && service['image'] != ''
            ? Image.network(
                service['image'],
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.cut),
        title: Text(service['name'] ?? ''),
        subtitle: Text(
          '₹${service['price'] ?? 0} • ${service['durationMinutes'] ?? 30} min',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                /* you'll open edit dialog from services screen */
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ctrl.deleteService(service['id']),
            ),
          ],
        ),
      ),
    );
  }
}
