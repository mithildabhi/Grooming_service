import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/primary_button.dart';

class UserBookingSuccessScreen extends StatelessWidget {
  const UserBookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 300),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Booking Confirmed!',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your appointment has been successfully booked.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                PrimaryButton(
                  text: 'View Appointments',
                  onTap: () {
                    Get.offAllNamed('/user/appointments');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
