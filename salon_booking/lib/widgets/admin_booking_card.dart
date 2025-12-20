import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String salonId;

  const AdminBookingCard({
    super.key,
    required this.booking,
    required this.salonId,
  });

  Color _statusColor(String s) {
    final up = s.toUpperCase();
    switch (up) {
      case 'REQUESTED':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    final status = (booking['status'] ?? 'REQUESTED').toString().toUpperCase();
    final name = booking['userName'] ?? booking['customerName'] ?? 'Guest';
    final service = booking['serviceName'] ?? booking['serviceId'] ?? 'Service';
    final date = booking['date'] ?? booking['bookingDate'] ?? '';
    final time = booking['time'] ?? booking['timeSlot'] ?? '';

    Future<void> confirmAndAct(String newStatus) async {
      final ok = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirm $newStatus'),
          content: Text(
            'Are you sure you want to mark this booking as $newStatus?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      if (ok == true) {
        ctrl.updateBookingStatus(booking['id'], newStatus);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$service • $date • $time',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if ((booking['note'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Note: ${booking['note']}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            Wrap(spacing: 8, children: _actionButtons(status, confirmAndAct)),
          ],
        ),
      ),
    );
  }

  List<Widget> _actionButtons(
    String status,
    Future<void> Function(String) onAction,
  ) {
    final List<Widget> buttons = [];

    if (status == 'REQUESTED') {
      buttons.add(
        ElevatedButton(
          onPressed: () => onAction('APPROVED'),
          child: const Text('Approve'),
        ),
      );
      buttons.add(
        TextButton(
          onPressed: () => onAction('CANCELLED'),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (status == 'APPROVED') {
      buttons.add(
        ElevatedButton(
          onPressed: () => onAction('IN_PROGRESS'),
          child: const Text('Start'),
        ),
      );
      buttons.add(
        TextButton(
          onPressed: () => onAction('CANCELLED'),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (status == 'IN_PROGRESS') {
      buttons.add(
        ElevatedButton(
          onPressed: () => onAction('COMPLETED'),
          child: const Text('Complete'),
        ),
      );
      buttons.add(
        TextButton(
          onPressed: () => onAction('CANCELLED'),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    buttons.add(
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          final ctrl = Get.find<AdminController>();
          final ok = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Delete booking'),
              content: const Text('Delete this booking permanently?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          if (ok == true) {
            await ctrl.deleteBooking(salonId, booking['id']);
          }
        },
      ),
    );

    return buttons;
  }
}
