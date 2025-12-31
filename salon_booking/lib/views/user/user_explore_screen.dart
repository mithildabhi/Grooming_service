import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_home_controller.dart';
import '../../widgets/salon_card.dart';

class UserExploreScreen extends StatelessWidget {
  const UserExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserHomeController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search salons or services',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏬 Salon list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _shimmerList();
              }

              // Temporary static list
              final salons = [
                {
                  'name': 'Luxe Studio & Spa',
                  'rating': 4.8,
                  'distance': '1.2 km',
                  'open': true,
                },
                {
                  'name': 'Urban Cut',
                  'rating': 4.6,
                  'distance': '2.4 km',
                  'open': false,
                },
              ];

              if (salons.isEmpty) {
                return _emptyState();
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView.separated(
                  key: const ValueKey('salon_list'),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: salons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final s = salons[i];
                    return SalonCard(
                      name: s['name'] as String,
                      rating: s['rating'] as double,
                      distance: s['distance'] as String,
                      isOpen: s['open'] as bool,
                      onTap: () {
                        Get.toNamed('/user/salon-details');
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'No salons found',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
