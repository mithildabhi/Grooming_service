import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/salon_model.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/primary_button.dart';

class UserBookingSuccessScreen extends StatelessWidget {
  const UserBookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;

    final SalonModel? salon = args?['salon'] as SalonModel?;
    final String? date = args?['date'] as String?;
    final String? time = args?['time'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ───────────── SUCCESS ANIMATION ─────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ───────────── TITLE ─────────────
              Text(
                'Booking Confirmed!',
                style: AppTextStyles.heading.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Your appointment has been successfully booked. We\'ll send you a confirmation shortly.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ───────────── SUMMARY CARD ─────────────
              if (salon != null && date != null && time != null)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              salon.imageUrl.isNotEmpty ? salon.imageUrl : 'https://via.placeholder.com/60',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: AppColors.surface,
                                child: const Icon(Icons.spa, color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  salon.name,
                                  style: AppTextStyles.subHeading.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$date • $time',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              /// ───────────── ACTIONS ─────────────
              PrimaryButton(
                label: 'View Appointments',
                onPressed: () {
                  Get.offAllNamed('/user', arguments: {'tab': 2});
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              TextButton(
                onPressed: () => Get.offAllNamed('/user'),
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
