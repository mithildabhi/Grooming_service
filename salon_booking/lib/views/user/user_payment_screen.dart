// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/booking_controller.dart';
import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';

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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _method('UPI', 'payment'),
            _method('Credit / Debit Card', 'credit_card'),
            _method('Wallet', 'account_balance_wallet'),
            _method('Pay at Salon', 'store'),

            const Spacer(),

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

  Widget _method(String text, String icon) {
    final isSelected = selectedPaymentMethod == text;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaymentMethod = text;
          });
        },
        child: UserCard(
          child: Row(
            children: [
              Icon(
                _getIconData(icon),
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.black,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF6C63FF),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'payment':
        return Icons.payment;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'store':
        return Icons.store;
      default:
        return Icons.payment;
    }
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

      // Get user display name or email
      String customerName = user.displayName ?? user.email?.split('@')[0] ?? 'Customer';
      String customerPhone = user.phoneNumber ?? '';

      print('📱 Creating booking for: $customerName');

      // Create the booking
      final success = await controller.createBooking(
        customerName: customerName,
        customerPhone: customerPhone,
      );

      if (success) {
        // Navigate to success screen
        Get.offAllNamed('/user/booking/success');
      } else {
        Get.snackbar(
          'Error',
          'Failed to create booking. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Payment error: $e');
      Get.snackbar(
        'Error',
        'Booking failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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