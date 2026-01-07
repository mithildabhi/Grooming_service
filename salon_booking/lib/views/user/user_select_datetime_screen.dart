import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';
import '../../theme/user_colors.dart';

class UserSelectDateTimeScreen extends StatelessWidget {
  const UserSelectDateTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Select Date & Time',
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
        final selectedService = controller.selectedService.value;
        final selectedSalon = controller.selectedSalon.value;

        if (selectedService == null || selectedSalon == null) {
          return const Center(
            child: Text(
              'No service selected',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceSummary(selectedService),
              const SizedBox(height: 32),
              _buildDateSection(controller),
              const SizedBox(height: 32),
              _buildTimeSection(controller),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Continue',
                onTap: () {
                  if (controller.selectedDate.value == null) {
                    Get.snackbar(
                      'Error',
                      'Please select a date',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade50,
                      colorText: Colors.red.shade700,
                    );
                    return;
                  }

                  if (controller.selectedTime.value.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please select a time',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade50,
                      colorText: Colors.red.shade700,
                    );
                    return;
                  }

                  if (controller.isBookingReady) {
                    Get.toNamed('/user/booking/review');
                  } else {
                    Get.snackbar('Error', 'Please complete booking details');
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildServiceSummary(dynamic service) {
    return UserCard(
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
                  service.name,
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
                    Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${service.duration} mins',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '₹${service.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: userPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BookingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 16),
        UserCard(
          child: SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected =
                    controller.selectedDate.value != null &&
                    DateFormat(
                          'yyyy-MM-dd',
                        ).format(controller.selectedDate.value!) ==
                        DateFormat('yyyy-MM-dd').format(date);
                final isToday =
                    DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.selectDate(date),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? userPrimary
                              : isToday
                              ? userPrimary.withOpacity(0.1)
                              : userCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? userPrimary
                                : isToday
                                ? userPrimary.withOpacity(0.3)
                                : Colors.white24,
                            width: isSelected ? 2 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: userPrimary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd').format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM').format(date),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(BookingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            if (controller.isLoadingSlots.value)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.selectedDate.value == null)
          UserCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please select a date first',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (controller.availableTimeSlots.isEmpty)
          UserCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No time slots available',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          UserCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.availableTimeSlots.map((time) {
                final isSelected = controller.selectedTime.value == time;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.selectTime(time),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? userPrimary : userCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? userPrimary : Colors.white24,
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: userPrimary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
