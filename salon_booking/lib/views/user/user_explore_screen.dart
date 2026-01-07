import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_home_controller.dart';
import '../../theme/user_colors.dart';
import '../../widgets/salon_card.dart';

class UserExploreScreen extends StatelessWidget {
  const UserExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserHomeController controller = Get.find();

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Explore',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search salons or services',
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: userPrimary,
                    size: 24,
                  ),
                  filled: true,
                  fillColor: userCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _shimmerList();
              }

              final salons = controller.allSalons;

              if (salons.isEmpty) {
                return _emptyState();
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView.separated(
                  key: const ValueKey('salon_list'),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: salons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final salon = salons[i];
                    return SalonCard(
                      name: salon.name,
                      rating: salon.rating,
                      distance: controller.getDistance(salon),
                      isOpen: salon.isOpen,
                      onTap: () => controller.selectSalon(salon),
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
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 4 ? 0 : 16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: userCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: userCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: userCard,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: userCard,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 60,
                  height: 28,
                  decoration: BoxDecoration(
                    color: userCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No salons found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your search',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
