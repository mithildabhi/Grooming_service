// lib/widgets/charts/weekly_revenue_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyRevenueChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;
  final Color barColor;

  const WeeklyRevenueChart({
    super.key,
    required this.dailyData,
    this.barColor = const Color(0xFF19F6E8),
  });

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Take last 7 days
    final last7Days = dailyData.take(7).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(last7Days),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '₹${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= last7Days.length) {
                    return const SizedBox();
                  }
                  final data = last7Days[value.toInt()];
                  final date = data['date'] as String;
                  final day = _getDayName(date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxY(last7Days) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _createBarGroups(last7Days),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final revenue = (item['revenue'] ?? 0).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: revenue,
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(data),
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 1000;
    
    final maxRevenue = data.fold<double>(
      0,
      (max, item) => ((item['revenue'] ?? 0) as num).toDouble() > max 
          ? ((item['revenue'] ?? 0) as num).toDouble() 
          : max,
    );
    
    // Round up to nearest 100
    return ((maxRevenue / 100).ceil() * 100).toDouble() + 100;
  }

  String _getDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } catch (e) {
      return '';
    }
  }
}
