import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();
    bookingController = Get.find<BookingController>();
    final args = Get.arguments;
    salon = args is SalonModel ? args : null;
    _generateAvailableDates();
    if (bookingController.selectedService.value != null) {
      bookingController.generateTimeSlots(DateTime.now());
    }
  }

  List<DateTime> _availableDates = [];

  void _generateAvailableDates() {
    final now = DateTime.now();
    _availableDates = List.generate(14, (index) {
      return now.add(Duration(days: index + 1));
    });
  }

  String _formatDateShort(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]} ${date.day}';
  }

  List<String> get _availableTimes {
    if (selectedDate == null) return [];
    return bookingController.availableTimeSlots.toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = salon;
    if (s == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Select Date & Time'),
          backgroundColor: AppColors.background,
        ),
        body: const Center(child: Text('Salon not found')),
      );
    }
    final service = bookingController.selectedService.value;
    final bool canContinue = selectedDate != null && selectedTime != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        backgroundColor: AppColors.background,
        elevation: 0,
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
                                Text(
                                  '₹${service.price.toStringAsFixed(0)}',
                                  style: AppTextStyles.subHeading.copyWith(
                                    color: AppColors.primary,
                                  ),
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

                  /// ───────────── DATE SELECTION ─────────────
                  Text(
                    'Select Date',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableDates.length,
                      itemBuilder: (context, index) {
                        final date = _availableDates[index];
                        final isSelected =
                            selectedDate?.day == date.day &&
                            selectedDate?.month == date.month;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                              bookingController.selectDate(date);
                            });
                          },
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            child: GlassCard(
                              padding: const EdgeInsets.all(8),
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.15)
                                  : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatDateShort(date),
                                    style: AppTextStyles.caption.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date.day.toString(),
                                    style: AppTextStyles.subHeading.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── TIME SELECTION ─────────────
                  Text(
                    'Select Time',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Obx(() {
                    final times = _availableTimes;
                    if (times.isEmpty && selectedDate != null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (times.isEmpty) {
                      return GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'Select a date first',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: times.map((t) {
                        final isSelected = selectedTime == t;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTime = t;
                              bookingController.selectTime(t);
                            });
                          },
                          child: GlassCard(
                            width: 100,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.15)
                                : null,
                            child: Text(
                              _formatTime(t),
                              style: AppTextStyles.body.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
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
            child: PrimaryButton(
              label: canContinue ? 'Continue' : 'Select Date & Time',
              onPressed: canContinue
                  ? () {
                      Get.toNamed(
                        '/review-booking',
                        arguments: {
                          'salon': s,
                          'date': selectedDate != null
                              ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                              : null,
                          'dateDisplay': selectedDate != null
                              ? _formatDateShort(selectedDate!)
                              : null,
                          'time': selectedTime,
                        },
                      );
                    }
                  : () {},
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
