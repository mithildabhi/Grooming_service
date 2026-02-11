import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/employee_screen.dart';
import 'package:salon_booking/views/admin/services_screen.dart';
import 'package:salon_booking/views/admin/settings_screen.dart';
import 'package:salon_booking/views/admin/salon_controls/salon_controls_screen.dart';
import '../../controllers/admin_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Brand Colors
  static const Color bg = Color(0xFF0B0F14);
  static const Color accent = Color(0xFF19F6E8);
  static const Color cardColor = Color(0xFF151E27);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminCtrl = Get.find<AdminController>();
      if (!adminCtrl.hasProfile && !adminCtrl.isLoadingProfile.value) {
        adminCtrl.loadSalonProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AdminController adminCtrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: bg,
      body: Obx(() {
        if (adminCtrl.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator(color: accent));
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(adminCtrl),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!adminCtrl.hasProfile) _buildNoProfileState(adminCtrl),
                    if (adminCtrl.hasProfile) ...[
                      _buildStatsRow(),
                      const SizedBox(height: 32),
                      _buildInfoSection(adminCtrl),
                      const SizedBox(height: 32),
                      _buildQuickActionsTitle(),
                      const SizedBox(height: 16),
                      _buildQuickActionsGrid(adminCtrl),
                      const SizedBox(height: 40),
                      _buildLogoutButton(adminCtrl),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(AdminController adminCtrl) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: bg,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1F29), bg],
                ),
              ),
            ),
            // Decorative Circles
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.1),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Profile Content
            if (adminCtrl.hasProfile)
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Avatar with Glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: cardColor,
                        backgroundImage: adminCtrl.imageUrl.isNotEmpty
                            ? NetworkImage(adminCtrl.imageUrl)
                            : const NetworkImage("https://i.pravatar.cc/300"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      adminCtrl.salonName,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withOpacity(0.2)),
                      ),
                      child: const Text(
                        "Salon Owner • AI Active",
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: textPrimary),
          onPressed: adminCtrl.openEditProfile,
          tooltip: 'Edit Profile',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: textPrimary),
          onPressed: adminCtrl.loadSalonProfile,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem("Revenue", "₹4.2K", Icons.currency_rupee),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem("Retention", "88%", Icons.repeat)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem("Stock Low", "2", Icons.inventory_2_outlined),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent.withOpacity(0.8), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(AdminController adminCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contact Info",
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildInfoTile(
                Icons.email_outlined,
                "Email",
                adminCtrl.ownerEmail,
              ),
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
              _buildInfoTile(Icons.phone_outlined, "Phone", adminCtrl.phone),
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
              _buildInfoTile(
                Icons.location_on_outlined,
                "Location",
                adminCtrl.location,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: textSecondary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: textSecondary, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsTitle() {
    return const Text(
      "Management",
      style: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuickActionsGrid(AdminController adminCtrl) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildActionCard(
          "Staff",
          "Manage Team",
          Icons.people_outline,
          const Color(0xFF6C63FF),
          () => Get.to(() => const EmployeeScreen()),
        ),
        _buildActionCard(
          "Services",
          "Menu & Pricing",
          Icons.spa_outlined,
          const Color(0xFFFF6B9D),
          () => Get.to(() => const ServicesScreen()),
        ),
        _buildActionCard(
          "Revenue",
          "Track Earnings",
          Icons.pie_chart_outline,
          const Color(0xFFFFA726),
          () => Get.toNamed('/admin/revenue'),
        ),
        _buildActionCard(
          "Controls",
          "Shop & Hours",
          Icons.tune,
          const Color(0xFF19F6E8),
          () => Get.to(() => const SalonControlsScreen()),
        ),
        _buildActionCard(
          "Settings",
          "App Config",
          Icons.settings_outlined,
          Colors.blueGrey,
          () => Get.to(() => const SettingsScreen()),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoProfileState(AdminController adminCtrl) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 60,
              color: accent.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome, Admin',
              style: TextStyle(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your salon profile to start managing your business.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: adminCtrl.openEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Create Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AdminController adminCtrl) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, size: 20),
        label: const Text("Logout"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          // Simplified logout dialog for modern feel
          Get.dialog(
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: textPrimary),
                ),
                content: const Text(
                  "Are you sure you want to sign out?",
                  style: TextStyle(color: textSecondary),
                ),
                actions: [
                  TextButton(
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: textSecondary),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Get.back(); // close dialog
                      await adminCtrl.logout();
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
