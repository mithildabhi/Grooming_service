import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;

  const RatingStars(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round()
              ? Icons.star
              : Icons.star_border,
          size: 16,
          color: AppColors.primary,
        );
      }),
    );
  }
}
