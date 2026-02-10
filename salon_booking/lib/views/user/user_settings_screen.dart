import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/section_header.dart';
import '../../widgets/custom_snackbar.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          /// ───────────── PREFERENCES ─────────────
          const SectionHeader(title: 'Preferences'),
          const SizedBox(height: AppSpacing.sm),

          _SettingItem(
            icon: Icons.notifications_none,
            label: 'Notifications',
            onTap: () {
              CustomSnackbar.show(
                title: 'Notifications',
                message: 'Notification settings coming soon',
              );
            },
          ),
          _SettingItem(
            icon: Icons.lock_outline,
            label: 'Privacy',
            onTap: () {
              CustomSnackbar.show(
                title: 'Privacy',
                message: 'Privacy settings coming soon',
              );
            },
          ),
          _SettingItem(
            icon: Icons.palette_outlined,
            label: 'Appearance',
            onTap: () {
              CustomSnackbar.show(
                title: 'Appearance',
                message: 'Appearance settings coming soon',
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          /// ───────────── SUPPORT ─────────────
          const SectionHeader(title: 'Support'),
          const SizedBox(height: AppSpacing.sm),

          _SettingItem(
            icon: Icons.help_outline,
            label: 'Help & Support',
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
                              Icons.help_outline,
                              color: AppColors.primary,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Help & Support',
                            style: AppTextStyles.heading.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'For support, please contact us at:',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'support@salonapp.com',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Or call: +91 1234567890',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
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
                                style: TextStyle(fontWeight: FontWeight.bold),
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
          _SettingItem(
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
                              fontWeight: FontWeight.bold,
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
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Book your favorite salon services with ease.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
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
                                style: TextStyle(fontWeight: FontWeight.bold),
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

          const SizedBox(height: AppSpacing.lg),

          /// ───────────── ACCOUNT ─────────────
          const SectionHeader(title: 'Account'),
          const SizedBox(height: AppSpacing.sm),

          _SettingItem(
            icon: Icons.logout,
            label: 'Log Out',
            isDestructive: true,
            onTap: () async {
              final confirmed = await Get.dialog<bool>(
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
                              color: Colors.redAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Log Out',
                            style: AppTextStyles.heading.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Are you sure you want to log out?',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(result: false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(
                                      color: AppColors.divider,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Get.back(result: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: true,
              );

              if (confirmed == true) {
                await userController.logout();
              }
            },
          ),
        ],
      ),
    );
  }
}

/* ───────────────── SETTING ROW ───────────────── */

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive
        ? Colors.redAccent
        : AppColors.textPrimary;

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
                color: (isDestructive ? Colors.redAccent : AppColors.primary)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(color: color),
              ),
            ),
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
