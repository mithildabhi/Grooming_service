// lib/views/admin/offers_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  void _showAdd(BuildContext context, AdminController ctrl) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final discount = TextEditingController();
    Get.defaultDialog(
      title: 'Add Offer',
      content: Column(
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: desc,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: discount,
            decoration: const InputDecoration(labelText: 'Discount %'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      textConfirm: 'Save',
      onConfirm: () async {
        await ctrl.addOffer({
          'title': title.text.trim(),
          'description': desc.text.trim(),
          'discount': double.tryParse(discount.text.trim()) ?? 0.0,
          "createdAt": DateTime.now().toIso8601String(),
        });
        Get.back();
      },
      textCancel: 'Cancel',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: Obx(() {
        final list = ctrl.offersList;
        if (list.isEmpty) return const Center(child: Text('No offers yet'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final o = list[i];
            return ListTile(
              title: Text(o['title'] ?? ''),
              subtitle: Text(o['description'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Delete offer?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await ctrl.deleteOffer(o['id']);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAdd(context, ctrl),
      ),
    );
  }
}
