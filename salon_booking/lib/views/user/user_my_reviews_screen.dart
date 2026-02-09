// lib/screens/user/user_my_reviews_screen.dart
// ✅ NEW: Screen for users to view/manage their reviews

// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/review_model.dart';
import '../../services/review_api.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/custom_snackbar.dart';

class UserMyReviewsScreen extends StatefulWidget {
  const UserMyReviewsScreen({super.key});

  @override
  State<UserMyReviewsScreen> createState() => _UserMyReviewsScreenState();
}

class _UserMyReviewsScreenState extends State<UserMyReviewsScreen> {
  List<ReviewModel> reviews = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMyReviews();
  }

  Future<void> _loadMyReviews() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedReviews = await ReviewApi.getMyReviews();

      setState(() {
        reviews = loadedReviews;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      debugPrint('❌ Error loading my reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Reviews',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyReviews,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading reviews',
                          style: AppTextStyles.subHeading,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMyReviews,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Reviews Yet',
                              style: AppTextStyles.subHeading,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your reviews will appear here',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return _MyReviewCard(
                            review: review,
                            onDelete: () => _deleteReview(review.id),
                            onEdit: () => _editReview(review),
                          );
                        },
                      ),
      ),
    );
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReviewApi.deleteReview(reviewId);
        CustomSnackbar.show(
          title: 'Success',
          message: 'Review deleted successfully',
          isSuccess: true,
        );
        _loadMyReviews(); // Refresh list
      } catch (e) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Failed to delete review: $e',
          isError: true,
        );
      }
    }
  }

  void _editReview(ReviewModel review) {
    // Navigate to edit screen
    Get.toNamed('/edit-review', arguments: review)?.then((_) {
      _loadMyReviews(); // Refresh after edit
    });
  }
}

/* ───────────────── MY REVIEW CARD ───────────────── */

class _MyReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _MyReviewCard({
    required this.review,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Salon name + service
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.salonName,
                        style: AppTextStyles.subHeading.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (review.service != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          review.service!.name,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Actions menu
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                      onTap: onEdit,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Rating + verified badge
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 18,
                    color: index < review.rating
                        ? Colors.amber
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.rating.toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (review.isVerified) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // Title
            if (review.title.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                review.title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            // Comment
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.comment,
              style: AppTextStyles.body,
            ),

            // Owner Reply
            if (review.ownerReply != null && review.ownerReply!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.store, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Owner Response',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review.ownerReply!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            // Footer: time + helpfulness
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  review.timeAgo,
                  style: AppTextStyles.caption,
                ),
                if (review.isEdited) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '• Edited',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const Spacer(),
                if (review.helpfulCount > 0) ...[
                  Icon(
                    Icons.thumb_up,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    review.helpfulCount.toString(),
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}