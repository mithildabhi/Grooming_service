// lib/views/admin/reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController ctrl = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5F2),
        elevation: 0,
        title: const Text(
          "Reviews",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Obx(() {
        final list = ctrl.reviewsList;

        if (list.isEmpty) {
          return const Center(
            child: Text(
              "No reviews yet",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final r = list[index];

            final userName = r['userName'] ?? r['name'] ?? 'Guest';
            final comment = r['comment'] ?? '';
            final rating = (r['rating'] ?? 0).toDouble();
            final avatar = r['userAvatar'];
            final id = r['id'] ?? '';

            return _reviewCard(
              name: userName,
              comment: comment,
              rating: rating,
              avatar: avatar,
              onDelete: () => _deleteReview(context, ctrl, id),
            );
          },
        );
      }),
    );
  }

  // ------------------------- REVIEW CARD UI -------------------------
  Widget _reviewCard({
    required String name,
    required String comment,
    required double rating,
    required String? avatar,
    required Function onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.orangeAccent.shade200],
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              backgroundImage: (avatar != null && avatar.toString().isNotEmpty)
                  ? NetworkImage(avatar)
                  : null,
              child: (avatar == null || avatar.toString().isEmpty)
                  ? const Icon(Icons.person, size: 28, color: Colors.black54)
                  : null,
            ),
          ),

          const SizedBox(width: 14),

          // Name, comment & rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (v) {
                        if (v == "delete") onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: "delete",
                          child: Text("Delete review"),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Rating stars
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------- DELETE CONFIRMATION ---------------------------
  Future<void> _deleteReview(
    BuildContext context,
    AdminController ctrl,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Review?"),
        content: const Text(
          "Deleting this review will update your salon rating.",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ctrl.deleteReview(id);
      Get.snackbar("Deleted", "Review removed successfully");
    }
  }
}
