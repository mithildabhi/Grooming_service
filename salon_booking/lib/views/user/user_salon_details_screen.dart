import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_home_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';
import '../../models/salon_model.dart';
import '../../theme/user_colors.dart';

class UserSalonDetailsScreen extends StatelessWidget {
  const UserSalonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SalonModel? salon = Get.arguments as SalonModel?;
    final controller = Get.find<UserHomeController>();
    final bookingController = Get.find<BookingController>();
    
    final displaySalon = salon ?? controller.selectedSalon.value;
    
    if (displaySalon == null) {
      return Scaffold(
        backgroundColor: userBg,
        appBar: AppBar(
          backgroundColor: userBg,
          elevation: 0,
          title: const Text(
            'Salon Details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: userCard,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No salon selected',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Salon Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final isLoadingServices = controller.isLoadingServices.value;
        final services = controller.salonServices;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSalonHeader(displaySalon, controller),
                    const SizedBox(height: 24),
                    _buildServicesHeader(isLoadingServices),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (isLoadingServices)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          height: 100,
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
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (services.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: UserCard(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: userCard,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.content_cut_rounded,
                            size: 48,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No services available yet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for updates',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = services[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        index == services.length - 1 ? 0 : 16,
                      ),
                      child: _buildServiceTile(
                        name: service.name,
                        description: service.description,
                        duration: '${service.duration} mins',
                        price: '₹${service.price.toStringAsFixed(0)}',
                        onTap: () {
                          bookingController.initializeBooking(
                            salon: displaySalon,
                            service: service,
                          );
                          Get.toNamed('/user/booking/datetime');
                        },
                      ),
                    );
                  },
                  childCount: services.length,
                ),
              ),
            if (services.isNotEmpty && !isLoadingServices)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  child: PrimaryButton(
                    text: 'Book Appointment',
                    onTap: () {
                      bookingController.initializeBooking(
                        salon: displaySalon,
                        service: services.first,
                      );
                      Get.toNamed('/user/booking/datetime');
                    },
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSalonHeader(SalonModel salon, UserHomeController controller) {
    return UserCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (salon.imageUrl.isNotEmpty)
            Hero(
              tag: 'salon_${salon.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  salon.displayImage,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: userPrimary.withOpacity(0.1),
                    child: Icon(
                      Icons.store_rounded,
                      size: 64,
                      color: userPrimary,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: userCard,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: userPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (salon.imageUrl.isNotEmpty) const SizedBox(height: 20),
          Text(
            salon.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 20, color: Colors.amber.shade600),
              const SizedBox(width: 6),
              Text(
                '${salon.rating.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.location_on_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                controller.getDistance(salon),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: salon.isOpen
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: salon.isOpen
                        ? Colors.green.shade200
                        : Colors.red.shade200,
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
                        color: salon.isOpen ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      salon.isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color: salon.isOpen ? Colors.green.shade700 : Colors.red.shade700,
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.home_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                salon.salonTypeDisplay,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  salon.address,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                salon.phone,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (salon.about.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 16),
            Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              salon.about,
              style: TextStyle(
                color: Colors.white70,
                height: 1.6,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesHeader(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildServiceTile({
    required String name,
    required String description,
    required String duration,
    required String price,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: userPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.content_cut_rounded,
                  color: userPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: userPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: userPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Book',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: userPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
