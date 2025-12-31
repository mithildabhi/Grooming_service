import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';

class UserPaymentScreen extends StatelessWidget {
  const UserPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            _method('UPI'),
            _method('Credit / Debit Card'),
            _method('Wallet'),
            _method('Pay at Salon'),

            const Spacer(),

            PrimaryButton(
              text: 'Pay ₹299',
              onTap: () {
                Get.offAllNamed('/user/booking-success');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _method(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: UserCard(
        child: Row(
          children: [
            const Icon(Icons.payment),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }
}
