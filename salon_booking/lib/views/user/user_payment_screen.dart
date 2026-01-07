// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/booking_controller.dart';
import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';
import '../../theme/user_colors.dart';

class UserPaymentScreen extends StatefulWidget {
  const UserPaymentScreen({super.key});

  @override
  State<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends State<UserPaymentScreen> {
  String selectedPaymentMethod = '';
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Payment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    _method('UPI', 'payment', Icons.payment_rounded),
                    const SizedBox(height: 12),
                    _method(
                      'Credit / Debit Card',
                      'credit_card',
                      Icons.credit_card_rounded,
                    ),
                    const SizedBox(height: 12),
                    _method(
                      'Wallet',
                      'account_balance_wallet',
                      Icons.account_balance_wallet_rounded,
                    ),
                    const SizedBox(height: 12),
                    _method('Pay at Salon', 'store', Icons.store_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final service = controller.selectedService.value;
              final price = service?.price ?? 0;

              return PrimaryButton(
                text: isProcessing
                    ? 'Processing...'
                    : 'Pay ₹${price.toStringAsFixed(0)}',
                onTap: isProcessing ? () {} : () => _processPayment(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _method(String text, String iconKey, IconData iconData) {
    final isSelected = selectedPaymentMethod == text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaymentMethod = text;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: UserCard(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? userPrimary : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? userPrimary.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconData,
                      color: isSelected ? userPrimary : Colors.grey.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 16,
                        color: isSelected
                            ? userPrimary
                            : const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: userPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final controller = Get.find<BookingController>();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      String customerName =
          user.displayName ?? user.email?.split('@')[0] ?? 'Customer';
      String customerPhone = user.phoneNumber ?? '';

      print('📱 Creating booking for: $customerName');

      final success = await controller.createBooking(
        customerName: customerName,
        customerPhone: customerPhone,
      );

      if (success) {
        Get.offAllNamed('/user/booking/success');
      } else {
        Get.snackbar(
          'Error',
          'Failed to create booking. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade700,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      print('❌ Payment error: $e');
      Get.snackbar(
        'Error',
        'Booking failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }
}
