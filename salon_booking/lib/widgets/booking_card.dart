import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final void Function(String status) onStatusChange;
  final VoidCallback? onDelete;
  const BookingCard({
    super.key,
    required this.booking,
    required this.onStatusChange,
    this.onDelete,
    required String salonId,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] ?? 'pending';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(
          booking['serviceName'] ?? booking['serviceId'] ?? 'Service',
        ),
        subtitle: Text(
          'Customer: ${booking['customerName'] ?? 'Guest'}\nDate: ${booking['date'] ?? ''} • ${booking['time'] ?? ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (v) {
                if (v != null) onStatusChange(v);
              },
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
