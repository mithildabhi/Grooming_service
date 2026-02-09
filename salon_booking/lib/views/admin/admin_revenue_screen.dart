// lib/screens/admin/admin_revenue_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/revenue_controller.dart';
import '../../controllers/revenue_controller.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_snackbar.dart';

class AdminRevenueScreen extends StatelessWidget {
  AdminRevenueScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);
  static const Color green = Color(0xFF4CAF50);
  static const Color orange = Color(0xFFFF9800);
  static const Color purple = Color(0xFF9C27B0);

  final RevenueController controller = Get.put(RevenueController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          '💰 Revenue Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _showDateRangePicker(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.revenueData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: accent,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview Cards
              _overviewCards(),
              const SizedBox(height: 20),

              // Today's Performance
              _sectionTitle('Today\'s Performance'),
              const SizedBox(height: 12),
              _todayPerformance(),
              const SizedBox(height: 20),

              // Revenue Trend
              _sectionTitle('Revenue Breakdown'),
              const SizedBox(height: 12),
              _revenueTrendCard(),
              const SizedBox(height: 20),

              // Top Services Button
              _actionButton(
                'Top Earning Services',
                Icons.star,
                Colors.amber,
                () => Get.toNamed('/admin/revenue/services'),
              ),
              const SizedBox(height: 12),

              // Staff Performance Button
              _actionButton(
                'Staff Performance',
                Icons.people,
                Colors.blue,
                () => Get.toNamed('/admin/revenue/staff'),
              ),
              const SizedBox(height: 12),

              // Detailed Reports Button
              _actionButton(
                'Detailed Reports',
                Icons.analytics,
                purple,
                () => Get.toNamed('/admin/revenue/reports'),
              ),
              const SizedBox(height: 20),

              // Metrics
              _metricsCard(),
            ],
          ),
        );
      }),
    );
  }

  // ===========================
  // OVERVIEW CARDS
  // ===========================
  Widget _overviewCards() {
    return Obx(() {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _revenueCard(
                  'Total Revenue',
                  controller.totalRevenue,
                  Icons.monetization_on,
                  green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _revenueCard(
                  'This Month',
                  controller.monthRevenue,
                  Icons.calendar_month,
                  accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _revenueCard(
                  'This Week',
                  controller.weekRevenue,
                  Icons.date_range,
                  purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _revenueCard(
                  'Pending',
                  controller.pendingRevenue,
                  Icons.pending,
                  orange,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _revenueCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${NumberFormat('#,##,###').format(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // TODAY'S PERFORMANCE
  // ===========================
  Widget _todayPerformance() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent.withOpacity(0.2), purple.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _performanceItem(
              'Revenue',
              '₹${controller.todayRevenue.toStringAsFixed(0)}',
              Icons.attach_money,
              green,
            ),
            Container(
              height: 50,
              width: 1,
              color: Colors.white24,
            ),
            _performanceItem(
              'Bookings',
              controller.todayBookings.toString(),
              Icons.event,
              accent,
            ),
            Container(
              height: 50,
              width: 1,
              color: Colors.white24,
            ),
            _performanceItem(
              'Avg Value',
              '₹${controller.averageBookingValue.toStringAsFixed(0)}',
              Icons.trending_up,
              purple,
            ),
          ],
        ),
      );
    });
  }

  Widget _performanceItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ===========================
  // REVENUE TREND
  // ===========================
  Widget _revenueTrendCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Week',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${controller.weekRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.completionRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _trendItem('Today', controller.todayRevenue),
                _trendItem('Week', controller.weekRevenue),
                _trendItem('Month', controller.monthRevenue),
                _trendItem('Year', controller.yearRevenue),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _trendItem(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${_formatCompact(value)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCompact(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  // ===========================
  // ACTION BUTTON
  // ===========================
  Widget _actionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  // ===========================
  // METRICS CARD
  // ===========================
  Widget _metricsCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _metricRow(
              'Total Bookings',
              controller.totalBookings.toString(),
              Icons.event_note,
            ),
            const SizedBox(height: 12),
            _metricRow(
              'Average Booking Value',
              '₹${controller.averageBookingValue.toStringAsFixed(0)}',
              Icons.payment,
            ),
            const SizedBox(height: 12),
            _metricRow(
              'Completion Rate',
              '${controller.completionRate.toStringAsFixed(1)}%',
              Icons.check_circle,
            ),
          ],
        ),
      );
    });
  }

  Widget _metricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ===========================
  // SECTION TITLE
  // ===========================
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

  // ===========================
  // DATE RANGE PICKER
  // ===========================
  void _showDateRangePicker(BuildContext context) {
    // TODO: Implement date range picker for custom reports
    CustomSnackbar.show(
      title: 'Coming Soon',
      message: 'Custom date range selection will be available soon',
    );
  }
}