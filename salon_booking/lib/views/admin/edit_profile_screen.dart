// lib/views/admin/edit_profile_screen.dart
// ✅ UPDATED: Complete location fields (address, city, state, pincode)

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

  // ✅ UPDATED: Separate controllers for location fields
  late TextEditingController _salonNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;      // NEW: Street address
  late TextEditingController _cityController;         // NEW: City
  late TextEditingController _stateController;        // NEW: State
  late TextEditingController _pincodeController;      // NEW: Pincode
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
    
    // ✅ NEW: Initialize location fields separately
    _addressController = TextEditingController(
      text: existingProfile?.address ?? '',
    );
    _cityController = TextEditingController(
      text: existingProfile?.city ?? '',
    );
    _stateController = TextEditingController(
      text: existingProfile?.state ?? '',
    );
    _pincodeController = TextEditingController(
      text: existingProfile?.pincode ?? '',
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
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _aboutController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ✅ NEW: Open location picker screen
  Future<void> _openLocationPicker() async {
    // You can create a separate AdminLocationPickerScreen or use a simple dialog
    // For now, I'll show a dialog, but you can replace with Get.to()
    
    final result = await Get.dialog<Map<String, dynamic>>(
      _buildLocationPickerDialog(),
      barrierDismissible: false,
    );
    
    if (result != null) {
      setState(() {
        if (result['address'] != null) {
          _addressController.text = result['address'];
        }
        if (result['city'] != null) {
          _cityController.text = result['city'];
        }
        if (result['state'] != null) {
          _stateController.text = result['state'];
        }
        if (result['pincode'] != null) {
          _pincodeController.text = result['pincode'];
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // ✅ UPDATED: Include all location fields
      final profile = existingProfile?.copyWith(
        name: _salonNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),      // Street address
        city: _cityController.text.trim(),            // City
        state: _stateController.text.trim(),          // State
        pincode: _pincodeController.text.trim(),      // Pincode
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
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
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
                // Profile Image
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

                // BASIC INFORMATION
                _sectionTitle('Basic Information'),
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
                    if (val.replaceAll(RegExp(r'[\s+\-()]'), '').length < 10) {
                      return 'Phone must be at least 10 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ✅ LOCATION SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle('Location Details'),
                    TextButton.icon(
                      onPressed: _openLocationPicker,
                      icon: const Icon(Icons.my_location, color: accent, size: 18),
                      label: const Text(
                        'Use GPS',
                        style: TextStyle(color: accent, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Street Address
                _buildTextField(
                  controller: _addressController,
                  label: 'Street Address',
                  hint: 'Shop no, Building, Street, Area',
                  icon: Icons.home,
                  maxLines: 2,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),

                // City & State Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'e.g., Surat',
                        icon: Icons.location_city,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'City is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _stateController,
                        label: 'State',
                        hint: 'e.g., Gujarat',
                        icon: Icons.map,
                      ),
                    ),
                  ],
                ),

                // Pincode
                _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  hint: 'e.g., 395007',
                  icon: Icons.pin,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),

                // ADDITIONAL INFORMATION
                _sectionTitle('Additional Information'),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _aboutController,
                  label: 'About Salon (Optional)',
                  hint: 'Describe your salon...',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),

                _buildTextField(
                  controller: _imageUrlController,
                  label: 'Image URL (Optional)',
                  hint: 'https://...',
                  icon: Icons.image,
                ),

                const SizedBox(height: 16),

                // Salon Type
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
                    icon: const Icon(Icons.arrow_drop_down, color: accent),
                    items: const [
                      DropdownMenuItem(
                        value: 'male',
                        child: Row(
                          children: [
                            Icon(Icons.man, color: accent, size: 20),
                            SizedBox(width: 12),
                            Text('Male Salon'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Row(
                          children: [
                            Icon(Icons.woman, color: accent, size: 20),
                            SizedBox(width: 12),
                            Text('Female Salon'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'unisex',
                        child: Row(
                          children: [
                            Icon(Icons.wc, color: accent, size: 20),
                            SizedBox(width: 12),
                            Text('Unisex Salon'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSalonType = value!);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
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
                            existingProfile != null ? 'SAVE CHANGES' : 'CREATE PROFILE',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
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

  // ===== HELPER METHODS =====

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
    String? hint,
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
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: Icon(icon, color: accent),
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
      ),
    );
  }

  // ✅ Simple location picker dialog (you can replace with full screen)
  Widget _buildLocationPickerDialog() {
    return AlertDialog(
      backgroundColor: card,
      title: const Text(
        'Location Options',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.my_location, color: accent),
            title: const Text(
              'Use Current Location',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Auto-fill from GPS',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            onTap: () async {
              // TODO: Implement GPS location fetch
              Get.back(result: {
                'address': 'Auto-filled from GPS',
                'city': 'Surat',
                'state': 'Gujarat',
                'pincode': '395007',
              });
              
              Get.snackbar(
                'GPS Feature',
                'GPS location will be implemented with location service',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: card,
                colorText: Colors.white,
              );
            },
          ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.edit, color: accent),
            title: const Text(
              'Enter Manually',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Fill forms below',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            onTap: () {
              Get.back(); // Just close dialog, user will fill manually
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
      ],
    );
  }
}