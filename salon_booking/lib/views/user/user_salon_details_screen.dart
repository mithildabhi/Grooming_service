import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/salon_model.dart';
import '../../models/service_model.dart';
import '../../controllers/user_home_controller.dart';
import '../../controllers/booking_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/ai_insight_card.dart';
import '../../widgets/ui/primary_button.dart';
import '../../widgets/ui/rating_stars.dart';
import '../../widgets/ui/section_header.dart';

class UserSalonDetailsScreen extends StatefulWidget {
  const UserSalonDetailsScreen({super.key});

  @override
  State<UserSalonDetailsScreen> createState() => _UserSalonDetailsScreenState();
}

class _UserSalonDetailsScreenState extends State<UserSalonDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is SalonModel) {
      Get.find<UserHomeController>().fetchSalonServices(args.id);
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
              _HeroSliver(salon: salon),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ───────────── HEADER INFO ─────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  salon.name,
                                  style: AppTextStyles.heading.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    RatingStars(salon.rating),
                                    const SizedBox(width: 6),
                                    Text(
                                      salon.rating.toStringAsFixed(1),
                                      style: AppTextStyles.subHeading.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: salon.isOpen
                                            ? Colors.green.withOpacity(0.15)
                                            : Colors.red.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        salon.isOpen ? 'Open Now' : 'Closed',
                                        style: AppTextStyles.caption.copyWith(
                                          color: salon.isOpen
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      /// ───────────── LOCATION ─────────────
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              salon.address,
                              style: AppTextStyles.body,
                            ),
                          ),
                          Text(
                            '${salon.distance.toStringAsFixed(1)} km',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// ───────────── AI INSIGHT ─────────────
                      const AiInsightCard(
                        title: 'AI Insight',
                        description:
                            'This salon is quieter on weekday afternoons — ideal for relaxed sessions.',
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// ───────────── ABOUT ─────────────
                      if (salon.about.isNotEmpty) ...[
                        const SectionHeader(title: 'About'),
                        const SizedBox(height: AppSpacing.sm),
                        GlassCard(
                          child: Text(
                            salon.about,
                            style: AppTextStyles.body,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      /// ───────────── SERVICES ─────────────
                      const SectionHeader(title: 'Services'),
                      const SizedBox(height: AppSpacing.sm),

                      Obx(() {
                        if (homeController.isLoadingServices.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        if (homeController.salonServices.isEmpty) {
                          return GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.spa_outlined,
                                  size: 48,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'No services available',
                                  style: AppTextStyles.subHeading,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Check back later for new services',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: homeController.salonServices
                              .map((service) => _ServiceTile(
                                    service: service,
                                    salon: salon,
                                  ))
                              .toList(),
                        );
                      }),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// ───────────── STICKY CTA BAR ─────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(() {
                final hasServices = homeController.salonServices.isNotEmpty;
                return PrimaryButton(
                  label: hasServices
                      ? 'Select a Service to Book'
                      : 'Book Appointment',
                  onPressed: hasServices
                      ? () {}
                      : () => Get.toNamed('/select-datetime', arguments: salon),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── HERO SLIVER ───────────────── */

class _HeroSliver extends StatelessWidget {
  final SalonModel salon;

  const _HeroSliver({required this.salon});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              salon.imageUrl.isNotEmpty
                  ? salon.imageUrl
                  : 'https://via.placeholder.com/400x300?text=Salon',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
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
}

/* ───────────────── SERVICE TILE ───────────────── */

class _ServiceTile extends StatelessWidget {
  final ServiceModel service;
  final SalonModel salon;

  const _ServiceTile({required this.service, required this.salon});

  @override
  Widget build(BuildContext context) {
    final BookingController bookingController = Get.find<BookingController>();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: () {
          bookingController.initializeBooking(
            salon: salon,
            service: service,
          );
          Get.toNamed('/select-datetime', arguments: salon);
        },
        child: Row(
          children: [
            /// SERVICE ICON
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.spa,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            /// SERVICE DETAILS
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
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
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

            /// PRICE
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
