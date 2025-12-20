// lib/views/admin/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/salon_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AdminController ctrl = Get.find<AdminController>();
  final _formKey = GlobalKey<FormState>();

  bool saving = false;

  late TextEditingController nameCtrl,
      addressCtrl,
      phoneCtrl,
      aboutCtrl,
      imageCtrl;

  String salonType = "Unisex";
  Map<String, dynamic> hours = {};

  @override
  void initState() {
    super.initState();
    final p = ctrl.salonProfile.value;

    nameCtrl = TextEditingController(text: p?.name ?? "");
    addressCtrl = TextEditingController(text: p?.address ?? "");
    phoneCtrl = TextEditingController(text: p?.phone ?? "");
    aboutCtrl = TextEditingController(text: p?.about ?? "");
    imageCtrl = TextEditingController(text: p?.imageUrl ?? "");

    salonType = p?.type ?? "Unisex";

    hours =
        p?.hours ??
        {
          "Mon": "09:00–19:00",
          "Tue": "09:00–19:00",
          "Wed": "09:00–19:00",
          "Thu": "09:00–19:00",
          "Fri": "09:00–19:00",
          "Sat": "09:00–19:00",
          "Sun": "Closed",
        };
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final profile = SalonProfile(
        id: ctrl.activeSalonId.value,
        name: nameCtrl.text.trim(),
        type: salonType,
        address: addressCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        about: aboutCtrl.text.trim(),
        imageUrl: imageCtrl.text.trim(),
        hours: hours,
      );

      await ctrl.saveSalonProfile(profile);
      Get.snackbar("Success", "Salon profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    setState(() => saving = false);
  }

  // ----------------- UPLOAD IMAGE -----------------
  Future<void> _uploadImage(bool fromCamera) async {
    final url = await ctrl.pickAndUploadImage(fromCamera: fromCamera);

    if (url != null && url.isNotEmpty) {
      setState(() => imageCtrl.text = url);
      Get.snackbar("Updated", "Profile image updated");
    }
  }

  // ----------------- EDIT HOURS -----------------
  void _editHours() {
    final days = hours.keys.toList();

    showDialog(
      context: context,
      builder: (ctx) {
        final controllers = {
          for (var d in days) d: TextEditingController(text: hours[d]),
        };

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Working Hours"),
          content: SingleChildScrollView(
            child: Column(
              children: days.map((day) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: controllers[day],
                    decoration: InputDecoration(
                      labelText: day,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hours = {for (var d in days) d: controllers[d]!.text.trim()};
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ----------------- UI START -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5F2),
        elevation: 0,
        title: const Text(
          "Salon Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---------------- PROFILE IMAGE SECTION ----------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: imageCtrl.text.isNotEmpty
                              ? NetworkImage(imageCtrl.text)
                              : null,
                          child: imageCtrl.text.isEmpty
                              ? const Icon(
                                  Icons.storefront,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        GestureDetector(
                          onTap: () => _uploadImage(false),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pinkAccent,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Update Salon Picture",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- INPUT FIELDS CARD ----------------
              _cardWrapper(
                children: [
                  _inputBox(
                    "Salon Name",
                    nameCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Salon name required";
                      }
                      return null;
                    },
                  ),

                  _dropdownBox("Salon Type", salonType, [
                    "Male",
                    "Female",
                    "Unisex",
                  ], (v) => setState(() => salonType = v!)),

                  _inputBox(
                    "Phone Number",
                    phoneCtrl,
                    type: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Phone required";
                      }
                      if (v.length != 10) return "Must be 10 digits";
                      return null;
                    },
                  ),

                  _inputBox("Address", addressCtrl, maxLines: 2),
                  _inputBox("About", aboutCtrl, maxLines: 3),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Working Hours",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      hours.entries
                          .map((e) => "${e.key}: ${e.value}")
                          .join("\n"),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: const Icon(Icons.schedule),
                    onTap: _editHours,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ---------------- SAVE BUTTON ----------------
              ElevatedButton(
                onPressed: saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Save Profile",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- UI SUB COMPONENTS -----------------

  Widget _cardWrapper({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(children: children),
    );
  }

  Widget _inputBox(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
    FormFieldValidator? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        validator: validator,
        maxLines: maxLines,
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
      ),
    );
  }

  Widget _dropdownBox(
    String label,
    String value,
    List<String> items,
    Function(String?) onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChange,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
