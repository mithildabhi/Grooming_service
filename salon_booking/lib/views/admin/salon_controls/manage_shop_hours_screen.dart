import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/salon_controls_controller.dart';

class ManageShopHoursScreen extends StatelessWidget {
  const ManageShopHoursScreen({super.key});

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
          'Shop Hours',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        actions: [
          TextButton(
            onPressed: ctrl.applyMondayToAll,
            child: const Text(
              "Copy Mon to All",
              style: TextStyle(color: accent),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.shopHours.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildDayRow(context, ctrl, index);
                },
              );
            }),
          ),
          _buildSaveBar(ctrl),
        ],
      ),
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    SalonControlsController ctrl,
    int index,
  ) {
    final day = ctrl.shopHours[index];
    final isOpen = day.isOpen.value;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpen
              ? accent.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          day.day,
          style: TextStyle(
            color: isOpen ? textPrimary : Colors.white38,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Switch(
          value: isOpen,
          activeColor: accent,
          onChanged: (val) => ctrl.toggleDay(index, val),
        ),
        subtitle: isOpen
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildTimeButton(
                      context,
                      ctrl.formatTime(day.startTime.value),
                      (t) => ctrl.updateStartTime(index, t),
                      day.startTime.value,
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.white24,
                    ),
                    _buildTimeButton(
                      context,
                      ctrl.formatTime(day.endTime.value),
                      (t) => ctrl.updateEndTime(index, t),
                      day.endTime.value,
                    ),
                  ],
                ),
              )
            : const Text("Closed", style: TextStyle(color: Colors.white24)),
      ),
    );
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
              onPressed: ctrl.isSaving.value ? null : ctrl.saveShopHours,
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
                      "Save Changes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
