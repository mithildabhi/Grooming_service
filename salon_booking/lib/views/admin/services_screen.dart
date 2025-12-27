import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/service_model.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load services when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Get.find<AdminController>();
      ctrl.fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "AI Service Performance",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Get.to(() => const AddServiceScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingServices.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        final allServices = ctrl.servicesList;
        final filteredServices = _getFilteredServices(allServices);

        if (allServices.isEmpty) {
          return _emptyState();
        }

        return RefreshIndicator(
          color: accent,
          onRefresh: () => ctrl.fetchServices(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧠 AI OVERVIEW
                _aiInsightsCard(allServices),

                const SizedBox(height: 24),

                // 📊 PERFORMANCE STATS
                _performanceStats(allServices),

                const SizedBox(height: 28),

                // 🔎 FILTERS
                _sectionTitle("Filters"),
                const SizedBox(height: 10),
                _filterChips(),

                const SizedBox(height: 28),

                // ✂️ SERVICE LIST
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("Services (${filteredServices.length})"),
                    TextButton.icon(
                      onPressed: () => Get.to(() => const AddServiceScreen()),
                      icon: const Icon(Icons.add, color: accent, size: 18),
                      label: const Text(
                        "Add Service",
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (filteredServices.isEmpty)
                  _noServicesForFilter()
                else
                  ...filteredServices.map((service) => _serviceTile(service)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ───────── FILTERING LOGIC ─────────

  List<ServiceModel> _getFilteredServices(List<ServiceModel> services) {
    switch (selectedFilter) {
      case 'Trending':
        return services.where((s) => _isTrending(s)).toList();
      case 'Low Performance':
        return services.where((s) => _needsAttention(s)).toList();
      case 'Inactive':
        return services.where((s) => !s.isActive).toList();
      default:
        return services;
    }
  }

  bool _isTrending(ServiceModel service) {
    // Services under 45 mins are trending
    return service.isActive && service.duration <= 45;
  }

  bool _needsAttention(ServiceModel service) {
    // Services over 60 mins or very low price
    return service.isActive && (service.duration > 60 || service.price < 200);
  }

  String _getPerformanceLabel(ServiceModel service) {
    if (!service.isActive) return 'Inactive';
    if (_isTrending(service)) return 'Trending';
    if (_needsAttention(service)) return 'Needs Attention';
    return 'Active';
  }

  Color _getPerformanceColor(ServiceModel service) {
    if (!service.isActive) return Colors.redAccent;
    if (_isTrending(service)) return Colors.greenAccent;
    if (_needsAttention(service)) return Colors.orangeAccent;
    return Colors.blueAccent;
  }

  // ───────── UI COMPONENTS ─────────

  Widget _aiInsightsCard(List<ServiceModel> services) {
    final trending = services.where((s) => _isTrending(s)).length;
    final needsAttention = services.where((s) => _needsAttention(s)).length;

    String insight = "No services yet. Add your first service to get started!";
    
    if (services.isNotEmpty) {
      if (trending > 0 && needsAttention == 0) {
        insight = "Great! You have $trending trending services. Keep up the good work!";
      } else if (needsAttention > 0 && trending > 0) {
        insight = "$trending services are trending this week. $needsAttention services need attention.";
      } else if (needsAttention > 0) {
        insight = "$needsAttention services need attention. Consider optimizing duration or pricing.";
      } else {
        insight = "All services are performing well. Keep monitoring for trends.";
      }
    }

    return _cardBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, color: accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Service Insights",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceStats(List<ServiceModel> services) {
    final trending = services.where((s) => _isTrending(s)).length;
    final needsAttention = services.where((s) => _needsAttention(s)).length;
    final inactive = services.where((s) => !s.isActive).length;

    return Row(
      children: [
        Expanded(
          child: _ServiceStat(
            title: "Trending",
            value: trending.toString(),
            color: Colors.greenAccent,
            onTap: () {
              setState(() => selectedFilter = 'Trending');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ServiceStat(
            title: "Needs Attention",
            value: needsAttention.toString(),
            color: Colors.orangeAccent,
            onTap: () {
              setState(() => selectedFilter = 'Low Performance');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ServiceStat(
            title: "Inactive",
            value: inactive.toString(),
            color: Colors.redAccent,
            onTap: () {
              setState(() => selectedFilter = 'Inactive');
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _filterChip("All"),
        _filterChip("Trending"),
        _filterChip("Low Performance"),
        _filterChip("Inactive"),
      ],
    );
  }

  Widget _filterChip(String label) {
    final active = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? accent.withOpacity(0.2) : card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? accent : Colors.white70,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _serviceTile(ServiceModel service) {
    final performanceLabel = _getPerformanceLabel(service);
    final performanceColor = _getPerformanceColor(service);

    return GestureDetector(
      onTap: () {
        Get.to(
          () => const EditServiceScreen(),
          arguments: service,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: performanceColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(service.category),
                color: performanceColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${service.duration} mins • ₹${service.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Performance Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: performanceColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                performanceLabel,
                style: TextStyle(
                  color: performanceColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text(
            "No Services Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Add your first service to get started",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddServiceScreen()),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              "Add Service",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noServicesForFilter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.filter_alt_off, size: 60, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              "No services found for '$selectedFilter'",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _cardBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hair':
        return Icons.content_cut;
      case 'spa':
        return Icons.spa;
      case 'nails':
        return Icons.back_hand;
      case 'facial':
        return Icons.face;
      case 'massage':
        return Icons.self_improvement;
      case 'waxing':
        return Icons.brush;
      case 'makeup':
        return Icons.face_retouching_natural;
      default:
        return Icons.miscellaneous_services;
    }
  }
}

// ───────── SUB WIDGET ─────────

class _ServiceStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ServiceStat({
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121A22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}