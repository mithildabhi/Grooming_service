import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_home_controller.dart';
import '../../widgets/primary_button.dart';
import '../../theme/user_colors.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserHomeController controller = Get.find();

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: userBg,
        scrolledUnderElevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: userCard,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, color: userPrimary, size: 22),
              onPressed: controller.refreshSalons,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmer();
        }

        if (controller.nearbySalons.isEmpty) {
          return _buildEmptyState(controller);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSalons,
          color: userPrimary,
          backgroundColor: userCard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 24),
                      _buildAICard(controller),
                      const SizedBox(height: 32),
                      _buildSectionHeader(controller),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final salon = controller.nearbySalons[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == controller.nearbySalons.length - 1
                            ? 0
                            : 16,
                      ),
                      child: _buildSalonCard(
                        context: context,
                        salon: salon,
                        distance: controller.getDistance(salon),
                        onTap: () => controller.selectSalon(salon),
                      ),
                    );
                  }, childCount: controller.nearbySalons.length),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Good Morning 👋',
        //   style: TextStyle(
        //     fontSize: 28,
        //     fontWeight: FontWeight.w700,
        //     color: userCard,
        //     letterSpacing: -0.8,
        //     height: 1.2,
        //   ),
        // ),
        const SizedBox(height: 8),
        Text(
          'Find the best salon near you',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildAICard(UserHomeController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            userPrimary.withOpacity(0.12),
            userPrimary.withOpacity(0.06),
            userCard,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: userPrimary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: userPrimary.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: userPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: userPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI Pick for You',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: userCard,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'We found ${controller.nearbySalons.length} salons near you. Evening slots are less crowded today.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Explore All',
              onTap: () => Get.toNamed('/user/explore'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(UserHomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Nearby Salons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: userCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${controller.nearbySalons.length} found',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalonCard({
    required BuildContext context,
    required dynamic salon,
    required String distance,
    required VoidCallback onTap,
  }) {
    final isOpen = salon.isOpen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: userCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: 'salon_${salon.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: userPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: salon.imageUrl.isNotEmpty
                        ? Image.network(
                            salon.displayImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: userPrimary.withOpacity(0.1),
                              child: Icon(
                                Icons.store_rounded,
                                color: userPrimary,
                                size: 36,
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: userCard,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    color: userPrimary,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: userPrimary.withOpacity(0.1),
                            child: Icon(
                              Icons.store_rounded,
                              color: userPrimary,
                              size: 36,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      salon.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${salon.rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          distance,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      salon.salonTypeDisplay,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOpen ? Colors.green.shade200 : Colors.red.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color: isOpen
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(UserHomeController controller) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: userCard,
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
                Icons.store_outlined,
                size: 64,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No salons found nearby',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try refreshing or check back later',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.refreshSalons,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Refresh',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: userPrimary,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 4 ? 0 : 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: userCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  width: 80,
                  height: 80,
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
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: userCard,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 70,
                  height: 32,
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
}
