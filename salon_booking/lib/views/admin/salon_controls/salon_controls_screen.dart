import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/salon_controls_controller.dart';
import 'manage_blockouts_screen.dart';
import 'manage_service_duration_screen.dart';
import 'manage_shop_hours_screen.dart';
import 'manage_slots_screen.dart';
import 'staff_list_screen.dart';

class SalonControlsScreen extends StatelessWidget {
  const SalonControlsScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF151E27);
  static const Color accent = Color(0xFF19F6E8);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;

  @override
  Widget build(BuildContext context) {
    Get.put(SalonControlsController());

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Salon Controls',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            const Text(
              'Operations',
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            _buildControlTile(
              "Slot Management",
              "View & block specific slots",
              Icons.calendar_view_week,
              const Color(0xFF26A69A),
              () => Get.to(() => const ManageSlotsScreen()),
            ),
            _buildControlTile(
              "Operating Hours",
              "Set opening & closing times",
              Icons.access_time,
              accent,
              () => Get.to(() => const ManageShopHoursScreen()),
            ),
            _buildControlTile(
              "Staff Structure",
              "Manage roster & shifts",
              Icons.people_outline,
              const Color(0xFF6C63FF),
              () => Get.to(() => const StaffListScreen()),
            ),
            _buildControlTile(
              "Service Timing",
              "Duration & buffer times",
              Icons.timer_outlined,
              const Color(0xFFFFA726),
              () => Get.to(() => const ManageServiceDurationScreen()),
            ),
            _buildControlTile(
              "Holidays",
              "Blockout dates & leaves",
              Icons.event_busy,
              const Color(0xFFEF5350),
              () => Get.to(() => const ManageBlockoutsScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront, color: accent, size: 32),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Salon Manager",
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Configure your shop's core settings from one place.",
                  style: TextStyle(color: textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: textSecondary, fontSize: 13),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}
