import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/controllers/admin_dashboard_controller.dart';
import 'package:salon_booking/views/admin/admin_revenue_screen.dart';
import 'package:salon_booking/views/admin/admin_bookings_screen.dart';
import 'package:salon_booking/widgets/dashboard_stat_card.dart';
import 'package:salon_booking/widgets/charts/weekly_revenue_chart.dart';
import 'package:salon_booking/widgets/ai_badge.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // 🎨 Color System
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        titleSpacing: 20,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Welcome back, Admin",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Obx(
            () => controller.isLoading.value
                ? const LinearProgressIndicator(
                    color: accent,
                    backgroundColor: Colors.transparent,
                    minHeight: 2,
                  )
                : const SizedBox(height: 2),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.recentBookings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: accent),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: accent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  /// 🔮 AI Optimization Card
                  _buildAIOptimizationCard(controller),

                  const SizedBox(height: 20),

                  /// 📊 Quick Stats Cards
                  _buildSectionHeader("Today's Metrics"),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      DashboardStatCard(
                        title: "Today's Revenue",
                        value: "₹${controller.todayRevenue.toStringAsFixed(0)}",
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                        subtitle: "TODAY",
                      ),
                      DashboardStatCard(
                        title: "Today's Bookings",
                        value: "${controller.todayBookings}",
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        subtitle: "ACTIVE",
                      ),
                      DashboardStatCard(
                        title: "Pending Bookings",
                        value: "${controller.pendingBookings}",
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                        subtitle: "PENDING",
                      ),
                      DashboardStatCard(
                        title: "Completion Rate",
                        value:
                            "${controller.completionRate.toStringAsFixed(0)}%",
                        icon: Icons.check_circle_outline,
                        color: accent,
                        subtitle: "RATE",
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// 📈 Weekly Revenue Chart
                  _buildSectionHeader("Weekly Revenue"),
                  const SizedBox(height: 12),
                  _buildWeeklyRevenueChart(controller),

                  const SizedBox(height: 24),

                  /// 💰 Revenue Forecast Card
                  _buildRevenueForecastCard(controller),

                  const SizedBox(height: 24),

                  /// 🎯 Quick Actions
                  _buildSectionHeader("Quick Actions"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          "View Revenue",
                          Icons.attach_money,
                          Colors.green,
                          () => Get.to(() => AdminRevenueScreen()),
                        ),
                      ),
                      const SizedBox(width: 1),
                      Expanded(
                        child: _buildActionButton(
                          "Manage Booking",
                          Icons.calendar_month,
                          Colors.blue,
                          () => Get.to(() => AdminBookingsScreen()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// 🚨 Live Alerts
                  _buildLiveAlertsCard(controller),

                  const SizedBox(height: 24),

                  /// 📋 Recent Bookings
                  _buildSectionHeader("Recent Bookings"),
                  const SizedBox(height: 12),
                  ...controller.recentBookings.map(
                    (booking) => _buildBookingTile(booking),
                  ),

                  if (controller.recentBookings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: const Text(
                        "No recent bookings",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAIOptimizationCard(AdminDashboardController controller) {
    final peakBookings = controller.todayBookings;
    final avgRevenue = controller.todayBookings > 0
        ? controller.todayRevenue / controller.todayBookings
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: accent),
              const SizedBox(width: 8),
              const Text(
                "AI Optimization",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              aiBadge("LIVE"),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            peakBookings > 10
                ? "🚀 High demand detected! Consider adding staff during peak hours to maximize revenue."
                : "💡 Optimize your schedule by focusing on high-revenue services. Average booking value: ₹${avgRevenue.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withOpacity(0.5)),
                ),
                onPressed: () {},
                child: const Text("View Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRevenueChart(AdminDashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Last 7 Days",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              Text(
                "₹${controller.weekRevenue.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final dailyData = controller.revenueController.dailyRevenue;
            if (dailyData.isEmpty) {
              return Container(
                height: 150,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "No data available",
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              );
            }

            return WeeklyRevenueChart(
              dailyData: dailyData.cast<Map<String, dynamic>>(),
              barColor: accent,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRevenueForecastCard(AdminDashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Revenue Forecast",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              aiBadge("AI"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildForecastItem(
                "This Week",
                "₹${controller.weekRevenue.toStringAsFixed(0)}",
                Colors.blue,
              ),
              Container(height: 40, width: 1, color: Colors.white12),
              _buildForecastItem(
                "This Month",
                "₹${controller.monthRevenue.toStringAsFixed(0)}",
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLiveAlertsCard(AdminDashboardController controller) {
    final pendingCount = controller.pendingBookings;
    final hasAlert = pendingCount > 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAlert
              ? Colors.orange.withOpacity(0.3)
              : Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasAlert ? Icons.warning_amber : Icons.check_circle,
                color: hasAlert ? Colors.orange : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hasAlert ? "Pending Alert" : "All Systems Normal",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasAlert
                ? "You have $pendingCount pending bookings. Consider confirming or updating their status."
                : "Dashboard running smoothly. No critical alerts.",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (hasAlert) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Get.to(() => AdminBookingsScreen()),
              child: const Text("View Bookings"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTile(dynamic booking) {
    final statusColor = _getStatusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_today, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName ?? "No Name",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${booking.serviceName} • ${booking.time}",
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
