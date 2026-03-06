import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../../../controllers/salon_controls_controller.dart';
import '../../../models/employee_model.dart';
import 'staff_schedule_screen.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF151E27);
  static const Color accent = Color(0xFF19F6E8);
  static const Color textPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Staff Structure',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: Obx(() {
        final staffList = adminCtrl.staffList
            .where((s) => s.isActive)
            .toList();

        if (adminCtrl.isLoadingStaff.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        if (staffList.isEmpty) {
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
                  "No active staff members",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add staff from Employee Management",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: staffList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildStaffTile(staffList[index]);
          },
        );
      }),
    );
  }

  Widget _buildStaffTile(EmployeeModel staff) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: () => Get.to(() => StaffScheduleScreen(staff: staff)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.15),
          child: Text(
            staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          staff.fullName,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _capitalizeFirst(staff.role),
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: staff.workingDays.map((day) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    day,
                    style: const TextStyle(color: accent, fontSize: 10),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.schedule,
          color: accent,
          size: 20,
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
