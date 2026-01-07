import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/booking_model.dart';
import '../../widgets/user_card.dart';
import '../../widgets/primary_button.dart';
import '../../theme/user_colors.dart';

class UserRateExperienceScreen extends StatefulWidget {
  const UserRateExperienceScreen({super.key});

  @override
  State<UserRateExperienceScreen> createState() =>
      _UserRateExperienceScreenState();
}

class _UserRateExperienceScreenState
    extends State<UserRateExperienceScreen> {
  int rating = 5;
  final TextEditingController feedbackController = TextEditingController();

  late final BookingModel booking;

  @override
  void initState() {
    super.initState();

    /// ✅ Read booking safely
    booking = Get.arguments as BookingModel;
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  void _submitReview() {
    Get.back();

    Get.snackbar(
      'Thank you!',
      'Your review has been submitted',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBg,
      appBar: AppBar(
        backgroundColor: userBg,
        elevation: 0,
        title: const Text(
          'Rate Experience',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            UserCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.salonName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.serviceName,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// ⭐ Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 42,
                  onPressed: () => setState(() => rating = index + 1),
                  icon: Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            /// ✍ Feedback
            UserCard(
              child: TextField(
                controller: feedbackController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Write your feedback...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),

            const Spacer(),

            PrimaryButton(
              text: 'Submit Review',
              onTap: _submitReview,
            ),
          ],
        ),
      ),
    );
  }
}
