// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../controllers/booking_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/section_header.dart';
import '../../widgets/custom_snackbar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserController userController = Get.find<UserController>();
  final BookingController bookingController = Get.find<BookingController>();

  @override
  void initState() {
    super.initState();
    // Load profile data when screen opens
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    print('🔄 Loading profile data...');
    await userController.refreshUserData();
    await bookingController.fetchUserBookings();
  }

  Future<void> _navigateToEditProfile() async {
    // Navigate to edit profile
    await Get.toNamed('/edit-profile');

    // ✅ When returning from edit profile, refresh the data
    print('⬅️ Returned from edit profile, refreshing...');
    await _loadProfileData();

    // Force UI rebuild
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        color: AppColors.primary,
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              /// ─────────── PROFILE CARD ───────────
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: userController.userName.value.isNotEmpty
                          ? Text(
                              userController.userName.value[0].toUpperCase(),
                              style: AppTextStyles.heading.copyWith(
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primary,
                            ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userController.userName.value.isNotEmpty
                                ? userController.userName.value
                                : 'Guest User',
                            style: AppTextStyles.subHeading.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userController.userEmail.value,
                            style: AppTextStyles.caption,
                          ),
                          if (userController.userPhone.value.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userController.userPhone.value,
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              /// ─────────── STATISTICS ───────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.event,
                      label: 'Total',
                      value: userController.totalBookings.value.toString(),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      label: 'Completed',
                      value: userController.completedBookings.value.toString(),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.currency_rupee,
                      label: 'Spent',
                      value:
                          '₹${userController.totalSpent.value.toStringAsFixed(0)}',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              /// ─────────── ACCOUNT ───────────
              const SectionHeader(title: 'Account'),
              const SizedBox(height: AppSpacing.sm),

              _ProfileItem(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: _navigateToEditProfile, // ✅ Use custom navigation
              ),
              _ProfileItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => Get.toNamed('/settings'),
              ),

              const SizedBox(height: AppSpacing.lg),

              /// ─────────── SUPPORT ───────────
              const SectionHeader(title: 'Support'),
              const SizedBox(height: AppSpacing.sm),

              _ProfileItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Help',
                    message: 'Contact support at support@salonapp.com',
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.info_outline,
                label: 'About App',
                onTap: () {
                  Get.dialog(
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: AppColors.primary,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'About',
                                style: AppTextStyles.heading.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Salon Booking App',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textPrimary,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Version 1.0.0',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Get.back(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────────────── STAT CARD ───────────────── */

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.subHeading.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/* ───────────────── PROFILE ITEM ───────────────── */

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
