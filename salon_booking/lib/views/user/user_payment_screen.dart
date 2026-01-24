import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/salon_model.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/user_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/primary_button.dart';

class UserPaymentScreen extends StatefulWidget {
  const UserPaymentScreen({super.key});

  @override
  State<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends State<UserPaymentScreen> {
  String selectedPaymentMethod = 'card';

  @override
  Widget build(BuildContext context) {
    final raw = Get.arguments;
    if (raw == null || raw is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment'), backgroundColor: AppColors.background),
        body: const Center(child: Text('Invalid data')),
      );
    }
    final args = raw;
    final BookingController bookingController = Get.find<BookingController>();
    final UserController userController = Get.find<UserController>();

    final SalonModel? salon = args['salon'] is SalonModel ? args['salon'] as SalonModel : null;
    final String? date = args['date'] as String?;
    final String? dateDisplay = args['dateDisplay'] as String?;
    final String? time = args['time'] as String?;
    final double amount = (args['amount'] as num?)?.toDouble() ?? 0.0;

    if (salon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment'), backgroundColor: AppColors.background),
        body: const Center(child: Text('Salon not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment'),
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
                  /// ───────────── BOOKING SUMMARY ─────────────
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
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
                              if (dateDisplay != null && time != null)
                                Text(
                                  '$dateDisplay • $time',
                                  style: AppTextStyles.caption,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── PAYMENT METHOD ─────────────
                  Text(
                    'Payment Method',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    onTap: () => setState(() => selectedPaymentMethod = 'card'),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    color: selectedPaymentMethod == 'card'
                        ? AppColors.primary.withOpacity(0.1)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Text(
                            'Credit / Debit Card',
                            style: AppTextStyles.body,
                          ),
                        ),
                        if (selectedPaymentMethod == 'card')
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    onTap: () => setState(() => selectedPaymentMethod = 'upi'),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    color: selectedPaymentMethod == 'upi'
                        ? AppColors.primary.withOpacity(0.1)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Text(
                            'UPI / Wallet',
                            style: AppTextStyles.body,
                          ),
                        ),
                        if (selectedPaymentMethod == 'upi')
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
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
                        _PriceRow(label: 'Service', value: '₹${amount.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Tax', value: '₹0'),
                        const Divider(height: 24),
                        _PriceRow(
                          label: 'Total',
                          value: '₹${amount.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ───────────── PAY CTA ─────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Obx(() => PrimaryButton(
              label: bookingController.isCreatingBooking.value
                  ? 'Processing...'
                  : 'Pay ₹${amount.toStringAsFixed(0)}',
              enabled: !bookingController.isCreatingBooking.value,
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Get.snackbar('Error', 'Please login to continue');
                  return;
                }

                final success = await bookingController.createBooking(
                  customerName: userController.userName.value.isNotEmpty
                      ? userController.userName.value
                      : user.displayName ?? 'User',
                  customerPhone: userController.userPhone.value.isNotEmpty
                      ? userController.userPhone.value
                      : user.phoneNumber ?? '',
                );

                if (success) {
                  Get.offNamed('/booking-success', arguments: {
                    'salon': salon,
                    'date': dateDisplay ?? date,
                    'time': time,
                  });
                }
              },
            )),
          ),
        ],
      ),
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
