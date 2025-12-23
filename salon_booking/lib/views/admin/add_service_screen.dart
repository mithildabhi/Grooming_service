// lib/views/admin/add_service_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/admin_controller.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final ctrl = Get.find<AdminController>();

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final durationCtrl = TextEditingController(text: "45");

  File? beforeImg;
  File? afterImg;

  Future<void> pick(bool before) async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        before ? beforeImg = File(img.path) : afterImg = File(img.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        title: const Text(
          "Add New Service",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gallery(),
            _field("Service Name", nameCtrl),
            _field("Description", descCtrl, maxLines: 3),
            Row(
              children: [
                Expanded(child: _field("Price", priceCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field("Duration (min)", durationCtrl)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22E6D3),
                ),
                onPressed: () {
                  ctrl.servicesList.add({
                    "id": DateTime.now().toString(),
                    "name": nameCtrl.text,
                    "description": descCtrl.text,
                    "price": priceCtrl.text,
                    "duration": durationCtrl.text,
                  });
                  Get.back();
                },
                child: const Text(
                  "Save Service",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gallery() => Row(
    children: [
      _imgBox("Before", beforeImg, () => pick(true)),
      const SizedBox(width: 12),
      _imgBox("After", afterImg, () => pick(false)),
    ],
  );

  Widget _imgBox(String t, File? f, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
            image: f != null
                ? DecorationImage(image: FileImage(f), fit: BoxFit.cover)
                : null,
          ),
          child: f == null
              ? Center(
                  child: Text(t, style: const TextStyle(color: Colors.white54)),
                )
              : null,
        ),
      ),
    );
  }

  Widget _field(String l, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: l,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
