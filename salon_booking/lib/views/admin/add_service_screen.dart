// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/custom_snackbar.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final category = 'hair'.obs;

  final List<Map<String, String>> categories = [
    {'value': 'hair', 'label': 'Hair'},
    {'value': 'spa', 'label': 'Spa'},
    {'value': 'nails', 'label': 'Nails'},
    {'value': 'facial', 'label': 'Facial'},
    {'value': 'massage', 'label': 'Massage'},
    {'value': 'waxing', 'label': 'Waxing'},
    {'value': 'makeup', 'label': 'Makeup'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    durationCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.map((cat) => Obx(() => ListTile(
              title: Text(
                cat['label']!,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: category.value == cat['value']
                  ? const Icon(Icons.check, color: accent)
                  : const SizedBox.shrink(),
              onTap: () {
                category.value = cat['value']!;
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }

  Future<void> _saveService() async {
    // Validation
    if (nameCtrl.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter service name',
        isError: true,
      );
      return;
    }

    if (priceCtrl.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter price',
        isError: true,
      );
      return;
    }

    if (durationCtrl.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter duration',
        isError: true,
      );
      return;
    }

    final ctrl = Get.find<AdminController>();

    try {
      await ctrl.addService(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.tryParse(priceCtrl.text) ?? 0,
        duration: int.tryParse(durationCtrl.text) ?? 0,
        category: category.value,
      );
    } catch (e) {
      // Error is already handled in controller
      print('Error saving service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text("Add Service", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (ctrl.isLoadingServices.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _aiHint(),
              const SizedBox(height: 24),

              _sectionTitle("Service Details"),
              const SizedBox(height: 12),

              _input("Service Name", nameCtrl, Icons.cut),
              _input("Price (₹)", priceCtrl, Icons.currency_rupee, 
                  keyboardType: TextInputType.number),
              _input("Duration (minutes)", durationCtrl, Icons.access_time,
                  keyboardType: TextInputType.number),
              _dropdownTile(),
              _multiline("Description", descCtrl),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saveService,
                  child: const Text(
                    "Save Service",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _aiHint() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      children: [
        Icon(Icons.psychology, color: accent, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            "AI suggests services under 30 mins get more bookings.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _input(
    String label, 
    TextEditingController c, 
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: accent),
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );

  Widget _multiline(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        alignLabelWithHint: true,
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );

  Widget _dropdownTile() => Obx(
    () => GestureDetector(
      onTap: _showCategoryPicker,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.category, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Category: ${categories.firstWhere((c) => c['value'] == category.value)['label']}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ],
        ),
      ),
    ),
  );
}