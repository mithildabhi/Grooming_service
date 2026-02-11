import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/salon_controls_controller.dart';
import 'package:intl/intl.dart';

class ManageSlotsScreen extends StatefulWidget {
  const ManageSlotsScreen({super.key});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  final SalonControlsController ctrl = Get.find<SalonControlsController>();
  DateTime selectedDate = DateTime.now();
  int slotDuration = 30; // Default slot size

  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayFormat = DateFormat('EEE, d MMM');

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0F14);
    const textPrimary = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Manage Slots',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: Column(
        children: [
          _buildDateSelector(bg, textPrimary),
          const SizedBox(height: 16),
          _buildFilterBar(bg, textPrimary),
          const SizedBox(height: 16),
          Expanded(child: _buildSlotsGrid()),
        ],
      ),
    );
  }

  Widget _buildDateSelector(Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF151E27),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(
              () =>
                  selectedDate = selectedDate.subtract(const Duration(days: 1)),
            ),
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: const Color(0xFF19F6E8),
                        onPrimary: bg,
                        surface: const Color(0xFF151E27),
                        onSurface: text,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
            child: Column(
              children: [
                Text(
                  _monthFormat.format(selectedDate),
                  style: TextStyle(color: text.withOpacity(0.5), fontSize: 12),
                ),
                Text(
                  _dayFormat.format(selectedDate),
                  style: TextStyle(
                    color: text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(
              () => selectedDate = selectedDate.add(const Duration(days: 1)),
            ),
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(Color bg, Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text("Slot Duration:", style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: slotDuration,
            dropdownColor: const Color(0xFF151E27),
            style: TextStyle(color: text),
            underline: Container(height: 1, color: const Color(0xFF19F6E8)),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF19F6E8)),
            items: [15, 30, 45, 60, 90, 120].map((e) {
              return DropdownMenuItem(value: e, child: Text("$e min"));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => slotDuration = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsGrid() {
    return Obx(() {
      // Rebuild when these change
      // ignore: unused_local_variable
      final _ = ctrl.manualBlockedSlots.length + ctrl.manualAddedSlots.length;

      final slots = ctrl.generateSlotsForDate(selectedDate, slotDuration);

      if (slots.isEmpty) {
        // Should realistically not happen with new logic unless shop closed AND no staff AND no manual AND default range is empty.
        // But my updated logic has a default range, so slots should exist unless filtered out.
        return Center(
          child: Text(
            "No slots generated for this view.",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          80,
        ), // Bottom padding for FAB/BottomBar
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.0,
        ),
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          return _buildSlotChip(slot);
        },
      );
    });
  }

  Widget _buildSlotChip(TimeSlot slot) {
    Color color;
    Color textColor = Colors.white;
    Color borderColor = Colors.transparent;

    switch (slot.status) {
      case 'available':
        color = const Color(0xFF19F6E8).withOpacity(0.15);
        textColor = const Color(0xFF19F6E8);
        borderColor = const Color(0xFF19F6E8).withOpacity(0.3);
        break;
      case 'blocked_manual':
        color = const Color(0xFFFFA726).withOpacity(0.15);
        textColor = const Color(0xFFFFA726);
        borderColor = const Color(0xFFFFA726).withOpacity(0.3);
        break;
      case 'forced_open':
        color = const Color(0xFF448AFF).withOpacity(0.2);
        textColor = const Color(0xFF448AFF);
        borderColor = const Color(0xFF448AFF).withOpacity(0.3);
        break;
      case 'closed':
      case 'no_staff':
      default:
        color = const Color(0xFFEF5350).withOpacity(0.1);
        textColor = const Color(0xFFEF5350).withOpacity(0.6);
        borderColor = const Color(0xFFEF5350).withOpacity(0.1);
    }

    return InkWell(
      onTap: () => ctrl.toggleSlotStatus(selectedDate, slot.time, slot.status),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ctrl.formatTime(slot.time),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (slot.status == 'available' || slot.status == 'forced_open')
                  Text(
                    "${slot.capacity} Staff",
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  )
                else if (slot.status == 'blocked_manual')
                  const Text(
                    "Blocked",
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  )
                else
                  const Text(
                    "Closed",
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
              ],
            ),
          ),
          if (slot.capacity > 0 &&
              (slot.status == 'available' || slot.status == 'forced_open'))
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF151E27),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${slot.capacity}",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(SalonControlsController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => ctrl.resetChangesForDate(selectedDate),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Reset Date"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isSaving.value ? null : ctrl.saveSlotChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19F6E8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
          ],
        ),
      ),
    );
  }
}
