import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/booking_controller.dart';
import '../../models/booking_model.dart';
import '../../theme/user_colors.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});
    @override
  State<UserAppointmentsScreen> createState() =>
      _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> { 
  final BookingController controller = Get.find<BookingController>();
  final RxInt selectedTab = 0.obs;

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: userCard,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: userPrimary,
                size: 22,
              ),
              onPressed: controller.fetchUserBookings,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final bookings = selectedTab.value == 0
                  ? controller.upcomingBookings
                  : controller.pastBookings;

              if (bookings.isEmpty) {
                return _emptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.fetchUserBookings,
                color: userPrimary,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == bookings.length - 1 ? 0 : 16,
                      ),
                      child: _appointmentCard(bookings[index]),
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

  Widget _buildTabBar() {
      return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: userCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: _tabButton(
                'Upcoming',
                0,
                controller.upcomingBookings.length,
              ),
            ),
            Expanded(
              child: _tabButton(
                'Past',
                1,
                controller.pastBookings.length,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _tabButton(String label, int index, int count) {
    final isSelected = selectedTab.value == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => selectedTab.value = index,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? userPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : userCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appointmentCard(BookingModel booking) {
    final isUpcoming = selectedTab.value == 0;
    final statusColor = _getStatusColor(booking.status);
    final canCancel = booking.status != 'CANCELLED' &&
        booking.status != 'COMPLETED' &&
        isUpcoming;

    return Container(
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
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(booking.status),
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.salonName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(booking.status, statusColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _detailRow(
                  Icons.calendar_today_rounded,
                  _formatDate(booking.date),
                ),
                const SizedBox(height: 12),
                _detailRow(
                  Icons.access_time_rounded,
                  _formatTime(booking.time),
                ),
                const SizedBox(height: 12),
                _detailRow(
                  Icons.timer_outlined,
                  '${booking.durationMinutes} minutes',
                ),
                if (booking.staffName != null) ...[
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.person_rounded,
                    booking.staffName!,
                  ),
                ],
                const SizedBox(height: 12),
                _detailRow(
                  Icons.payment_rounded,
                  '₹${booking.price.toStringAsFixed(0)}',
                  isPrice: true,
                ),
                if (canCancel || booking.status == 'COMPLETED') ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      if (canCancel)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmCancellation(booking),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (canCancel && booking.status == 'COMPLETED')
                        const SizedBox(width: 12),
                      if (booking.status == 'COMPLETED')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _rateExperience(booking),
                            icon: const Icon(Icons.star_outline, size: 18),
                            label: const Text('Rate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: userPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, {bool isPrice = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: userPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: userPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isPrice ? userPrimary : Colors.white,
              fontWeight: isPrice ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  void _confirmCancellation(BookingModel booking) {
      Get.dialog(
      AlertDialog(
        backgroundColor: userCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Cancel Booking?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this booking?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'No, Keep It',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelBooking(booking.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rateExperience(BookingModel booking) {
    Get.toNamed('/user/rate-experience', arguments: booking);
  }

  Widget _emptyState() {
    final isUpcoming = selectedTab.value == 0;
    return Center(
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
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isUpcoming ? Icons.event_available_rounded : Icons.history_rounded,
              size: 64,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isUpcoming ? 'No Upcoming Appointments' : 'No Past Appointments',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isUpcoming
                ? 'Book a service to see your appointments here'
                : 'Your completed appointments will appear here',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/user/home'),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Book Now',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: userPrimary,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Icons.check_circle_rounded;
      case 'COMPLETED':
        return Icons.done_all_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      case 'PENDING':
        return Icons.schedule_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(0, 1, 1, hour, minute);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return timeStr;
    }
  }
}
