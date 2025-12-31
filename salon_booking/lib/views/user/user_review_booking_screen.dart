import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';

class UserReviewBookingScreen extends StatelessWidget {
  const UserReviewBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Review Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            UserCard(
              child: Column(
                children: const [
                  _RowItem('Salon', 'Luxe Studio & Spa'),
                  _RowItem('Service', 'Men’s Haircut'),
                  _RowItem('Date', '24 Oct 2025'),
                  _RowItem('Time', '05:30 PM'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            UserCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹299',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),

            const Spacer(),

            PrimaryButton(
              text: 'Confirm & Pay',
              onTap: () {
                Get.toNamed('/user/payment');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String value;

  const _RowItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
