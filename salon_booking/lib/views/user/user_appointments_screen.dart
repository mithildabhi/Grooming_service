import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/user_card.dart';

class UserAppointmentsScreen extends StatelessWidget {
  const UserAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _appointmentCard(
            salon: 'Luxe Studio & Spa',
            date: '24 Oct 2025',
            time: '05:30 PM',
            upcoming: true,
          ),
          const SizedBox(height: 12),
          _appointmentCard(
            salon: 'Urban Cut',
            date: '12 Oct 2025',
            time: '01:00 PM',
            upcoming: false,
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard({
    required String salon,
    required String date,
    required String time,
    required bool upcoming,
  }) {
    return UserCard(
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date • $time',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          upcoming
              ? const Text(
                  'Upcoming',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : TextButton(
                  onPressed: () {
                    Get.toNamed('/user/rate-experience');
                  },
                  child: const Text('Rate'),
                ),
        ],
      ),
    );
  }
}
