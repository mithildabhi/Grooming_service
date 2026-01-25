import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/section_header.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Get.snackbar(
                'Notifications',
                'Notification settings coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _SettingItem(
            icon: Icons.lock_outline,
            label: 'Privacy',
            onTap: () {
              Get.snackbar(
                'Privacy',
                'Privacy settings coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _SettingItem(
            icon: Icons.palette_outlined,
            label: 'Appearance',
            onTap: () {
              Get.snackbar(
                'Appearance',
                'Appearance settings coming soon',
                snackPosition: SnackPosition.BOTTOM,
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
                AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Help & Support'),
                  content: const Text(
                    'For support, please contact us at:\n\nsupport@salonapp.com\n\nOr call: +91 1234567890',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _SettingItem(
            icon: Icons.info_outline,
            label: 'About App',
            onTap: () {
              Get.dialog(
                AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('About'),
                  content: const Text(
                    'Salon Booking App\nVersion 1.0.0\n\nBook your favorite salon services with ease.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
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
                AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
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
