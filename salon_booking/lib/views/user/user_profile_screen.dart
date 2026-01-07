import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/user_colors.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        elevation: 0,
        // leading: const BackButton(color: Colors.white),
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFFE5E7EB),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: userPrimary),
            onPressed: () => Get.toNamed('/user/edit-profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profileHeader(user),
            const SizedBox(height: 28),
            _aiStyleHubCard(),
            const SizedBox(height: 32),
            _sectionTitle('MY ACCOUNT'),
            _accountTile(
              icon: Icons.calendar_today_rounded,
              title: 'My Appointments',
              subtitle: 'Upcoming & past bookings',
              onTap: () => Get.toNamed('/user/appointments'),
            ),
            _accountTile(
              icon: Icons.payment_rounded,
              title: 'Payment Methods',
              subtitle: 'Saved cards & UPI',
              onTap: () {},
            ),
            _accountTile(
              icon: Icons.favorite_rounded,
              title: 'Saved Styles & Salons',
              subtitle: 'Your favorites',
              onTap: () {},
            ),
            const SizedBox(height: 28),
            _sectionTitle('APP SETTINGS'),
            _switchTile(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              value: true,
            ),
            _accountTile(
              icon: Icons.lock_rounded,
              title: 'Privacy & Security',
              onTap: () => Get.toNamed('/user/settings'),
            ),
            const SizedBox(height: 40),
            _logoutButton(authController),
          ],
        ),
      ),
    );
  }

  // ---------------- UI PARTS ----------------

  Widget _profileHeader(User? user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: userPrimary.withOpacity(0.2),
              child: const Icon(Icons.person, size: 52),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: userPrimary,
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? 'User',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE5E7EB),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: const TextStyle(color: Color(0xFFE5E7EB)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: userPrimary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified_rounded, size: 16),
              SizedBox(width: 6),
              Text('PLATINUM MEMBER'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _aiStyleHubCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: userCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ AI Style Hub',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Discover styles tailored to your face & hair type.',
                  style: TextStyle(color: Color(0xFFE5E7EB)),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userPrimary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Get.toNamed('/user/assistant'),
                  child: const Text('View Recommendations'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.auto_awesome, size: 42),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE5E7EB),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _accountTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: userPrimary.withOpacity(0.15),
        child: Icon(icon, color: userPrimary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: userPrimary,
      value: value,
      onChanged: (_) {},
      title: Text(title),
      secondary: Icon(icon),
    );
  }

  Widget _logoutButton(AuthController authController) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.redAccent),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: authController.logout,
    );
  }
}
