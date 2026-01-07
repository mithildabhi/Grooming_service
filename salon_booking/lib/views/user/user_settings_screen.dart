import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/user_colors.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Preferences'),
            const SizedBox(height: 12),
            _cardBox(
              child: Column(
                children: [
                  _toggleTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Booking and payment alerts',
                    value: true,
                  ),
                  _divider(),
                  _toggleTile(
                    icon: Icons.email_rounded,
                    title: 'Email Notifications',
                    subtitle: 'Reports and summaries',
                    value: false,
                  ),
                  _divider(),
                  _toggleTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: 'Always enabled',
                    value: true,
                    enabled: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Account'),
            const SizedBox(height: 12),
            _cardBox(
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.person_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onPressed: () {
                      Get.toNamed('/user/edit-profile');
                    },
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.lock_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onPressed: () {
                      Get.snackbar(
                        'Info',
                        'Password change feature coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: userCard,
                        colorText: userPrimary,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onPressed: () {
                      Get.snackbar(
                        'Info',
                        'Privacy policy coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: userCard,
                        colorText: userPrimary,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Support'),
            const SizedBox(height: 12),
            _cardBox(
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help with your account',
                    onPressed: () {
                      Get.snackbar(
                        'Info',
                        'Help center coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: userCard,
                        colorText: userPrimary,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'App version and information',
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: userCard,
                          title: const Text(
                            'About',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Salon Booking App\nVersion 1.0.0',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Close',
                                style: TextStyle(color: userPrimary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Security'),
            const SizedBox(height: 12),
            _cardBox(
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    danger: true,
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: userCard,
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                authController.logout();
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _cardBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: userCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _divider() {
    return const Divider(color: Colors.white12, height: 24);
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    bool enabled = true,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: userPrimary.withOpacity(0.2),
          child: Icon(icon, color: userPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: userPrimary,
          onChanged: enabled ? (_) {} : null,
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool danger = false,
    required VoidCallback onPressed,
  }) {
    final Color color = danger ? Colors.redAccent : userPrimary;

    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: danger ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white54),
        ],
      ),
    );
  }
}

