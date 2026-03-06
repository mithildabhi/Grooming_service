import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/salon_controls_controller.dart';
import '../../../models/employee_model.dart';

class StaffScheduleScreen extends StatelessWidget {
  final EmployeeModel staff;
  const StaffScheduleScreen({super.key, required this.staff});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF151E27);
  static const Color accent = Color(0xFF19F6E8);
  static const Color textPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalonControlsController>();
    final schedule = ctrl.staffSchedules[staff.id];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "${staff.fullName}'s Schedule",
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: schedule == null
          ? const Center(
              child: Text(
                "No schedule found",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : Column(
              children: [
                // Staff info header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: accent.withOpacity(0.15),
                        radius: 24,
                        child: Text(
                          staff.fullName.isNotEmpty
                              ? staff.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.fullName,
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _capitalizeFirst(staff.role),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: schedule.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildScheduleRow(
                        context,
                        ctrl,
                        index,
                        schedule[index],
                      );
                    },
                  ),
                ),
                _buildSaveBar(ctrl),
              ],
            ),
    );
  }

  Widget _buildScheduleRow(
    BuildContext context,
    SalonControlsController ctrl,
    int index,
    StaffDaySchedule day,
  ) {
    return Obx(() {
      final isWorking = day.isWorking.value;
      return Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWorking
                ? accent.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Checkbox(
            value: isWorking,
            activeColor: accent,
            checkColor: bg,
            onChanged: (val) =>
                ctrl.toggleStaffDay(staff.id, index, val ?? false),
          ),
          title: Text(
            day.day,
            style: TextStyle(
              color: isWorking ? textPrimary : Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: isWorking
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildTimeButton(
                        context,
                        ctrl.formatTime(day.shiftStart.value),
                        (t) => ctrl.updateStaffShiftStart(staff.id, index, t),
                        day.shiftStart.value,
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.white24,
                      ),
                      _buildTimeButton(
                        context,
                        ctrl.formatTime(day.shiftEnd.value),
                        (t) => ctrl.updateStaffShiftEnd(staff.id, index, t),
                        day.shiftEnd.value,
                      ),
                    ],
                  ),
                )
              : const Text("Off Duty", style: TextStyle(color: Colors.white24)),
        ),
      );
    });
  }

  Widget _buildTimeButton(
    BuildContext context,
    String text,
    Function(TimeOfDay) onTimePicked,
    TimeOfDay initial,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: accent,
                  onPrimary: bg,
                  surface: card,
                  onSurface: textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onTimePicked(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 14, color: accent),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveBar(SalonControlsController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: ctrl.isSaving.value
                  ? null
                  : () => ctrl.saveStaffSchedule(staff.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: ctrl.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Save Schedule",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
