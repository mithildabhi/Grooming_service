import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';

class AdminBookingsScreen extends StatelessWidget {
  final String salonId;  // Add this line

  AdminBookingsScreen({super.key, required this.salonId});  // Add salonId here


  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  final BookingController controller = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Bookings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchBookings(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        if (controller.bookings.isEmpty) {
          return _emptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBookings(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statisticsCard(),
                const SizedBox(height: 24),
                _sectionTitle('Today\'s Bookings'),
                const SizedBox(height: 12),
                ...controller.todayBookings.map((booking) => _bookingTile(booking)),
                if (controller.todayBookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No bookings for today',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                const SizedBox(height: 24),
                _sectionTitle('All Bookings'),
                const SizedBox(height: 12),
                ...controller.bookings.map((booking) => _bookingTile(booking)),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create booking screen
          Get.toNamed('/create-booking');
        },
        backgroundColor: accent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.white30),
          const SizedBox(height: 16),
          const Text(
            'No bookings yet',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => controller.fetchBookings(),
            child: const Text('Refresh', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  Widget _statisticsCard() {
    return Obx(() {
      final stats = controller.statistics['today'] ?? {};
      final total = stats['total'] ?? 0;
      final confirmed = stats['confirmed'] ?? 0;
      final completed = stats['completed'] ?? 0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: accent),
                SizedBox(width: 8),
                Text(
                  'Today\'s Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Total', total.toString(), Colors.blueAccent),
                _statItem('Confirmed', confirmed.toString(), Colors.greenAccent),
                _statItem('Completed', completed.toString(), Colors.purpleAccent),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _bookingTile(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'PENDING';
    final statusColor = _getStatusColor(status);
    final time = booking['booking_time'] ?? '';
    final date = booking['booking_date'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(Icons.event, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking['service_name'] ?? 'Service'} • $time',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customer: ${booking['customer_name'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Staff: ${booking['staff_name'] ?? 'Unassigned'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Date: $date',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '#${booking['id']}',
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status_display'] ?? status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (status == 'PENDING') ...[
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                    onPressed: () {
                      controller.updateStatus(booking['id'], 'CONFIRMED');
                    },
                    iconSize: 20,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.greenAccent;
      case 'CONFIRMED':
        return Colors.blueAccent;
      case 'PENDING':
        return Colors.orangeAccent;
      case 'CANCELLED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}