import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';

class UserSelectDateTimeScreen extends StatelessWidget {
  const UserSelectDateTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Select Date & Time',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🤖 AI Suggestion
              UserCard(
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI Suggestion: Evening slots are less crowded today.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// 📅 Date
              const Text(
                'Select Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    return UserCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Day ${i + 1}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Oct',
                              style: TextStyle(
                                  color: Colors.grey.shade600)),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              /// ⏰ Time
              const Text(
                'Select Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _timeChip('09:00 AM'),
                  _timeChip('10:30 AM'),
                  _timeChip('12:00 PM'),
                  _timeChip('03:00 PM'),
                  _timeChip('05:30 PM'),
                ],
              ),

              const Spacer(),

              PrimaryButton(
                text: 'Continue',
                onTap: () {
                  Get.toNamed('/user/review-booking');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeChip(String text) {
    return UserCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(text),
    );
  }
}
