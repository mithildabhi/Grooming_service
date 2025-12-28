import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/employee_model.dart';
import 'new_staff_member_screen.dart';
import 'edit_staff_member_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Get.find<AdminController>();
      ctrl.fetchStaff();
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
          "AI Staff Intelligence",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Get.to(() => const NewStaffMemberScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingStaff.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        final allStaff = ctrl.staffList;
        final filteredStaff = _getFilteredStaff(allStaff);

        if (allStaff.isEmpty) {
          return _emptyState();
        }

        return RefreshIndicator(
          color: accent,
          onRefresh: () => ctrl.fetchStaff(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _aiInsightsCard(allStaff),
                const SizedBox(height: 24),
                _staffStats(allStaff),
                const SizedBox(height: 28),
                _sectionTitle("Filters"),
                const SizedBox(height: 10),
                _filterChips(),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("Staff Members (${filteredStaff.length})"),
                    TextButton.icon(
                      onPressed: () => Get.to(() => const NewStaffMemberScreen()),
                      icon: const Icon(Icons.add, color: accent, size: 18),
                      label: const Text(
                        "Add Staff",
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filteredStaff.isEmpty)
                  _noStaffForFilter()
                else
                  ...filteredStaff.map((staff) => _staffTile(staff)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  List<EmployeeModel> _getFilteredStaff(List<EmployeeModel> staff) {
    switch (selectedFilter) {
      case 'Top Performer':
        return staff.where((s) => s.performanceStatus == 'Top Performer' && s.isActive).toList();
      case 'Overloaded':
        return staff.where((s) => s.performanceStatus == 'Overloaded' && s.isActive).toList();
      case 'Available':
        return staff.where((s) => s.performanceStatus == 'Available' && s.isActive).toList();
      case 'Inactive':
        return staff.where((s) => !s.isActive).toList();
      default:  // "All" - show EVERYONE (active + inactive)
        return staff;  // ← Changed: show all staff including inactive
      }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Top Performer':
        return Colors.greenAccent;
      case 'Overloaded':
        return Colors.orangeAccent;
      case 'Available':
        return accent;
      default:
        return Colors.blueAccent;
    }
  }

    Widget _aiInsightsCard(List<EmployeeModel> staff) {
      final activeStaff = staff.where((s) => s.isActive).toList();
      final topPerformers = activeStaff.where((s) => s.performanceStatus == 'Top Performer').length;
      final overloaded = activeStaff.where((s) => s.performanceStatus == 'Overloaded').length;
      final inactiveCount = staff.where((s) => !s.isActive).length;

      String insight = "No staff yet. Add your first team member to get started!";
      
      if (staff.isNotEmpty) {
        if (inactiveCount > 0 && activeStaff.isEmpty) {
          insight = "All $inactiveCount staff members are inactive. Activate them to start operations.";
        } else if (activeStaff.isNotEmpty) {
          if (topPerformers > 0 && overloaded == 0) {
            insight = "Great! You have $topPerformers top performers. Team is working efficiently!";
          } else if (overloaded > 0 && topPerformers > 0) {
            insight = "$topPerformers staff are top performers. $overloaded members show signs of overload.";
          } else if (overloaded > 0) {
            insight = "$overloaded staff members are overloaded. Consider redistributing workload.";
          } else {
            insight = "Your team is performing well. Keep monitoring for optimization opportunities.";
          }
          
          if (inactiveCount > 0) {
            insight += " ($inactiveCount inactive)";
          }
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
                    "AI Staff Insights",
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

    Widget _staffStats(List<EmployeeModel> staff) {
      // Only count active staff for performance stats
      final activeStaff = staff.where((s) => s.isActive).toList();
      final topPerformers = activeStaff.where((s) => s.performanceStatus == 'Top Performer').length;
      final overloaded = activeStaff.where((s) => s.performanceStatus == 'Overloaded').length;
      final available = activeStaff.where((s) => s.performanceStatus == 'Available').length;

      return Row(
        children: [
          Expanded(
            child: _StaffStat(
              title: "Top Performers",
              value: topPerformers.toString(),
              color: Colors.greenAccent,
              onTap: () => setState(() => selectedFilter = 'Top Performer'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StaffStat(
              title: "Overloaded",
              value: overloaded.toString(),
              color: Colors.orangeAccent,
              onTap: () => setState(() => selectedFilter = 'Overloaded'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StaffStat(
              title: "Available",
              value: available.toString(),
              color: accent,  
              onTap: () => setState(() => selectedFilter = 'Available'),
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
        _filterChip("Top Performer"),
        _filterChip("Overloaded"),
        _filterChip("Available"),
        _filterChip("Inactive"), 

      ],
    );
  }

  Widget _filterChip(String label) {
    final active = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
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

    Widget _staffTile(EmployeeModel staff) {
      // Determine status based on isActive first
      final String displayStatus;
      final Color statusColor;
      
      if (!staff.isActive) {
        // If inactive, always show "Inactive"
        displayStatus = 'Inactive';
        statusColor = Colors.grey;
      } else {
        // If active, show performance status
        displayStatus = staff.performanceStatus;
        statusColor = _getStatusColor(staff.performanceStatus);
      }

      return Opacity(  // ← WRAP WITH OPACITY WIDGET
        opacity: staff.isActive ? 1.0 : 0.6,  // ← Dim if inactive
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => const EditStaffMemberScreen(),
              arguments: staff,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              // REMOVE opacity from here - it doesn't exist
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.role,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.isActive 
                            ? "Performance: ${staff.performanceScore}"
                            : "Status: Inactive",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text(
            "No Staff Members Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Add your first team member to get started",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const NewStaffMemberScreen()),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              "Add Staff Member",
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

  Widget _noStaffForFilter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.filter_alt_off, size: 60, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              "No staff found for '$selectedFilter'",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

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
}

class _StaffStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StaffStat({
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