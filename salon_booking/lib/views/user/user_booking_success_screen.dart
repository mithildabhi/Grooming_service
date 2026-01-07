import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/user_card.dart';
import '../../theme/user_colors.dart';

class UserBookingSuccessScreen extends StatelessWidget {
  const UserBookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: userBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildSuccessIcon(),
                const SizedBox(height: 32),
                _buildSuccessMessage(),
                const SizedBox(height: 32),
                _buildBookingDetails(controller),
                const SizedBox(height: 32),
                _buildActionButtons(controller),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 80,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Text(
          'Booking Confirmed!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your appointment has been successfully booked.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookingDetails(BookingController controller) {
    return Obx(() {
      final booking = controller.currentBooking.value;

      if (booking == null) {
        return UserCard(
          child: Column(
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading booking details...'),
            ],
          ),
        );
      }

      return UserCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 20),
            _detailRow(Icons.store_rounded, 'Salon', booking.salonName),
            const SizedBox(height: 16),
            _detailRow(Icons.content_cut_rounded, 'Service', booking.serviceName),
            const SizedBox(height: 16),
            _detailRow(
              Icons.calendar_today_rounded,
              'Date',
              _formatDate(booking.date),
            ),
            const SizedBox(height: 16),
            _detailRow(
              Icons.access_time_rounded,
              'Time',
              _formatTime(booking.time),
            ),
            if (booking.staffName != null && booking.staffName!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _detailRow(Icons.person_rounded, 'Staff', booking.staffName!),
            ],
            const SizedBox(height: 16),
            _detailRow(
              Icons.timer_outlined,
              'Duration',
              '${booking.durationMinutes} minutes',
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.shade200,
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
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        booking.status,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Booking ID',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '#${booking.id ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: userPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    '₹${booking.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: userPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(BookingController controller) {
    return Column(
      children: [
        PrimaryButton(
          text: 'View My Bookings',
          onTap: () {
            controller.fetchUserBookings();
            Get.offAllNamed('/user');
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Get.offAllNamed('/user'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: userPrimary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Back to Home',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: userPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: userPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: userPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      return DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.parse(dateStr));
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
