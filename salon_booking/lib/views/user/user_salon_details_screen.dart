import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/user_card.dart';
import '../../widgets/service_tile.dart';
import '../../widgets/primary_button.dart';

class UserSalonDetailsScreen extends StatelessWidget {
  const UserSalonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Salon Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedSlide(
        offset: Offset.zero,
        duration: const Duration(milliseconds: 250),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏬 Salon Info
              UserCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Luxe Studio & Spa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⭐ 4.8 • 1.2 km away',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Premium salon offering hair, grooming and skin services.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✂ Services
              const Text(
                'Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ServiceTile(
                name: 'Men’s Haircut',
                duration: '30 mins',
                price: '₹299',
                onTap: () {
                  Get.toNamed('/user/select-date-time');
                },
              ),
              ServiceTile(
                name: 'Beard Trim',
                duration: '20 mins',
                price: '₹199',
                onTap: () {
                  Get.toNamed('/user/select-date-time');
                },
              ),
              ServiceTile(
                name: 'Hair Spa',
                duration: '45 mins',
                price: '₹599',
                onTap: () {
                  Get.toNamed('/user/select-date-time');
                },
              ),

              const SizedBox(height: 30),

              // 📅 CTA
              PrimaryButton(
                text: 'Book Appointment',
                onTap: () {
                  Get.toNamed('/user/select-date-time');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
