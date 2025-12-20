import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class StaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  const StaffCard({
    super.key,
    required this.staff,
    required Future<Null> Function() onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (staff['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
          ),
        ),
        title: Text(staff['name'] ?? ''),
        subtitle: Text(staff['position'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                /* open edit */
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ctrl.deleteStaff(staff['id']),
            ),
          ],
        ),
      ),
    );
  }
}
