import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import 'glass_card.dart';
import 'ai_badge.dart';

class AiInsightCard extends StatelessWidget {
  final String title;
  final String description;

  const AiInsightCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiBadge('AI Insight'),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.subHeading),
          const SizedBox(height: 4),
          Text(description, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
