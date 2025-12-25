import 'package:flutter/material.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key, required salonId});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aiSummaryCard(),
            const SizedBox(height: 24),
            _sectionTitle('Today’s Bookings'),
            const SizedBox(height: 12),
            _bookingTile(
              id: '#BK1023',
              customer: 'Rahul Sharma',
              service: 'Hair Cut',
              staff: 'Alex',
              time: '10:30 AM',
              status: 'Completed',
              statusColor: Colors.greenAccent,
            ),
            _bookingTile(
              id: '#BK1024',
              customer: 'Neha Patel',
              service: 'Facial',
              staff: 'Sarah',
              time: '12:00 PM',
              status: 'Pending',
              statusColor: Colors.orangeAccent,
            ),
            _bookingTile(
              id: '#BK1025',
              customer: 'Amit Verma',
              service: 'Beard Trim',
              staff: 'John',
              time: '2:00 PM',
              status: 'Cancelled',
              statusColor: Colors.redAccent,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── UI HELPERS ─────────────────────────

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

  Widget _aiSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: accent),
              SizedBox(width: 8),
              Text(
                'AI Booking Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Peak booking hours today: 11 AM – 3 PM.\n'
            'AI recommends adding extra staff in afternoon slots.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _bookingTile({
    required String id,
    required String customer,
    required String service,
    required String staff,
    required String time,
    required String status,
    required Color statusColor,
  }) {
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
                    '$service • $time',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customer: $customer',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Staff: $staff',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(id, style: const TextStyle(color: Colors.white38)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
