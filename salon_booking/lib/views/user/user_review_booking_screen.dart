import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/salon_model.dart';
import '../../controllers/booking_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/primary_button.dart';

class UserReviewBookingScreen extends StatelessWidget {
  const UserReviewBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final raw = Get.arguments;
    if (raw == null || raw is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review'), backgroundColor: AppColors.background),
        body: const Center(child: Text('Invalid data')),
      );
    }
    final args = raw;
    final BookingController bookingController = Get.find<BookingController>();

    final SalonModel? salon = args['salon'] is SalonModel ? args['salon'] as SalonModel : null;
    final String? date = args['date'] as String?;
    final String? dateDisplay = args['dateDisplay'] as String?;
    final String? time = args['time'] as String?;

    if (salon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review'), backgroundColor: AppColors.background),
        body: const Center(child: Text('Salon not found')),
      );
    }

    final service = bookingController.selectedService.value;
    final serviceName = service?.name ?? 'Service';
    final servicePrice = service?.price ?? 0.0;
    final duration = service?.durationMinutes ?? 30;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Booking'),
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
                  /// ───────────── SALON SUMMARY ─────────────
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            salon.imageUrl.isNotEmpty ? salon.imageUrl : 'https://via.placeholder.com/80',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: AppColors.surface,
                              child: const Icon(Icons.spa, size: 40, color: AppColors.primary),
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      salon.address,
                                      style: AppTextStyles.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── BOOKING DETAILS ─────────────
                  Text(
                    'Booking Details',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.spa,
                          label: 'Service',
                          value: serviceName,
                        ),
                        const Divider(height: 24),
                        if (dateDisplay != null)
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: dateDisplay,
                          ),
                        if (dateDisplay != null) const Divider(height: 24),
                        if (time != null)
                          _DetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value: time,
                          ),
                        if (time != null) const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.timer,
                          label: 'Duration',
                          value: '$duration minutes',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.person,
                          label: 'Stylist',
                          value: bookingController.selectedStaff.value?.fullName ??
                              'Any Available',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── PRICE BREAKDOWN ─────────────
                  Text(
                    'Price Breakdown',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _PriceRow(label: 'Service', value: '₹${servicePrice.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Tax', value: '₹0'),
                        const Divider(height: 24),
                        _PriceRow(
                          label: 'Total',
                          value: '₹${servicePrice.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
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
              label: 'Proceed to Payment',
              onPressed: () {
                Get.toNamed('/payment', arguments: {
                  'salon': salon,
                  'date': date,
                  'dateDisplay': dateDisplay,
                  'time': time,
                  'amount': servicePrice,
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── DETAIL ROW ───────────────── */

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label, style: AppTextStyles.body),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/* ───────────────── PRICE ROW ───────────────── */

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : AppTextStyles.body,
          ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.heading.copyWith(
                  color: AppColors.primary,
                )
              : AppTextStyles.subHeading,
        ),
      ],
    );
  }
}
