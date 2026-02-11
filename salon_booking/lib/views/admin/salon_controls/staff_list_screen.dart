import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/salon_controls_controller.dart';
import 'staff_schedule_screen.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF151E27);
  static const Color accent = Color(0xFF19F6E8);
  static const Color textPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalonControlsController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Staff Management',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: Obx(() {
        if (ctrl.staffList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Staff Members',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.staffList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final staff = ctrl.staffList[index];
            return _buildStaffTile(staff);
          },
        );
      }),
    );
  }

  Widget _buildStaffTile(DummyStaff staff) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: ListTile(
        onTap: () => Get.to(() => StaffScheduleScreen(staff: staff)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.1),
          child: Text(
            staff.name.isNotEmpty ? staff.name[0] : '?',
            style: const TextStyle(color: accent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          staff.name,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          staff.role,
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Schedule",
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
