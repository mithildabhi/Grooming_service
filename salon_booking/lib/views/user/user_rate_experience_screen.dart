import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/booking_model.dart';
import '../../controllers/booking_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/ui/primary_button.dart';
import '../../widgets/ui/glass_card.dart';

class UserRateExperienceScreen extends StatefulWidget {
  const UserRateExperienceScreen({super.key});

  @override
  State<UserRateExperienceScreen> createState() =>
      _UserRateExperienceScreenState();
}

class _UserRateExperienceScreenState extends State<UserRateExperienceScreen> {
  final BookingController bookingController = Get.find<BookingController>();
  final TextEditingController feedbackController = TextEditingController();
  int selectedRating = 0;
  BookingModel? booking;

  @override
  void initState() {
    super.initState();
    booking = Get.arguments as BookingModel?;
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Rate Experience', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('No booking found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rate Experience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  /// ───────────── BOOKING INFO ─────────────
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.spa,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking!.salonName,
                                style: AppTextStyles.subHeading.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking!.serviceName,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /// ───────────── RATING ─────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'How was your experience?',
                          style: AppTextStyles.heading.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Stars(
                          selectedRating: selectedRating,
                          onRatingChanged: (rating) {
                            setState(() => selectedRating = rating);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (selectedRating > 0)
                          Text(
                            _getRatingText(selectedRating),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /// ───────────── FEEDBACK ─────────────
                  Text(
                    'Share your feedback (Optional)',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: TextField(
                      controller: feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Tell us about your experience...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ───────────── SUBMIT BUTTON ─────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: PrimaryButton(
              label: 'Submit Review',
              enabled: selectedRating > 0 && (booking?.id != null) == true,
              onPressed: () async {
                if (booking?.id == null) return;
                await bookingController.submitReview(
                  bookingId: booking!.id!,
                  rating: selectedRating,
                  feedback: feedbackController.text.trim(),
                );
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

/* ───────────────── STARS ───────────────── */

class _Stars extends StatelessWidget {
  final int selectedRating;
  final Function(int) onRatingChanged;

  const _Stars({
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.star,
              color: index < selectedRating
                  ? Colors.amber
                  : Colors.grey.withOpacity(0.3),
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
