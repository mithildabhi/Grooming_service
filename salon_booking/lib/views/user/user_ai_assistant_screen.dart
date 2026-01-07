import 'package:flutter/material.dart';

import '../../widgets/user_card.dart';
import '../../theme/user_colors.dart';

class UserAIAssistantScreen extends StatelessWidget {
  const UserAIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            _buildAICard(
              icon: Icons.auto_awesome_rounded,
              title: 'Smart Tip',
              description: 'Evening slots have 25% less waiting time today.',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  userPrimary.withOpacity(0.15),
                  userPrimary.withOpacity(0.05),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAICard(
              icon: Icons.trending_up_rounded,
              title: 'Recommended Service',
              description: 'Hair Spa + Trim combo is trending near you.',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.15),
                  Colors.purple.withOpacity(0.05),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAICard(
              icon: Icons.schedule_rounded,
              title: 'Best Time to Book',
              description: 'Weekday mornings typically have more availability.',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.15),
                  Colors.blue.withOpacity(0.05),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAICard(
              icon: Icons.local_offer_rounded,
              title: 'Special Offers',
              description: 'New customers get 20% off on first booking.',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.15),
                  Colors.orange.withOpacity(0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAICard({
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: UserCard(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: userPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: userPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: userPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
