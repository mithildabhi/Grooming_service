// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/user_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/primary_button.dart';

class UserEditProfileScreen extends StatefulWidget {
  const UserEditProfileScreen({super.key});

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final UserController userController = Get.find<UserController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String selectedGender = 'NOT_SPECIFIED';
  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    // Load current customer profile data
    nameController.text = userController.userName.value;
    phoneController.text = userController.userPhone.value;
    addressController.text = userController.userAddress.value;
    cityController.text = userController.userCity.value;
    pincodeController.text = userController.userPincode.value;
    
    // Map backend gender values to display values
    selectedGender = _mapGenderFromBackend(userController.userGender.value);
    
    if (userController.userDateOfBirth.value.isNotEmpty) {
      try {
        selectedDateOfBirth = DateTime.parse(userController.userDateOfBirth.value);
      } catch (_) {}
    }
  }

  String _mapGenderFromBackend(String backendGender) {
    switch (backendGender.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      case 'NOT_SPECIFIED':
      default:
        return 'Not specified';
    }
  }

  String _mapGenderToBackend(String displayGender) {
    switch (displayGender) {
      case 'Male':
        return 'MALE';
      case 'Female':
        return 'FEMALE';
      case 'Other':
        return 'OTHER';
      case 'Not specified':
      default:
        return 'NOT_SPECIFIED';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading
    print('📤 Saving profile changes...');

    final success = await userController.updateProfile(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      pincode: pincodeController.text.trim(),
      gender: _mapGenderToBackend(selectedGender),
      dateOfBirth: selectedDateOfBirth?.toIso8601String() ?? '',
    );

    if (success) {
      print('✅ Profile saved successfully, going back to profile screen');
      
      // ✅ Wait a moment for the UI to update
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Go back to profile screen - the profile will auto-refresh
      Get.back();
    } else {
      print('❌ Profile save failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PROFILE PICTURE
                    Center(
                      child: Stack(
                        children: [
                          Obx(() => CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: userController.userName.value.isNotEmpty
                                ? Text(
                                    userController.userName.value[0].toUpperCase(),
                                    style: AppTextStyles.heading.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 40,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                          )),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// PERSONAL INFO
                    Text(
                      'Personal Information',
                      style: AppTextStyles.subHeading.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          TextFormField(
                            enabled: false,
                            initialValue: userController.userEmail.value,
                            decoration: _inputDecoration(
                              label: 'Email',
                              icon: Icons.email,
                              enabled: false,
                            ),
                            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          _buildTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty && value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Gender Selection
                          GestureDetector(
                            onTap: () {
                              _showGenderPicker();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline, color: AppColors.textMuted),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Gender',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedGender,
                                          style: AppTextStyles.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Date of Birth
                          GestureDetector(
                            onTap: _selectDateOfBirth,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cake, color: AppColors.textMuted),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date of Birth',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedDateOfBirth != null
                                              ? DateFormat('dd MMM yyyy').format(selectedDateOfBirth!)
                                              : 'Select date',
                                          style: AppTextStyles.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// ADDRESS INFO
                    Text(
                      'Address Details',
                      style: AppTextStyles.subHeading.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: addressController,
                            label: 'Address',
                            icon: Icons.home,
                            maxLines: 2,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: cityController,
                                  label: 'City',
                                  icon: Icons.location_city,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _buildTextField(
                                  controller: pincodeController,
                                  label: 'Pincode',
                                  icon: Icons.pin_drop,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && value.length != 6) {
                                      return 'Invalid pincode';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            /// SAVE BUTTON
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Obx(() => PrimaryButton(
                label: userController.isUpdating.value ? 'Saving...' : 'Save Changes',
                enabled: !userController.isUpdating.value,
                onPressed: _handleSave,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label: label, icon: icon),
      style: AppTextStyles.body,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: enabled ? AppColors.surface : AppColors.surface.withOpacity(0.5),
    );
  }

  void _showGenderPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Gender',
              style: AppTextStyles.subHeading.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...['Male', 'Female', 'Other', 'Not specified'].map((gender) {
              return ListTile(
                title: Text(gender, style: AppTextStyles.body),
                trailing: selectedGender == gender
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    selectedGender = gender;
                  });
                  Get.back();
                },
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}