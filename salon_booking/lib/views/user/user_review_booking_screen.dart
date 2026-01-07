import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';
import '../../theme/user_colors.dart';

class UserReviewBookingScreen extends StatelessWidget {
  const UserReviewBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Review Booking',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (!controller.isBookingReady) {
          return _invalidState();
        }

        final salon = controller.selectedSalon.value!;
        final service = controller.selectedService.value!;
        final date = controller.selectedDate.value!;
        final time = controller.selectedTime.value;
        final staff = controller.selectedStaff.value;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      UserCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking Details',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _row(Icons.store, 'Salon', salon.name),
                            _row(Icons.content_cut, 'Service', service.name),
                            _row(
                              Icons.calendar_today,
                              'Date',
                              DateFormat('EEE, dd MMM yyyy').format(date),
                            ),
                            _row(Icons.access_time, 'Time', time),
                            if (staff != null)
                              _row(Icons.person, 'Staff', staff.fullName),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      UserCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '₹${service.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: userPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                text: 'Confirm & Pay',
                onTap: () => Get.toNamed('/user/payment'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: userPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _invalidState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Booking data missing',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
