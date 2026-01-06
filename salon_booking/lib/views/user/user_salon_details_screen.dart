import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_home_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';
import '../../models/salon_model.dart';

class UserSalonDetailsScreen extends StatelessWidget {
  const UserSalonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get salon from arguments or controller
    final SalonModel? salon = Get.arguments as SalonModel?;
    final controller = Get.find<UserHomeController>();
    
    // Initialize booking controller
    final bookingController = Get.put(BookingController());
    
    final displaySalon = salon ?? controller.selectedSalon.value;
    
    if (displaySalon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Salon Details')),
        body: const Center(child: Text('No salon selected')),
      );
    }

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
      body: Obx(() {
        final isLoadingServices = controller.isLoadingServices.value;
        final services = controller.salonServices;

        return AnimatedSlide(
          offset: Offset.zero,
          duration: const Duration(milliseconds: 250),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏬 Salon Header Card
                UserCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Salon Image
                      if (displaySalon.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            displaySalon.displayImage,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: Colors.purple.shade50,
                              child: Icon(
                                Icons.store,
                                size: 64,
                                color: Colors.purple.shade300,
                              ),
                            ),
                          ),
                        ),
                      
                      if (displaySalon.imageUrl.isNotEmpty) 
                        const SizedBox(height: 16),

                      // Salon Name
                      Text(
                        displaySalon.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Rating & Distance
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${displaySalon.rating.toStringAsFixed(1)} • ${controller.getDistance(displaySalon)}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: displaySalon.isOpen
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              displaySalon.isOpen ? 'OPEN' : 'CLOSED',
                              style: TextStyle(
                                color: displaySalon.isOpen 
                                    ? Colors.green 
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Salon Type
                      Row(
                        children: [
                          Icon(Icons.home, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            displaySalon.salonTypeDisplay,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              displaySalon.address,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Phone
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            displaySalon.phone,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      
                      if (displaySalon.about.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          displaySalon.about,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ✂️ Services Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLoadingServices)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Services List
                if (isLoadingServices)
                  ...List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else if (services.isEmpty)
                  UserCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.content_cut,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No services available yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check back later for updates',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...services.map((service) {
                    return Column(
                      children: [
                        _buildServiceTile(
                          name: service.name,
                          description: service.description,
                          duration: '${service.duration} mins',
                          price: '₹${service.price.toStringAsFixed(0)}',
                          onTap: () {
                            // Initialize booking with selected service
                            bookingController.initializeBooking(
                              salon: displaySalon,
                              service: service,
                            );
                            
                            // Navigate to date & time selection
                            Get.toNamed('/user/booking/datetime');
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),

                const SizedBox(height: 30),

                // 📅 Quick Book CTA (Optional - goes to first service)
                if (services.isNotEmpty)
                  PrimaryButton(
                    text: 'Book Appointment',
                    onTap: () {
                      // Initialize with first service
                      bookingController.initializeBooking(
                        salon: displaySalon,
                        service: services.first,
                      );
                      
                      Get.toNamed('/user/booking/datetime');
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildServiceTile({
    required String name,
    required String description,
    required String duration,
    required String price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.content_cut,
                color: Colors.purple.shade400,
                size: 24,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}