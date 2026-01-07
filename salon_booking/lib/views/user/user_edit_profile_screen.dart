import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/user_colors.dart';

class UserEditProfileScreen extends StatefulWidget {
  const UserEditProfileScreen({super.key});

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController profileController = Get.find<ProfileController>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;

  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDOB() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (date != null) {
      _dobController.text = '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await profileController.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        // backend can later accept these:
        // gender: _gender,
        // address: _addressController.text.trim(),
        // dob: _dobController.text.trim(),
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: userCard,
        colorText: userPrimary,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFFE5E7EB),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE5E7EB)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('PERSONAL INFORMATION'),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_rounded,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_rounded,
                enabled: false,
              ),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.length != 10) {
                    return 'Enter valid 10 digit number';
                  }
                  return null;
                },
              ),

              _genderSelector(),

              _buildDateField(),

              _sectionTitle('ADDRESS'),

              _buildTextField(
                controller: _addressController,
                label: 'Full Address',
                icon: Icons.location_on_rounded,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Address required' : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userPrimary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 24),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: userCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) {
              final selected = _gender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? userPrimary.withOpacity(0.2) : userBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? userPrimary : Colors.white12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        g,
                        style: TextStyle(
                          color: selected
                              ? userPrimary
                              : const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDOB,
      child: AbsorbPointer(
        child: _buildTextField(
          controller: _dobController,
          label: 'Date of Birth',
          icon: Icons.cake_rounded,
          validator: (v) => v!.isEmpty ? 'Select date of birth' : null,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFFE5E7EB)),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: Icon(icon, color: userPrimary),
          filled: true,
          fillColor: userCard,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
