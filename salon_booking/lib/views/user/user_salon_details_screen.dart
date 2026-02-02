import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/salon_model.dart';
import '../../models/service_model.dart';
import '../../models/review_model.dart';
import '../../controllers/user_home_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../services/review_api.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/primary_button.dart';
import '../../widgets/ui/rating_stars.dart';

class UserSalonDetailsScreen extends StatefulWidget {
  const UserSalonDetailsScreen({super.key});

  @override
  State<UserSalonDetailsScreen> createState() => _UserSalonDetailsScreenState();
}

class _UserSalonDetailsScreenState extends State<UserSalonDetailsScreen> {
  ReviewStats? reviewStats;
  List<ReviewModel> recentReviews = [];
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is SalonModel) {
      Get.find<UserHomeController>().fetchSalonServices(args.id);
      _loadReviews(args.id);
    }
  }

  Future<void> _loadReviews(String salonId) async {
    try {
      setState(() => isLoadingReviews = true);

      // Load review stats
      final stats = await ReviewApi.getSalonReviewStats(int.parse(salonId));
      
      // Load recent reviews
      final reviewsData = await ReviewApi.getSalonReviews(
        salonId: int.parse(salonId),
        page: 1,
        pageSize: 5,
        sort: 'recent',
      );

      setState(() {
        reviewStats = stats;
        recentReviews = reviewsData['reviews'] as List<ReviewModel>;
        isLoadingReviews = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading reviews: $e');
      setState(() => isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args == null || args is! SalonModel) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Salon', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Something went wrong')),
      );
    }

    final SalonModel salon = args;
    final UserHomeController homeController = Get.find<UserHomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image with Back Button
              _buildHeroSliver(salon),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ============ HEADER INFO ============
                      _buildHeaderSection(salon),
                      
                      const SizedBox(height: AppSpacing.xl),

                      // ============ QUICK ACTIONS ============
                      _buildQuickActions(salon),

                      const SizedBox(height: AppSpacing.xl),

                      // ============ RATING & REVIEWS ============
                      _buildRatingsSection(salon),

                      const SizedBox(height: AppSpacing.xl),

                      // ============ ABOUT SALON ============
                      if (salon.about.isNotEmpty) ...[
                        _buildAboutSection(salon),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // ============ WORKING HOURS ============
                      _buildWorkingHoursSection(salon),

                      const SizedBox(height: AppSpacing.xl),

                      // ============ LOCATION INFO ============
                      _buildLocationSection(salon),

                      const SizedBox(height: AppSpacing.xl),

                      // ============ SERVICES ============
                      _buildServicesSection(homeController, salon),

                      const SizedBox(height: AppSpacing.xl),

                      // ============ REVIEWS ============
                      _buildReviewsSection(salon),

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: PrimaryButton(
                label: 'View All Services',
                onPressed: () {
                  // Scroll to services section or open services bottom sheet
                  Get.bottomSheet(
                    _buildServicesBottomSheet(homeController, salon),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO IMAGE SECTION
  // ============================================================
  Widget _buildHeroSliver(SalonModel salon) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.background,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Salon Image
            Image.network(
              salon.displayImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.store,
                    size: 80,
                    color: AppColors.textMuted,
                  ),
                );
              },
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER SECTION (Name, Rating, Status, Type)
  // ============================================================
  Widget _buildHeaderSection(SalonModel salon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salon Name
        Text(
          salon.name,
          style: AppTextStyles.heading.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),

        // Rating & Type Row
        Row(
          children: [
            // Rating
            RatingStars(salon.rating),
            const SizedBox(width: 6),
            Text(
              salon.rating.toStringAsFixed(1),
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (reviewStats != null) ...[
              const SizedBox(width: 6),
              Text(
                '(${reviewStats!.totalReviews})',
                style: AppTextStyles.caption,
              ),
            ],

            const SizedBox(width: AppSpacing.md),

            // Open/Closed Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: salon.isOpen
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: salon.isOpen
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    salon.isOpen ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: salon.isOpen ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    salon.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: salon.isOpen ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Salon Type & Distance
        Row(
          children: [
            const Icon(Icons.store, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              salon.salonTypeDisplay,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            
            if (salon.distance > 0) ...[
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.location_on, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${salon.distance.toStringAsFixed(1)} km away',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS (Call, Direction, Share)
  // ============================================================
  Widget _buildQuickActions(SalonModel salon) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.phone,
            label: 'Call',
            onTap: () => _makePhoneCall(salon.phone),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildActionButton(
            icon: Icons.directions,
            label: 'Direction',
            onTap: () => _openMaps(salon),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: () => _shareSalon(salon),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RATINGS & REVIEWS SUMMARY
  // ============================================================
  Widget _buildRatingsSection(SalonModel salon) {
    if (isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviewStats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ratings & Reviews',
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all reviews screen
                Get.toNamed('/salon-reviews', arguments: salon.id);
              },
              child: const Text('See All'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Rating Summary Card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Average Rating
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      reviewStats!.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    RatingStars(reviewStats!.averageRating),
                    const SizedBox(height: 4),
                    Text(
                      '${reviewStats!.totalReviews} reviews',
                      style: AppTextStyles.caption,
                    ),
                    if (reviewStats!.verifiedReviewsCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reviewStats!.verifiedReviewsCount} verified',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                    final percentage = reviewStats!.getPercentage(stars);
                    final count = reviewStats!.getCount(stars);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$stars★',
                            style: const TextStyle(fontSize: 12),
                          ),
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
        ),

        // Detailed Ratings (if available)
        if (reviewStats!.avgServiceQuality > 0) ...[
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Ratings',
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildDetailedRatingRow(
                  'Service Quality',
                  reviewStats!.avgServiceQuality,
                ),
                _buildDetailedRatingRow(
                  'Staff Behavior',
                  reviewStats!.avgStaffBehavior,
                ),
                _buildDetailedRatingRow(
                  'Ambiance',
                  reviewStats!.avgAmbiance,
                ),
                _buildDetailedRatingRow(
                  'Value for Money',
                  reviewStats!.avgValueForMoney,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.body,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rating / 5,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  rating.toStringAsFixed(1),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ABOUT SALON
  // ============================================================
  Widget _buildAboutSection(SalonModel salon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Salon',
          style: AppTextStyles.heading.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            salon.about,
            style: AppTextStyles.body.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WORKING HOURS
  // ============================================================
  Widget _buildWorkingHoursSection(SalonModel salon) {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday).toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working Hours',
          style: AppTextStyles.heading.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              'monday',
              'tuesday',
              'wednesday',
              'thursday',
              'friday',
              'saturday',
              'sunday',
            ].map((day) {
              final hours = salon.hours[day];
              final isToday = day == dayName;
              final isClosed = hours?['closed'] == true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        day.capitalizeFirst!,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? AppColors.primary : Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        isClosed
                            ? 'Closed'
                            : '${hours?['open'] ?? 'N/A'} - ${hours?['close'] ?? 'N/A'}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isClosed
                              ? Colors.red
                              : (isToday ? AppColors.primary : Colors.white),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION SECTION
  // ============================================================
  Widget _buildLocationSection(SalonModel salon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTextStyles.heading.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.fullAddress,
                          style: AppTextStyles.body.copyWith(
                            height: 1.4,
                          ),
                        ),
                        if (salon.city.isNotEmpty || salon.state.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            salon.shortLocation,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openMaps(salon),
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SERVICES SECTION
  // ============================================================
  Widget _buildServicesSection(UserHomeController homeController, SalonModel salon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: AppTextStyles.heading.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Obx(() {
          if (homeController.isLoadingServices.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (homeController.salonServices.isEmpty) {
            return GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  'No services available',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            );
          }

          // Show first 3 services
          final displayServices = homeController.salonServices.take(3).toList();

          return Column(
            children: [
              ...displayServices.map((service) {
                return _buildServiceCard(service, salon);
              }),
              
              if (homeController.salonServices.length > 3) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    Get.bottomSheet(
                      _buildServicesBottomSheet(homeController, salon),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: Text('View All ${homeController.salonServices.length} Services'),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service, SalonModel salon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Service Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getServiceIcon(service.category),
                color: AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationMinutes} min',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price & Book Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${service.price.toStringAsFixed(0)}',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    // ✅ FIXED: Navigate to select-datetime instead of booking-confirmation
                    Get.find<BookingController>().initializeBooking(
                      salon: salon,
                      service: service,
                    );
                    Get.toNamed('/select-datetime', arguments: salon);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REVIEWS SECTION
  // ============================================================
  Widget _buildReviewsSection(SalonModel salon) {
    if (isLoadingReviews || recentReviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reviews',
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/salon-reviews', arguments: salon.id);
              },
              child: const Text('See All'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        ...recentReviews.take(3).map((review) {
          return _buildReviewCard(review);
        }),
      ],
    );
  }

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
                      Text(
                        review.timeAgo,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                // Rating
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
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],

            // Review Comment
            Text(
              review.comment,
              style: AppTextStyles.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
              Text(
                '${review.helpfulCount} people found this helpful',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SERVICES BOTTOM SHEET
  // ============================================================
  Widget _buildServicesBottomSheet(UserHomeController homeController, SalonModel salon) {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Services',
                  style: AppTextStyles.heading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // Services List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: homeController.salonServices.length,
              itemBuilder: (context, index) {
                final service = homeController.salonServices[index];
                return _buildServiceCard(service, salon);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'haircut':
      case 'hair':
        return Icons.content_cut;
      case 'facial':
      case 'skin':
        return Icons.face;
      case 'massage':
        return Icons.spa;
      case 'makeup':
        return Icons.brush;
      case 'nails':
      case 'manicure':
      case 'pedicure':
        return Icons.back_hand;
      default:
        return Icons.star;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('Error', 'Could not make phone call');
    }
  }

  Future<void> _openMaps(SalonModel salon) async {
    // Try to open in Google Maps
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(salon.fullAddress)}';
    
    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open maps');
    }
  }

  void _shareSalon(SalonModel salon) {
    // Implement share functionality
    Get.snackbar(
      'Share',
      'Share functionality will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}