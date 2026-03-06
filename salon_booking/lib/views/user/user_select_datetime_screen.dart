import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/salon_model.dart';
import '../../controllers/booking_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/ai_insight_card.dart';
import '../../widgets/ui/primary_button.dart';
import '../../widgets/ui/glass_card.dart';

class UserSelectDateTimeScreen extends StatefulWidget {
  const UserSelectDateTimeScreen({super.key});

  @override
  State<UserSelectDateTimeScreen> createState() =>
      _UserSelectDateTimeScreenState();
}

class _UserSelectDateTimeScreenState extends State<UserSelectDateTimeScreen> {
  SalonModel? salon;
  late final BookingController bookingController;

  DateTime? selectedDate;
  String? selectedTime;
  int selectedMonthOffset = 0;

  @override
  void initState() {
    super.initState();
    bookingController = Get.find<BookingController>();
    final args = Get.arguments;
    salon = args is SalonModel ? args : null;
    
    // ✅ Ensure controller has the correct salon
    if (salon != null) {
      bookingController.selectedSalon.value = salon;
    }
    
    // ✅ FIX: AUTO-SELECT TODAY'S DATE on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now();
      setState(() {
        selectedDate = today;
      });
      // ✅ Generate time slots for today automatically
      bookingController.selectDate(today);
      print('✅ Auto-selected today: ${today.toString().split(' ')[0]}');
      print('⏰ Current time: ${today.hour}:${today.minute}');
    });
  }

  DateTime get _currentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + selectedMonthOffset, 1);
  }

  List<DateTime?> _getCalendarDays() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    
    List<DateTime?> days = [];
    
    // Add empty slots for days before the first day of month
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }
    
    // Add all days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }
    
    return days;
  }

  // ✅ FIXED: Allow selecting today OR future dates
  bool _isDateSelectable(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    // ✅ Can select today or future dates
    return dateOnly.isAtSameMomentAs(today) || dateOnly.isAfter(today);
  }

  String _formatDateDisplay(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  // ✅ FIXED: Group time slots by period with PROPER filtering
  Map<String, List<String>> _groupTimeSlots() {
    Map<String, List<String>> grouped = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };
    
    // ✅ Get times from observable list
    final times = bookingController.availableTimeSlots.toList();
    
    for (var time in times) {
      try {
        final hour = int.parse(time.split(':')[0]);
        if (hour < 12) {
          grouped['Morning']!.add(time);
        } else if (hour < 17) {
          grouped['Afternoon']!.add(time);
        } else {
          grouped['Evening']!.add(time);
        }
      } catch (_) {}
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final s = salon;
    if (s == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Select Date & Time', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Salon not found')),
      );
    }
    final service = bookingController.selectedService.value;
    final bool canContinue = selectedDate != null && selectedTime != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Date & Time', style: TextStyle(color: Colors.white)),
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
                  /// ───────────── SALON INFO ─────────────
                  GlassCard(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            s.imageUrl.isNotEmpty
                                ? s.imageUrl
                                : 'https://via.placeholder.com/60',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.spa,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: AppTextStyles.subHeading.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (service != null) ...[
                                const SizedBox(height: 4),
                                Text(service.name, style: AppTextStyles.body),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '₹${service.price.toStringAsFixed(0)}',
                                      style: AppTextStyles.subHeading.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.durationMinutes} min',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── AI INSIGHT ─────────────
                  const AiInsightCard(
                    title: 'AI Recommendation',
                    description:
                        'Weekday afternoons have shorter wait times and better availability.',
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── CALENDAR DATE PICKER ─────────────
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        // Month Navigation Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: selectedMonthOffset > 0
                                  ? () => setState(() => selectedMonthOffset--)
                                  : null,
                              icon: Icon(
                                Icons.chevron_left,
                                color: selectedMonthOffset > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted.withOpacity(0.3),
                              ),
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(_currentMonth),
                              style: AppTextStyles.subHeading.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: selectedMonthOffset < 2
                                  ? () => setState(() => selectedMonthOffset++)
                                  : null,
                              icon: Icon(
                                Icons.chevron_right,
                                color: selectedMonthOffset < 2
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Day names header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                            return SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  day,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Calendar grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: _getCalendarDays().length,
                          itemBuilder: (context, index) {
                            final date = _getCalendarDays()[index];
                            if (date == null) {
                              return const SizedBox();
                            }
                            
                            final isSelectable = _isDateSelectable(date);
                            final isSelected = selectedDate != null &&
                                selectedDate!.day == date.day &&
                                selectedDate!.month == date.month &&
                                selectedDate!.year == date.year;
                            final isToday = DateTime.now().day == date.day &&
                                DateTime.now().month == date.month &&
                                DateTime.now().year == date.year;
                            
                            return GestureDetector(
                              onTap: isSelectable
                                  ? () {
                                      setState(() {
                                        selectedDate = date;
                                        selectedTime = null; // Reset time when date changes
                                      });
                                      // ✅ Generate time slots with filtering
                                      bookingController.selectDate(date);
                                    }
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isToday
                                          ? AppColors.primary.withOpacity(0.2)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isToday && !isSelected
                                      ? Border.all(color: AppColors.primary, width: 1)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    date.day.toString(),
                                    style: AppTextStyles.body.copyWith(
                                      color: isSelected
                                          ? Colors.black
                                          : isSelectable
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted.withOpacity(0.3),
                                      fontWeight: isSelected || isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Selected Date Display
                  if (selectedDate != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateDisplay(selectedDate!),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── TIME SELECTION ─────────────
                  Text(
                    'Select Time Slot',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ✅ FIXED: Proper Obx usage watching the controller's observable
                  Obx(() {
                    if (selectedDate == null) {
                      return GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Please select a date first',
                              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // ✅ Watch isLoadingSlots observable
                    if (bookingController.isLoadingSlots.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    
                    // ✅ Watch availableTimeSlots observable
                    if (bookingController.availableTimeSlots.isEmpty) {
                      return GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Icon(Icons.event_busy, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No time slots available for this date',
                              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final groupedSlots = _groupTimeSlots();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedSlots.entries.where((e) => e.value.isNotEmpty).map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  entry.key == 'Morning'
                                      ? Icons.wb_sunny
                                      : entry.key == 'Afternoon'
                                          ? Icons.wb_cloudy
                                          : Icons.nights_stay,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: entry.value.map((t) {
                                final isSelected = selectedTime == t;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTime = t;
                                    });
                                    bookingController.selectTime(t);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.divider,
                                      ),
                                    ),
                                    child: Text(
                                      _formatTime(t),
                                      style: AppTextStyles.body.copyWith(
                                        color: isSelected
                                            ? Colors.black
                                            : AppColors.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      }).toList(),
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
                // Selection Summary
                if (selectedDate != null || selectedTime != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        if (selectedDate != null) ...[
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('d MMM').format(selectedDate!),
                                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (selectedTime != null) ...[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.access_time, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(selectedTime!),
                                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                PrimaryButton(
                  label: canContinue ? 'Choose Stylist' : 'Select Date & Time',
                  enabled: canContinue,
                  onPressed: canContinue
                      ? () {
                          Get.toNamed('/select-staff');
                        }
                      : () {},
                ),
              ],
            ),
          ),
        ],
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
}