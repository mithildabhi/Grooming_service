import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/booking_model.dart';
import '../../controllers/booking_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/primary_button.dart';
import '../../widgets/custom_snackbar.dart';

class UserAppointmentDetailsScreen extends StatelessWidget {
  const UserAppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final raw = Get.arguments;
    if (raw == null || raw is! BookingModel) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Details', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Booking not found')),
      );
    }
    final BookingModel booking = raw;
    final BookingController bookingController = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
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
                  /// ───────────── STATUS CARD ─────────────
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              booking.status,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(booking.status),
                            color: _getStatusColor(booking.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status', style: AppTextStyles.caption),
                              const SizedBox(height: 4),
                              Text(
                                booking.status,
                                style: AppTextStyles.subHeading.copyWith(
                                  color: _getStatusColor(booking.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── SALON INFO ─────────────
                  Text(
                    'Salon Information',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.salonName,
                          style: AppTextStyles.subHeading.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _DetailItem(
                          icon: Icons.spa,
                          label: 'Service',
                          value: booking.serviceName,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DetailItem(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: booking.date,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DetailItem(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: booking.time,
                        ),
                        if (booking.staffName != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _DetailItem(
                            icon: Icons.person,
                            label: 'Stylist',
                            value: booking.staffName!,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        _DetailItem(
                          icon: Icons.timer,
                          label: 'Duration',
                          value: '${booking.durationMinutes} minutes',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── PRICE ─────────────
                  Text(
                    'Payment',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total Amount',
                            style: AppTextStyles.body,
                          ),
                        ),
                        Text(
                          '₹${booking.price.toStringAsFixed(0)}',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          /// ───────────── ACTION BUTTONS ─────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                if (booking.status == 'CONFIRMED' ||
                    booking.status == 'PENDING')
                  PrimaryButton(
                    label: 'Cancel Appointment',
                    onPressed: () async {
                      if (booking.id == null) {
                        CustomSnackbar.show(
                          title: 'Error',
                          message: 'Invalid booking',
                          isError: true,
                        );
                        return;
                      }

                      final confirmed = await Get.dialog<bool>(
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: GlassCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.orange,
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Cancel Appointment',
                                    style: AppTextStyles.heading.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Are you sure you want to cancel this appointment?',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textPrimary,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Get.back(result: false),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppColors.textPrimary,
                                            side: const BorderSide(
                                              color: AppColors.divider,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'No',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              Get.back(result: true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Yes, Cancel',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        barrierDismissible: true,
                      );

                      if (confirmed == true) {
                        await bookingController.cancelBooking(booking.id!);
                        Get.back();
                      }
                    },
                  ),
                if (booking.status == 'COMPLETED' && !booking.isRated) ...[
                  const SizedBox(height: AppSpacing.sm),
                  PrimaryButton(
                    label: 'Rate Experience',
                    onPressed: () =>
                        Get.toNamed('/rate-experience', arguments: booking),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'COMPLETED':
        return Icons.done_all;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

/* ───────────────── DETAIL ITEM ───────────────── */

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Text('$label: ', style: AppTextStyles.caption),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
