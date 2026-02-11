import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/salon_controls_controller.dart';

class ManageServiceDurationScreen extends StatelessWidget {
  const ManageServiceDurationScreen({super.key});

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
          'Service Durations',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.serviceList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildServiceTile(
                    context,
                    ctrl,
                    ctrl.serviceList[index],
                  );
                },
              );
            }),
          ),
          _buildSaveBar(ctrl),
        ],
      ),
    );
  }

  Widget _buildServiceTile(
    BuildContext context,
    SalonControlsController ctrl,
    DummyService service,
  ) {
    return Obx(() {
      final duration = ctrl.serviceDurations[service.id] ?? 30;
      final buffer = ctrl.serviceBufferTimes[service.id] ?? 0;

      return Container(
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
          onTap: () =>
              _showDurationSheet(context, ctrl, service, duration, buffer),
          leading: CircleAvatar(
            backgroundColor: _categoryColor(service.category).withOpacity(0.15),
            child: Icon(
              _categoryIcon(service.category),
              color: _categoryColor(service.category),
              size: 20,
            ),
          ),
          title: Text(
            service.name,
            style: const TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            "${service.category} • ₹${service.price.toInt()}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$duration min",
                  style: const TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (buffer > 0)
                  Text(
                    "+$buffer buffer",
                    style: TextStyle(
                      color: accent.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showDurationSheet(
    BuildContext context,
    SalonControlsController ctrl,
    DummyService service,
    int currentDuration,
    int currentBuffer,
  ) {
    int selectedDuration = currentDuration;
    int selectedBuffer = currentBuffer;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    service.name,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Service Duration",
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [15, 30, 45, 60, 90, 120].map((d) {
                      final isSelected = d == selectedDuration;
                      return ChoiceChip(
                        label: Text("$d min"),
                        selected: isSelected,
                        onSelected: (v) => setState(() => selectedDuration = d),
                        selectedColor: accent,
                        backgroundColor: bg,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? accent : Colors.white12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Buffer Time (Cleanup)",
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [0, 5, 10, 15, 20, 30].map((b) {
                      final isSelected = b == selectedBuffer;
                      return ChoiceChip(
                        label: Text(b == 0 ? "None" : "+$b min"),
                        selected: isSelected,
                        onSelected: (v) => setState(() => selectedBuffer = b),
                        selectedColor: const Color(0xFFFFA726),
                        backgroundColor: bg,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFFFA726)
                                : Colors.white12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.updateServiceDuration(
                          service.id,
                          selectedDuration,
                        );
                        ctrl.updateServiceBufferTime(
                          service.id,
                          selectedBuffer,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Apply Changes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
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
              onPressed: ctrl.isSaving.value ? null : ctrl.saveServiceDurations,
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
                      "Save Durations",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // Icons Helper
  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hair':
        return Icons.content_cut;
      case 'grooming':
        return Icons.face_retouching_natural;
      case 'skin':
        return Icons.spa;
      case 'nails':
        return Icons.brush;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hair':
        return const Color(0xFF19F6E8);
      case 'grooming':
        return const Color(0xFF6C63FF);
      case 'skin':
        return const Color(0xFFFF6B9D);
      case 'nails':
        return const Color(0xFFFFA726);
      default:
        return Colors.blueGrey;
    }
  }
}
