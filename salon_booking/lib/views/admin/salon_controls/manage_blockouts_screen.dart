import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/salon_controls_controller.dart';

class ManageBlockoutsScreen extends StatelessWidget {
  const ManageBlockoutsScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF151E27);
  static const Color accent = Color(0xFFEF5350);
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
          'Holidays & Blockouts',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        onPressed: () => _pickDate(context, ctrl),
        icon: const Icon(Icons.add),
        label: const Text("Add Holiday"),
      ),
      body: Obx(() {
        if (ctrl.blockoutDates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Blockout Dates',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.blockoutDates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildDateTile(ctrl, ctrl.blockoutDates[index], index);
          },
        );
      }),
    );
  }

  Widget _buildDateTile(
    SalonControlsController ctrl,
    DateTime date,
    int index,
  ) {
    final isPast = date.isBefore(DateTime.now());
    return Dismissible(
      key: ValueKey(date),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent.withOpacity(0.2),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      onDismissed: (_) => ctrl.removeBlockoutDate(index),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: accent, size: 20),
          ),
          title: Text(
            _formatDate(date),
            style: TextStyle(
              color: isPast ? Colors.white38 : textPrimary,
              fontWeight: FontWeight.w600,
              decoration: isPast ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            _weekday(date) + (isPast ? " (Past)" : ""),
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white24),
            onPressed: () => ctrl.removeBlockoutDate(index),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    SalonControlsController ctrl,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accent,
              onPrimary: Colors.white,
              surface: card,
              onSurface: textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ctrl.addBlockoutDate(picked);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  String _weekday(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[d.weekday - 1];
  }
}
