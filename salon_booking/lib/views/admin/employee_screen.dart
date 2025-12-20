import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/admin_controller.dart';

class EmployeesScreen extends StatelessWidget {
  EmployeesScreen({super.key});

  final AdminController ctrl = Get.find<AdminController>();

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController roleCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  final Rx<File?> imageFile = Rx<File?>(null);

  // ---------------- PICK IMAGE ----------------
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  // ---------------- ADD STAFF SHEET ----------------
  void _addEmployeeSheet() {
    nameCtrl.clear();
    roleCtrl.clear();
    phoneCtrl.clear();
    imageFile.value = null;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Add Staff",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Obx(
                () => GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: imageFile.value != null
                        ? FileImage(imageFile.value!)
                        : null,
                    child: imageFile.value == null
                        ? const Icon(Icons.camera_alt)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _field(nameCtrl, "Full Name"),
              const SizedBox(height: 12),
              _field(roleCtrl, "Role"),
              const SizedBox(height: 12),
              _field(phoneCtrl, "Phone", type: TextInputType.phone),

              const SizedBox(height: 22),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (nameCtrl.text.isEmpty || roleCtrl.text.isEmpty) return;

                  ctrl.addEmployee({
                    "id": DateTime.now().millisecondsSinceEpoch.toString(),
                    "name": nameCtrl.text.trim(),
                    "role": roleCtrl.text.trim(),
                    "contact": phoneCtrl.text.trim(),
                    "imageFile": imageFile.value,
                    "bookingCount": 0,
                  });

                  Get.back();
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5F2),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Manage Staff",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.pinkAccent,
              onPressed: _addEmployeeSheet,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ---------------- SEARCH ----------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              onChanged: ctrl.searchEmployee,
              decoration: InputDecoration(
                hintText: "Search by staff name",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---------------- STAFF LIST ----------------
          Expanded(
            child: Obx(() {
              final list = ctrl.filteredEmployees;

              if (list.isEmpty) {
                return const Center(child: Text("No staff found"));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _staffCard(list[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---------------- STAFF CARD ----------------
  Widget _staffCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              (data['name'] ?? 'S')[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['role'] ?? '',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: Colors.pinkAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  "${data['bookingCount'] ?? 0}",
                  style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text("Delete")),
            ],
            onSelected: (v) {
              if (v == 'delete') {
                ctrl.deleteEmployee(data['id']);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
