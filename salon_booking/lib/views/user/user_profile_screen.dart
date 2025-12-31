import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            UserCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'john@example.com',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            UserCard(
              onTap: () {},
              child: const Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            UserCard(
              onTap: () {},
              child: const Row(
                children: [
                  Icon(Icons.help_outline),
                  SizedBox(width: 12),
                  Text('Help & Support'),
                ],
              ),
            ),

            const Spacer(),

            PrimaryButton(
              text: 'Logout',
              onTap: () {
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
