import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../models/employee_model.dart';
import '../../controllers/booking_controller.dart';

import '../../services/staff_api.dart';
import '../../services/booking_api.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/primary_button.dart';

class UserSelectStaffScreen extends StatefulWidget {
  const UserSelectStaffScreen({super.key});

  @override
  State<UserSelectStaffScreen> createState() => _UserSelectStaffScreenState();
}

class _UserSelectStaffScreenState extends State<UserSelectStaffScreen> {
  late final BookingController bookingController;
  
  // Grouped Staff: Role -> List of (Staff, isAvailable, unavailabilityReason)
  Map<String, List<StaffAvailability>> categorizedStaff = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    bookingController = Get.find<BookingController>();
    _loadAndCategorizeStaff();
  }

  Future<void> _loadAndCategorizeStaff() async {
    final date = bookingController.selectedDate.value;
    final time = bookingController.selectedTime.value;
    final service = bookingController.selectedService.value;
    
    // Reset state
    categorizedStaff.clear();
    
    if (date == null) {
      setState(() => isLoading = false);
      return;
    }

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayAbbrev = dayNames[date.weekday - 1];

    try {
      final salon = bookingController.selectedSalon.value;
      if (salon == null) return;

      final allStaff = await StaffApi.fetchPublicStaff(salon.id);
      
      // Fetch Bookings for the day to check availability
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      List<Map<String, dynamic>> todayBookings = [];
      try {
        todayBookings = await BookingApi.fetchPublicSlots(salonId: salon.id, date: dateStr);
      } catch (e) {
        print('Error fetching bookings: $e');
      }

      for (final staff in allStaff) {
        // 1. Determine Availability
        bool isAvailable = true;
        String reason = '';

        // Check Working Days
        if (!staff.workingDays.contains(dayAbbrev)) {
          isAvailable = false;
          reason = 'Not working today';
        }

        // Check Shift Time & Existing Bookings
        if (isAvailable && time.isNotEmpty) {
          final parts = time.split(':');
          if (parts.length >= 2) {
            final slotHour = int.tryParse(parts[0]) ?? 0;
            final slotMin = int.tryParse(parts[1]) ?? 0;
            
            final slotStartMins = slotHour * 60 + slotMin;
            final duration = service?.duration ?? 30;
            final slotEndMins = slotStartMins + duration;

            // Check Shift
            final startMinutes = _timeToMins(staff.shiftStartTime);
            final endMinutes = _timeToMins(staff.shiftEndTime);

            // Shift check: Start time must be within shift (and ideally end time too, but keeping it loose for now)
            // Stricter check: Slot must start AFTER shift start and BEFORE shift end
            if (slotStartMins < startMinutes || slotStartMins >= endMinutes) {
              isAvailable = false;
              reason = 'Shift: ${_formatShiftTime(staff.shiftStartTime)} - ${_formatShiftTime(staff.shiftEndTime)}';
            }
            
            // Check Existing Bookings (Overlap)
            if (isAvailable) {
               final staffBookings = todayBookings.where((b) => b['staff'].toString() == staff.id.toString()).toList();
               for (final booking in staffBookings) {
                  final bStart = _timeToMins(booking['booking_time']);
                  final bEnd = _timeToMins(booking['end_time']);
                  
                  // Overlap check: (StartA < EndB) and (EndA > StartB)
                  if (slotStartMins < bEnd && slotEndMins > bStart) {
                     isAvailable = false;
                     reason = 'Already booked';
                     break;
                  }
               }
            }
          }
        }

        // 2. Group by Role
        final role = _capitalize(staff.role.isEmpty ? 'Staff' : staff.role);
        if (!categorizedStaff.containsKey(role)) {
          categorizedStaff[role] = [];
        }
        
        categorizedStaff[role]!.add(StaffAvailability(staff, isAvailable, reason));
      }
      
    } catch (_) {}

    setState(() => isLoading = false);
  }

  int _timeToMins(String timeStr) {
     try {
       final parts = timeStr.split(':');
       final h = int.parse(parts[0]);
       final m = int.parse(parts[1]); // Handles "09:00:00" too if split works, but split(':') gives 3 parts.
       // Use safe parsing
       return h * 60 + m;
     } catch (_) {
       return 0;
     }
  }

  @override
  Widget build(BuildContext context) {
    final salon = bookingController.selectedSalon.value;
    final service = bookingController.selectedService.value;
    final selectedTime = bookingController.selectedTime.value;
    final selectedDate = bookingController.selectedDate.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Choose Your Stylist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ───────────── BOOKING SUMMARY ─────────────
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.spa, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service?.name ?? 'Service',
                                style: AppTextStyles.subHeading.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedDate != null
                                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                                        : '--',
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.access_time, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedTime.isNotEmpty ? _formatTime(selectedTime) : '--',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${service?.price.toStringAsFixed(0) ?? '0'}',
                          style: AppTextStyles.subHeading.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── "ANY AVAILABLE" ─────────────
                  Obx(() {
                    final isSelected = bookingController.selectedStaff.value == null;
                    // Count total available staff across all categories
                    int totalAvailable = 0;
                    categorizedStaff.forEach((_, list) {
                      totalAvailable += list.where((s) => s.isAvailable).length;
                    });
                    
                    return _buildStaffCard(
                      name: 'Any Available',
                      subtitle: '$totalAvailable stylist${totalAvailable == 1 ? '' : 's'} available',
                      icon: Icons.groups_rounded,
                      isSelected: isSelected,
                      isAvailable: true,
                      onTap: () => bookingController.selectStaff(null),
                    );
                  }),

                  const SizedBox(height: AppSpacing.md),

                  /// ───────────── CATEGORIZED STAFF LIST ─────────────
                  if (isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else if (categorizedStaff.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No staff found for this salon.',
                          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...categorizedStaff.entries.map((entry) {
                      final category = entry.key;
                      final staffList = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 4, 
                                  height: 16, 
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: AppTextStyles.subHeading.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...staffList.map((staffWrapper) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Obx(() {
                                final isSelected = bookingController.selectedStaff.value?.id == staffWrapper.employee.id;
                                return _buildStaffCard(
                                  name: staffWrapper.employee.fullName,
                                  subtitle: staffWrapper.isAvailable
                                      ? '${_formatShiftTime(staffWrapper.employee.shiftStartTime)} – ${_formatShiftTime(staffWrapper.employee.shiftEndTime)}'
                                      : 'Unavailable: ${staffWrapper.unavailabilityReason}',
                                  role: _capitalize(staffWrapper.employee.primarySkill.replaceAll('_', ' ')), // Show expertise as subtitle/badge
                                  workingDays: staffWrapper.employee.workingDays,
                                  icon: Icons.person,
                                  isSelected: isSelected,
                                  isAvailable: staffWrapper.isAvailable,
                                  onTap: () {
                                    if (staffWrapper.isAvailable) {
                                      bookingController.selectStaff(staffWrapper.employee);
                                    } else {
                                      Get.snackbar(
                                        'Stylist Unavailable',
                                        'This stylist is not available at the selected time.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppColors.surface,
                                        colorText: Colors.white,
                                        margin: const EdgeInsets.all(16),
                                      );
                                    }
                                  },
                                );
                              }),
                            );
                          }),
                          const SizedBox(height: 8), 
                        ],
                      );
                    }),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          /// ───────────── CTA BAR ─────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                // Show selected stylist
                Obx(() {
                  final staff = bookingController.selectedStaff.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          staff?.fullName ?? 'Any Available Stylist',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
                PrimaryButton(
                  label: 'Continue to Review',
                  onPressed: () {
                    final selectedDate = bookingController.selectedDate.value;
                    Get.toNamed(
                      '/review-booking',
                      arguments: {
                        'salon': salon,
                        'date': selectedDate != null
                            ? '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'
                            : null,
                        'dateDisplay': selectedDate != null
                            ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                            : null,
                        'time': selectedTime,
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isAvailable,
    required VoidCallback onTap,
    String? role,
    List<String>? workingDays,
  }) {
    final double opacity = isAvailable ? 1.0 : 0.5;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.surface.withOpacity(isAvailable ? 1 : 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider.withOpacity(opacity),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.08 * opacity),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted.withOpacity(opacity),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.body.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (role != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              color: isAvailable ? AppColors.textSecondary : AppColors.error.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Radio indicator
            if (isAvailable)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 14)
                    : null,
              )
            else
              const Icon(Icons.block, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour12:$minute $period';
    } catch (e) {
      return time;
    }
  }

  String _formatShiftTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = parts[1];
      final period = h >= 12 ? 'PM' : 'AM';
      final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$h12:$m $period';
    }
    return time;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class StaffAvailability {
  final EmployeeModel employee;
  final bool isAvailable;
  final String unavailabilityReason;

  StaffAvailability(this.employee, this.isAvailable, this.unavailabilityReason);
}
