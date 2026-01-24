import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_home_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../models/salon_model.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/ai_badge.dart';
import '../../widgets/ui/primary_button.dart';
import '../../widgets/ui/chip_pill.dart';
import '../../widgets/ui/section_header.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserHomeController>();
    final bookingController = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshSalons(),
          color: AppColors.primary,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const _Header(),
                const SizedBox(height: AppSpacing.lg),
                const _SearchBar(),
                const SizedBox(height: AppSpacing.lg),
                Obx(() {
                  final up = bookingController.upcomingBookings;
                  if (up.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Upcoming Appointments'),
                        const SizedBox(height: AppSpacing.sm),
                        _UpcomingAppointmentCard(booking: up.first),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const _AiPickCard(),
                const SizedBox(height: AppSpacing.lg),
                const _CategoryRow(),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Nearby Salons'),
                const SizedBox(height: AppSpacing.sm),
                Obx(() {
                  final list = controller.nearbySalons;
                  if (list.isEmpty) {
                    return const _NearbyEmptyState();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...list.map((salon) => _NearbySalonCard(salon: salon)),
                    ],
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/* ───────────────── HEADER ───────────────── */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    
    return Row(
      children: [
        Obx(() => CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: userController.userName.value.isNotEmpty
              ? Text(
                  userController.userName.value[0].toUpperCase(),
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(Icons.person, color: AppColors.primary, size: 24),
        )),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Obx(() => Text(
                userController.userName.value.isNotEmpty
                    ? userController.userName.value
                    : 'Welcome 👋',
                style: AppTextStyles.subHeading.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
        ),
        GlassCard(
          width: 48,
          height: 48,
          padding: EdgeInsets.zero,
          child: const Icon(
            Icons.notifications_none,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

/* ───────────────── SEARCH ───────────────── */

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textMuted, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Find services, stylists, or salons…',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.mic, color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── AI PICK ───────────────── */

class _AiPickCard extends StatelessWidget {
  const _AiPickCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: AppColors.primary.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiBadge('AI Pick'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Premium Hair Treatment',
            style: AppTextStyles.subHeading.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recommended based on your preferences',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹899',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Special Price',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: PrimaryButton(
                  label: 'View Deal',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ───────────────── CATEGORIES ───────────────── */

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Haircut', 'icon': Icons.content_cut},
      {'name': 'Spa', 'icon': Icons.spa},
      {'name': 'Makeup', 'icon': Icons.face},
      {'name': 'Nails', 'icon': Icons.brush},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final isSelected = index == 0;
          
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChipPill(
              label: category['name'] as String,
              selected: isSelected,
              onTap: () {},
            ),
          );
        }).toList(),
      ),
    );
  }
}

/* ───────────────── UPCOMING ───────────────── */

class _UpcomingAppointmentCard extends StatelessWidget {
  final dynamic booking;

  const _UpcomingAppointmentCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        Get.toNamed('/appointment-details', arguments: booking);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _getMonth(booking.date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getDay(booking.date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.salonName,
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.serviceName,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(booking.time),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(String date) {
    try {
      final d = DateTime.parse(date);
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      return months[d.month - 1];
    } catch (e) {
      return 'OCT';
    }
  }

  String _getDay(String date) {
    try {
      final d = DateTime.parse(date);
      return d.day.toString();
    } catch (e) {
      return '24';
    }
  }

  static String _formatTime(String t) {
    if (t.isEmpty) return '--:--';
    if (t.length >= 5) return t.substring(0, 5);
    return t;
  }
}

/* ───────────────── NEARBY EMPTY ───────────────── */

class _NearbyEmptyState extends StatelessWidget {
  const _NearbyEmptyState();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.sm),
          Text('No salons in your area', style: AppTextStyles.subHeading),
          const SizedBox(height: 4),
          Text('Pull down to refresh', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/* ───────────────── SALON CARD ───────────────── */

class _NearbySalonCard extends StatelessWidget {
  final SalonModel salon;

  const _NearbySalonCard({required this.salon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/salon-details', arguments: salon);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      salon.imageUrl.isNotEmpty
                          ? salon.imageUrl
                          : 'https://via.placeholder.com/400x300?text=Salon',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: AppColors.surface,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: salon.isOpen
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        salon.isOpen ? 'Open' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            salon.name,
                            style: AppTextStyles.subHeading.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                salon.rating.toStringAsFixed(1),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            salon.address,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
