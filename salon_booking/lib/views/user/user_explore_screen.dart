import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_home_controller.dart';
import '../../models/salon_model.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/ai_insight_card.dart';
import '../../widgets/ui/chip_pill.dart';
import '../../widgets/ui/section_header.dart';

class UserExploreScreen extends StatefulWidget {
  const UserExploreScreen({super.key});

  @override
  State<UserExploreScreen> createState() => _UserExploreScreenState();
}

class _UserExploreScreenState extends State<UserExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString sortBy = 'distance'.obs;
  final RxBool showOpenOnly = false.obs;
  final RxDouble minRating = 0.0.obs;

  late final UserHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserHomeController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SalonModel> _getFilteredSalons(List<SalonModel> salons) {
    var filtered = salons.where((salon) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!salon.name.toLowerCase().contains(query) &&
            !salon.address.toLowerCase().contains(query) &&
            !salon.services.any((s) => s.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Open only filter
      if (showOpenOnly.value && !salon.isOpen) {
        return false;
      }

      // Rating filter
      if (salon.rating < minRating.value) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (sortBy.value) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'distance':
      default:
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
    }

    return filtered;
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: AppTextStyles.heading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    sortBy.value = 'distance';
                    showOpenOnly.value = false;
                    minRating.value = 0.0;
                    Get.back();
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Sort By
            Text(
              'Sort By',
              style: AppTextStyles.subHeading.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Obx(
              () => Wrap(
                spacing: AppSpacing.sm,
                children: [
                  _FilterChip(
                    label: 'Distance',
                    selected: sortBy.value == 'distance',
                    onTap: () => sortBy.value = 'distance',
                  ),
                  _FilterChip(
                    label: 'Rating',
                    selected: sortBy.value == 'rating',
                    onTap: () => sortBy.value = 'rating',
                  ),
                  _FilterChip(
                    label: 'Name',
                    selected: sortBy.value == 'name',
                    onTap: () => sortBy.value = 'name',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Open Now Filter
            Obx(
              () => SwitchListTile(
                title: Text('Open Now Only', style: AppTextStyles.body),
                value: showOpenOnly.value,
                onChanged: (val) => showOpenOnly.value = val,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Rating Filter
            Text(
              'Minimum Rating',
              style: AppTextStyles.subHeading.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: minRating.value,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: AppColors.primary,
                      onChanged: (val) => minRating.value = val,
                    ),
                  ),
                  Text(
                    minRating.value.toStringAsFixed(1),
                    style: AppTextStyles.subHeading.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
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

            final filteredSalons = _getFilteredSalons(controller.nearbySalons);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Explore',
                              style: AppTextStyles.heading.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            GlassCard(
                              width: 40,
                              height: 40,
                              padding: EdgeInsets.zero,
                              onTap: _showFilterSheet,
                              child: const Icon(
                                Icons.filter_list,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Functional Search Bar
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: AppColors.textMuted,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => searchQuery.value = val,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search salons, services, stylists',
                                    hintStyle: AppTextStyles.body.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              if (searchQuery.value.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    searchQuery.value = '';
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.textMuted,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: _showFilterSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _CategoryRow(
                          selectedIndex: selectedCategoryIndex,
                          onCategorySelected: (index) {
                            selectedCategoryIndex.value = index;
                            // Filter by category
                            final categories = [
                              'All',
                              'Hair',
                              'Spa',
                              'Makeup',
                              'Nails',
                              'Massage',
                            ];
                            if (index == 0) {
                              searchQuery.value = '';
                              _searchController.clear();
                            } else {
                              searchQuery.value = categories[index];
                              _searchController.text = categories[index];
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        const AiInsightCard(
                          title: 'AI Match',
                          description:
                              'Based on your preferences, these salons fit your style best.',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const SectionHeader(title: 'Salons Near You'),
                        const Spacer(),
                        Text(
                          '${filteredSalons.length} found',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: filteredSalons.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No salons found',
                                    style: AppTextStyles.subHeading,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Try adjusting your filters',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final salon = filteredSalons[index];
                            return _ExploreSalonCard(salon: salon);
                          }, childCount: filteredSalons.length),
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/* ───────────────── FILTER CHIP ───────────────── */

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: selected ? Colors.black : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/* ───────────────── CATEGORY ROW ───────────────── */

class _CategoryRow extends StatelessWidget {
  final RxInt selectedIndex;
  final Function(int) onCategorySelected;

  const _CategoryRow({
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'All', 'icon': Icons.apps},
      {'name': 'Hair', 'icon': Icons.content_cut},
      {'name': 'Spa', 'icon': Icons.spa},
      {'name': 'Makeup', 'icon': Icons.face},
      {'name': 'Nails', 'icon': Icons.brush},
      {'name': 'Massage', 'icon': Icons.airline_seat_flat},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = selectedIndex.value == index;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChipPill(
                label: category['name'] as String,
                selected: isSelected,
                onTap: () => onCategorySelected(index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/* ───────────────── SALON CARD ───────────────── */

class _ExploreSalonCard extends StatelessWidget {
  final SalonModel salon;

  const _ExploreSalonCard({required this.salon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/salon-details', arguments: salon),
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
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
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
                    if (salon.services.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: salon.services
                            .take(3)
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Text(
                                  s,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
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
