import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/employee_model.dart';

class EditStaffMemberScreen extends StatefulWidget {
  const EditStaffMemberScreen({super.key});

  @override
  State<EditStaffMemberScreen> createState() => _EditStaffMemberScreenState();
}

class _EditStaffMemberScreenState extends State<EditStaffMemberScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  late EmployeeModel staff;
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late String selectedRole;
  late String selectedSkill;
  late List<String> selectedDays;
  late bool isActive;

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
  void initState() {
    super.initState();
    staff = Get.arguments as EmployeeModel;
    
    nameCtrl = TextEditingController(text: staff.fullName);
    emailCtrl = TextEditingController(text: staff.email);
    phoneCtrl = TextEditingController(text: staff.phone);
    selectedRole = _capitalizeFirst(staff.role);
    selectedSkill = _formatSkill(staff.primarySkill);
    selectedDays = List.from(staff.workingDays);
    isActive = staff.isActive;  
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatSkill(String skill) {
    return skill.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStaff() async {
    if (nameCtrl.text.trim().isEmpty || 
        emailCtrl.text.trim().isEmpty || 
        phoneCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final ctrl = Get.find<AdminController>();
    try {
      await ctrl.updateStaff(
        staffId: staff.id,
        fullName: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        role: selectedRole,
        primarySkill: selectedSkill,
        workingDays: selectedDays,
        isActive: isActive,
      );
    } catch (e) {
      // Error handled in controller
    }
  }

  Future<void> _deleteStaff() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: card,
        title: const Text(
          'Delete Staff Member',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${staff.fullName}? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ctrl = Get.find<AdminController>();
      try {
        await ctrl.deleteStaffMember(staffId: staff.id);
      } catch (e) {
        // Error handled in controller
      }
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
          "Staff Details",
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Staff Info Card
              _staffInfoCard(),
              const SizedBox(height: 24),

              // Performance & Status
              _performanceCard(),
              const SizedBox(height: 24),

              // Edit Form
              _sectionTitle("Edit Information"),
              const SizedBox(height: 12),
              _inputField("Full Name", nameCtrl, Icons.person),
              _inputField("Email", emailCtrl, Icons.email, 
                  keyboardType: TextInputType.emailAddress),
              _inputField("Phone Number", phoneCtrl, Icons.phone, 
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 20),
              _sectionTitle("Role & Skills"),
              const SizedBox(height: 12),
              _dropdownField("Role", selectedRole, roles, 
                  (val) => setState(() => selectedRole = val)),
              _dropdownField("Primary Skill", selectedSkill, skills, 
                  (val) => setState(() => selectedSkill = val)),

              const SizedBox(height: 20),
              _sectionTitle("Working Schedule"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allDays.map((day) => _dayChip(day)).toList(),
              ),

              const SizedBox(height: 24),
              _sectionTitle("Status"),
              const SizedBox(height: 12),
              _statusTile(),

              const SizedBox(height: 32),
              _actionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _staffInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: accent.withOpacity(0.2),
                child: Text(
                  staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: accent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${staff.id}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.email, staff.email),
          const SizedBox(height: 8),
          _infoRow(Icons.phone, staff.phone),
          const SizedBox(height: 8),
          _infoRow(Icons.business, 'Salon ID: ${staff.salon}'),
        ],
      ),
    );
  }

  Widget _performanceCard() {
    final status = staff.performanceStatus;
    final score = staff.performanceScore;
    Color statusColor;
    
    switch (status) {
      case 'Top Performer':
        statusColor = Colors.greenAccent;
        break;
      case 'Overloaded':
        statusColor = Colors.orangeAccent;
        break;
      case 'Available':
        statusColor = accent;
        break;
      default:
        statusColor = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: accent, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Performance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statBox("Status", status, statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox("Score", score, statusColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statBox("Working Days", "${selectedDays.length} days/week", accent),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
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

  Widget _dropdownField(String label, String value, List<String> items, 
      Function(String) onChanged) {
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

  void _showPicker(String label, List<String> items, String currentValue, 
      Function(String) onChanged) {
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

  Widget _statusTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Active Status",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: isActive,
            activeColor: accent,
            onChanged: (val) => setState(() => isActive = val),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _updateStaff,
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _deleteStaff,
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}