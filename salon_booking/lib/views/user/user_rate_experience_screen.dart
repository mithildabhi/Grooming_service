import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';

class UserRateExperienceScreen extends StatefulWidget {
  const UserRateExperienceScreen({super.key});

  @override
  State<UserRateExperienceScreen> createState() =>
      _UserRateExperienceScreenState();
}

class _UserRateExperienceScreenState extends State<UserRateExperienceScreen> {
  int rating = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Rate Experience',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            UserCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How was your visit?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            UserCard(
              child: const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your feedback...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const Spacer(),

            PrimaryButton(
              text: 'Submit Review',
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
