import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class NewStaffMemberScreen extends StatefulWidget {
  const NewStaffMemberScreen({super.key});

  @override
  State<NewStaffMemberScreen> createState() => _NewStaffMemberScreenState();
}

class _NewStaffMemberScreenState extends State<NewStaffMemberScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  
  String selectedRole = 'Stylist';
  String selectedSkill = 'Hair Styling';
  final List<String> selectedDays = ['Mon', 'Tue', 'Fri', 'Sat'];

  final List<String> roles = ['Stylist', 'Barber', 'Specialist', 'Manager', 'Receptionist'];
  final List<String> skills = [
    'Hair Styling',
    'Hair Cutting',
    'Beard Trim',
    'Coloring',
    'Spa',
    'Massage',
    'Nails',
    'Makeup'
  ];
  final List<String> allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveStaff() async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter full name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (emailCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final ctrl = Get.find<AdminController>();

    try {
      await ctrl.addStaff(
        fullName: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        role: selectedRole,
        primarySkill: selectedSkill,
        workingDays: selectedDays, 
        isActive: true,
        
      );
    } catch (e) {
      // Error handled in controller
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
        title: const Text(
          "Add Staff Member",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (ctrl.isLoadingStaff.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(
            bottom: MediaQuery.of(context).viewInsets.bottom + 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _aiSuggestion(),
              const SizedBox(height: 24),
              _sectionTitle("Basic Information"),
              const SizedBox(height: 12),
              _inputField("Full Name", nameCtrl, Icons.person),
              _inputField("Email", emailCtrl, Icons.email, keyboardType: TextInputType.emailAddress),
              _inputField("Phone Number", phoneCtrl, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _sectionTitle("Role & Skills"),
              const SizedBox(height: 12),
              _dropdownField("Role", selectedRole, roles, (val) => setState(() => selectedRole = val)),
              _dropdownField("Primary Skill", selectedSkill, skills, (val) => setState(() => selectedSkill = val)),
              const SizedBox(height: 20),
              _sectionTitle("Working Hours"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allDays.map((day) => _dayChip(day)).toList(),
              ),
              const SizedBox(height: 20),
              _aiRecommendation(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _saveStaff,
                  child: const Text(
                    "Save Staff Member",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _aiSuggestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.psychology, color: accent, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Hiring Suggestion",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Based on booking trends, hiring a part-time stylist for weekends can reduce overload by 23%.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiRecommendation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb, color: accent, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "AI recommends assigning Hair Styling and Beard Trim services.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _inputField(String label, TextEditingController c, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
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
  }

  Widget _dropdownField(String label, String value, List<String> items, Function(String) onChanged) {
    return GestureDetector(
      onTap: () => _showPicker(label, items, value, onChanged),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(label == 'Role' ? Icons.work : Icons.star, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$label: $value",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _showPicker(String label, List<String> items, String currentValue, Function(String) onChanged) {
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
            Text(
              'Select $label',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => ListTile(
              title: Text(item, style: const TextStyle(color: Colors.white)),
              trailing: currentValue == item
                  ? const Icon(Icons.check, color: accent)
                  : const SizedBox.shrink(),
              onTap: () {
                onChanged(item);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _dayChip(String day) {
    final active = selectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (active) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? accent.withOpacity(0.2) : card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? accent : Colors.transparent),
        ),
        child: Text(
          day,
          style: TextStyle(
            color: active ? accent : Colors.white70,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}