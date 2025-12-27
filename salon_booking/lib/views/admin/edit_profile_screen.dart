// lib/views/admin/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/controllers/admin_controller.dart';
import 'package:salon_booking/models/salon_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  final _formKey = GlobalKey<FormState>();
  final AdminController adminCtrl = Get.find<AdminController>();

  SalonProfile? existingProfile;

  late TextEditingController _salonNameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _imageUrlController;

  String _selectedSalonType = 'unisex';

  @override
  void initState() {
    super.initState();

    existingProfile = Get.arguments as SalonProfile? ?? adminCtrl.salonProfile.value;

    _salonNameController = TextEditingController(
      text: existingProfile?.name ?? '',
    );
    _phoneController = TextEditingController(
      text: existingProfile?.phone ?? '',
    );
    _locationController = TextEditingController(
      text: existingProfile?.address ?? '',
    );
    _aboutController = TextEditingController(
      text: existingProfile?.about ?? '',
    );
    _imageUrlController = TextEditingController(
      text: existingProfile?.imageUrl ?? '',
    );

    _selectedSalonType = existingProfile?.salonType ?? 'unisex';
  }

  @override
  void dispose() {
    _salonNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final profile = existingProfile?.copyWith(
        name: _salonNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _locationController.text.trim(),
        about: _aboutController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        salonType: _selectedSalonType,
        hours: existingProfile?.hours ?? {
          'Mon': '09:00-19:00',
          'Tue': '09:00-19:00',
          'Wed': '09:00-19:00',
          'Thu': '09:00-19:00',
          'Fri': '09:00-19:00',
          'Sat': '09:00-19:00',
          'Sun': 'Closed',
        },
      ) ?? SalonProfile(
        id: '',
        name: _salonNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _locationController.text.trim(),
        about: _aboutController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        salonType: _selectedSalonType,
        hours: {
          'Mon': '09:00-19:00',
          'Tue': '09:00-19:00',
          'Wed': '09:00-19:00',
          'Thu': '09:00-19:00',
          'Fri': '09:00-19:00',
          'Sat': '09:00-19:00',
          'Sun': 'Closed',
        },
      );

      await adminCtrl.saveSalonProfile(profile);
    } catch (e) {
      debugPrint('Error in EditProfileScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          existingProfile != null ? 'Edit Profile' : 'Create Profile',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final isLoading = adminCtrl.isLoadingProfile.value;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageUrlController.text.isNotEmpty
                            ? NetworkImage(_imageUrlController.text)
                            : const NetworkImage('https://i.pravatar.cc/300'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _sectionTitle('Salon Information'),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _salonNameController,
                  label: 'Salon Name',
                  icon: Icons.store,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Salon name is required';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Phone is required';
                    }
                    if (val.replaceAll(RegExp(r'[\s+]'), '').length < 10) {
                      return 'Phone must be at least 10 digits';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _aboutController,
                  label: 'About (Optional)',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),

                _buildTextField(
                  controller: _imageUrlController,
                  label: 'Image URL (Optional)',
                  icon: Icons.image,
                ),

                const SizedBox(height: 16),

                _sectionTitle('Salon Type'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSalonType,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: card,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'unisex', child: Text('Unisex')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSalonType = value!);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isLoading ? null : _saveProfile,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            existingProfile != null ? 'Save Changes' : 'Create Profile',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: validator,
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
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}