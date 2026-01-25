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
  String selectedPaymentMethod = 'cash';  // Default to cash

  @override
  Widget build(BuildContext context) {
    final raw = Get.arguments;
    if (raw == null || raw is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
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
        appBar: AppBar(
          title: const Text('Payment', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Salon not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
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
                    'Select Payment Method',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Cash Payment Option
                  _PaymentMethodCard(
                    icon: Icons.payments_outlined,
                    title: 'Pay at Salon (Cash)',
                    subtitle: 'Pay when you visit the salon',
                    isSelected: selectedPaymentMethod == 'cash',
                    onTap: () => setState(() => selectedPaymentMethod = 'cash'),
                    badge: 'Recommended',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Online Payment Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'OR PAY ONLINE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                  ),

                  // Card Payment Option
                  _PaymentMethodCard(
                    icon: Icons.credit_card,
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa, Mastercard, RuPay',
                    isSelected: selectedPaymentMethod == 'card',
                    onTap: () => setState(() => selectedPaymentMethod = 'card'),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // UPI Payment Option
                  _PaymentMethodCard(
                    icon: Icons.account_balance,
                    title: 'UPI',
                    subtitle: 'GPay, PhonePe, Paytm, BHIM',
                    isSelected: selectedPaymentMethod == 'upi',
                    onTap: () => setState(() => selectedPaymentMethod = 'upi'),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Net Banking Option
                  _PaymentMethodCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Net Banking',
                    subtitle: 'All major banks supported',
                    isSelected: selectedPaymentMethod == 'netbanking',
                    onTap: () => setState(() => selectedPaymentMethod = 'netbanking'),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// ───────────── PRICE BREAKDOWN ─────────────
                  Text(
                    'Price Details',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _PriceRow(label: 'Service', value: '₹${amount.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Convenience Fee', value: selectedPaymentMethod == 'cash' ? '₹0' : '₹10'),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Tax', value: '₹0'),
                        const Divider(height: 24),
                        _PriceRow(
                          label: 'Total Amount',
                          value: '₹${(amount + (selectedPaymentMethod == 'cash' ? 0 : 10)).toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  // Cash payment info note
                  if (selectedPaymentMethod == 'cash')
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'No advance payment needed. Pay at the salon after your service.',
                                style: AppTextStyles.caption.copyWith(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
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
            child: Column(
              children: [
                // Total amount display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                    Text(
                      '₹${(amount + (selectedPaymentMethod == 'cash' ? 0 : 10)).toStringAsFixed(0)}',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Obx(() => PrimaryButton(
                  label: bookingController.isCreatingBooking.value
                      ? 'Processing...'
                      : selectedPaymentMethod == 'cash'
                          ? 'Confirm Booking'
                          : 'Pay ₹${(amount + 10).toStringAsFixed(0)}',
                  enabled: !bookingController.isCreatingBooking.value,
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      Get.snackbar('Error', 'Please login to continue');
                      return;
                    }

                    // For online payments, show a mock payment processing
                    if (selectedPaymentMethod != 'cash') {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: Text('Processing Payment', style: TextStyle(color: Colors.white)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Please wait while we process your payment...',
                                style: TextStyle(color: AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        barrierDismissible: false,
                      );
                      await Future.delayed(const Duration(seconds: 2));
                      Get.back(); // Close dialog
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
                        'paymentMethod': selectedPaymentMethod,
                      });
                    }
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── PAYMENT METHOD CARD ───────────────── */

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge!,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
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
