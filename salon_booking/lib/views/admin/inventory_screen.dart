// lib/views/admin/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _showAdd(BuildContext context, AdminController ctrl) {
    final name = TextEditingController();
    final qty = TextEditingController();
    Get.defaultDialog(
      title: 'Add Item',
      content: Column(
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: qty,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      textConfirm: 'Save',
      onConfirm: () async {
        await ctrl.addInventory({
          'name': name.text.trim(),
          'qty': int.tryParse(qty.text.trim()) ?? 0,
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
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                showSearch(context: context, delegate: _InvSearch(ctrl)),
          ),
        ],
      ),
      body: Obx(() {
        final list = ctrl.inventoryList;
        if (list.isEmpty) {
          return const Center(child: Text('No inventory items'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, i) {
            final it = list[i];
            return ListTile(
              title: Text(it['name'] ?? ''),
              subtitle: Text('Qty: ${it['qty'] ?? 0}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Delete item?'),
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
                  if (ok == true) await ctrl.deleteInventory(it['id']);
                },
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: list.length,
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAdd(context, Get.find<AdminController>()),
      ),
    );
  }
}

class _InvSearch extends SearchDelegate {
  final AdminController ctrl;
  _InvSearch(this.ctrl);
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );
  @override
  Widget buildResults(BuildContext context) => Container();
  @override
  Widget buildSuggestions(BuildContext context) {
    final list = ctrl.inventoryList
        .where(
          (i) => (i['name'] ?? '').toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(list[i]['name'] ?? ''),
        subtitle: Text('Qty: ${list[i]['qty'] ?? 0}'),
      ),
    );
  }
}
