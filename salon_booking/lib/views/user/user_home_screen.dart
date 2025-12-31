import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_home_controller.dart';
import '../../widgets/user_card.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/primary_button.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserHomeController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _homeShimmer();
        }

        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning 👋',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find the best salon near you',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 20),

                /// AI Card
                UserCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 8),
                          Text(
                            'AI Pick for You',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Evening slots are less crowded today.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'Explore',
                        onTap: () => Get.toNamed('/user/explore'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Nearby Salons',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                SalonCard(
                  name: 'Luxe Studio & Spa',
                  rating: 4.8,
                  distance: '1.2 km',
                  isOpen: true,
                  onTap: () => Get.toNamed('/user/salon-details'),
                ),
                const SizedBox(height: 12),
                SalonCard(
                  name: 'Urban Cut',
                  rating: 4.6,
                  distance: '2.4 km',
                  isOpen: false,
                  onTap: () => Get.toNamed('/user/salon-details'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _homeShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
