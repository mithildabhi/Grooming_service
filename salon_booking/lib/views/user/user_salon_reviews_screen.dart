import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/review_model.dart';
import '../../services/review_api.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/rating_stars.dart';

class UserSalonReviewsScreen extends StatefulWidget {
  const UserSalonReviewsScreen({super.key});

  @override
  State<UserSalonReviewsScreen> createState() => _UserSalonReviewsScreenState();
}

class _UserSalonReviewsScreenState extends State<UserSalonReviewsScreen> {
  ReviewStats? reviewStats;
  List<ReviewModel> reviews = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;
  String selectedSort = 'recent';
  int? selectedRatingFilter;

  late final int salonId;
  late final ScrollController _scrollController;

  static const _sortOptions = {
    'recent': 'Most Recent',
    'helpful': 'Most Helpful',
    'rating_high': 'Highest Rated',
    'rating_low': 'Lowest Rated',
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    final args = Get.arguments;
    if (args is String) {
      salonId = int.parse(args);
    } else if (args is int) {
      salonId = args;
    } else {
      salonId = 0;
    }

    if (salonId > 0) {
      _loadStats();
      _loadReviews();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ReviewApi.getSalonReviewStats(salonId);
      if (mounted) setState(() => reviewStats = stats);
    } catch (e) {
      debugPrint('❌ Error loading review stats: $e');
    }
  }

  Future<void> _loadReviews() async {
    try {
      setState(() => isLoading = true);

      final data = await ReviewApi.getSalonReviews(
        salonId: salonId,
        page: 1,
        pageSize: 15,
        sort: selectedSort,
        rating: selectedRatingFilter,
      );

      if (mounted) {
        setState(() {
          reviews = data['reviews'] as List<ReviewModel>;
          currentPage = 1;
          hasMore = (data['has_next'] as bool?) ?? reviews.length >= 15;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading reviews: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    try {
      final data = await ReviewApi.getSalonReviews(
        salonId: salonId,
        page: currentPage + 1,
        pageSize: 15,
        sort: selectedSort,
        rating: selectedRatingFilter,
      );

      final newReviews = data['reviews'] as List<ReviewModel>;

      if (mounted) {
        setState(() {
          reviews.addAll(newReviews);
          currentPage++;
          hasMore = (data['has_next'] as bool?) ?? newReviews.length >= 15;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading more reviews: $e');
      if (mounted) setState(() => isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (salonId == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Reviews', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Invalid salon')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'All Reviews',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // ── STATS SUMMARY ──
                if (reviewStats != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _buildStatsSummary(),
                    ),
                  ),

                // ── SORT & FILTER ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: _buildSortFilterBar(),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),

                // ── REVIEW LIST ──
                if (reviews.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == reviews.length) {
                          return isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(AppSpacing.lg),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        return _buildReviewCard(reviews[index]);
                      }, childCount: reviews.length + (hasMore ? 1 : 0)),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
    );
  }

  // ════════════════════════════════════════
  // STATS SUMMARY
  // ════════════════════════════════════════
  Widget _buildStatsSummary() {
    final stats = reviewStats!;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Average Rating
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                RatingStars(stats.averageRating),
                const SizedBox(height: 4),
                Text(
                  '${stats.totalReviews} reviews',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Rating Distribution
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final percentage = stats.getPercentage(stars);
                final count = stats.getCount(stars);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$stars★', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.amber,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        count.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // SORT & FILTER BAR
  // ════════════════════════════════════════
  Widget _buildSortFilterBar() {
    return Row(
      children: [
        // Sort Dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSort,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: AppTextStyles.body,
                icon: const Icon(
                  Icons.sort,
                  color: AppColors.primary,
                  size: 18,
                ),
                items: _sortOptions.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          e.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null && val != selectedSort) {
                    setState(() => selectedSort = val);
                    _loadReviews();
                  }
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Rating Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: selectedRatingFilter,
              dropdownColor: AppColors.surface,
              style: AppTextStyles.body,
              hint: const Text(
                'All Stars',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              icon: const Icon(Icons.star, color: Colors.amber, size: 18),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All', style: TextStyle(fontSize: 14)),
                ),
                ...List.generate(
                  5,
                  (i) => DropdownMenuItem<int?>(
                    value: 5 - i,
                    child: Text(
                      '${5 - i} ★',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != selectedRatingFilter) {
                  setState(() => selectedRatingFilter = val);
                  _loadReviews();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════
  // REVIEW CARD
  // ════════════════════════════════════════
  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    review.user.initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.user.displayName,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (review.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.green,
                            ),
                          ],
                        ],
                      ),
                      Text(review.timeAgo, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                // Rating Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        review.rating.toString(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Review Title
            if (review.title.isNotEmpty) ...[
              Text(
                review.title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
            ],

            // Review Comment (no truncation in full list)
            Text(review.comment, style: AppTextStyles.body),

            // Service Info
            if (review.service != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${review.service!.name} • ${review.service!.category}',
                  style: AppTextStyles.caption.copyWith(color: Colors.blue),
                ),
              ),
            ],

            // Owner Reply
            if (review.ownerReply != null && review.ownerReply!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
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

            // Helpfulness
            if (review.helpfulCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.thumb_up_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.helpfulCount} found this helpful',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
