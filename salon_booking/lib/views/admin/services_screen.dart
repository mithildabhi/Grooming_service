// lib/views/admin/services_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/service_model.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5F2),
        elevation: 0,
        title: const Text(
          'Services',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                showSearch(context: context, delegate: _ServiceSearch(ctrl)),
          ),
        ],
      ),

      // ---------------- BODY ----------------
      body: Obx(() {
        final services = ctrl.servicesList;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.design_services,
                      size: 32,
                      color: Colors.pinkAccent,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Services',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          services.length.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---------- LIST ----------
            Expanded(
              child: services.isEmpty
                  ? const Center(
                      child: Text(
                        'No services added yet',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final s = services[i];
                        return _ServiceTile(
                          service: s,
                          onDelete: () async {
                            final ok = await _confirmDelete(context, ctrl, s);
                            if (ok == true) {
                              Get.snackbar(
                                "Deleted",
                                "Service removed successfully",
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      }),

      // ---------------- FAB ----------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
        onPressed: () => _showAddServiceSheet(context, ctrl),
      ),
    );
  }

  // ================= ADD SERVICE SHEET =================
  void _showAddServiceSheet(BuildContext context, AdminController ctrl) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '30');
    final categoryCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final gender = 'Unisex'.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _sheetHandle(),
              const SizedBox(height: 12),
              const Text(
                "Add Service",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              _textField(nameCtrl, "Service Name"),
              const SizedBox(height: 12),
              _textField(priceCtrl, "Price", type: TextInputType.number),
              const SizedBox(height: 12),
              _textField(
                durationCtrl,
                "Duration (minutes)",
                type: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _textField(categoryCtrl, "Category"),
              const SizedBox(height: 12),

              Obx(
                () => DropdownButtonFormField<String>(
                  value: gender.value,
                  decoration: _inputDecoration("Gender"),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Unisex', child: Text('Unisex')),
                  ],
                  onChanged: (v) => gender.value = v ?? 'Unisex',
                ),
              ),

              const SizedBox(height: 12),
              _textField(descCtrl, "Description", maxLines: 3),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty ||
                      priceCtrl.text.isEmpty ||
                      durationCtrl.text.isEmpty) {
                    Get.snackbar("Error", "Required fields missing");
                    return;
                  }

                  final service = ServiceModel(
                    id: '',
                    name: nameCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text.trim()) ?? 0,
                    durationMinutes:
                        int.tryParse(durationCtrl.text.trim()) ?? 30,
                    category: categoryCtrl.text.trim(),
                    gender: gender.value,
                    description: descCtrl.text.trim(),
                    image: '',
                  );

                  await ctrl.addService(service);
                  Get.back();
                  Get.snackbar("Success", "Service added");
                },
                child: const Text("Save Service"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DELETE =================
  Future<bool?> _confirmDelete(
    BuildContext context,
    AdminController ctrl,
    dynamic service,
  ) async {
    final id = service['id'];

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete service?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await ctrl.deleteService(id);
              Get.back(result: true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ================= SERVICE TILE =================
class _ServiceTile extends StatelessWidget {
  final dynamic service;
  final VoidCallback onDelete;

  const _ServiceTile({required this.service, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.pinkAccent.withOpacity(.15),
            child: const Icon(Icons.cut, color: Colors.pinkAccent),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${service['price']} • ${service['durationMinutes']} min',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ================= SEARCH =================
class _ServiceSearch extends SearchDelegate {
  final AdminController ctrl;
  _ServiceSearch(this.ctrl);

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
    final list = ctrl.servicesList
        .where(
          (s) => (s['name'] ?? '').toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(list[i]['name'] ?? ''),
        subtitle: Text('₹${list[i]['price']}'),
      ),
    );
  }
}

// ================= HELPERS =================
Widget _sheetHandle() => Container(
  width: 40,
  height: 4,
  decoration: BoxDecoration(
    color: Colors.grey.shade400,
    borderRadius: BorderRadius.circular(8),
  ),
);

Widget _textField(
  TextEditingController ctrl,
  String label, {
  int maxLines = 1,
  TextInputType type = TextInputType.text,
}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: type,
    decoration: _inputDecoration(label),
  );
}

InputDecoration _inputDecoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: Colors.grey.shade100,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
);
