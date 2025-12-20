import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      body: Obx(() {
        final profile = ctrl.salonProfile.value;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //------------------------- HEADER -------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // PROFILE MENU
                    PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      icon: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: profile.imageUrl.isNotEmpty
                            ? NetworkImage(profile.imageUrl)
                            : const AssetImage("assets/user.png")
                                  as ImageProvider,
                      ),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: "profile", child: Text("Profile")),
                        PopupMenuItem(
                          value: "settings",
                          child: Text("Settings"),
                        ),
                        PopupMenuItem(value: "logout", child: Text("Logout")),
                      ],
                      onSelected: (value) async {
                        if (value == "profile") {
                          Get.toNamed(AppRoutes.adminProfile);
                        } else if (value == "settings") {
                          Get.toNamed(AppRoutes.adminSettings);
                        } else if (value == "logout") {
                          ctrl.logout();
                          Get.offAllNamed(AppRoutes.login);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                //---------------------- GREETING -------------------------
                Text(
                  "Welcome back, ${profile.name}!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Here’s your salon activity today.",
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 25),

                //---------------------- KPI CARDS -------------------------
                Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        "Today's Bookings",
                        ctrl.todayBookings.toString(),
                        Icons.calendar_month,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _kpiCard(
                        "Employees",
                        ctrl.employeesList.length.toString(),
                        Icons.people_alt,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        "Pending",
                        ctrl.pendingBookings.toString(),
                        Icons.timelapse,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _kpiCard(
                        "Completed",
                        ctrl.completedBookings.toString(),
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                //-------------------- WEEKLY OVERVIEW --------------------
                _sectionCard(
                  "Weekly Overview",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${ctrl.weeklyBookings} Bookings",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Chart placeholder
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Mon"),
                          Text("Tue"),
                          Text("Wed"),
                          Text("Thu"),
                          Text("Fri"),
                          Text("Sat"),
                          Text("Sun"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //---------------------- TOP STAFF ----------------------
                _sectionCard(
                  "Top Staff",
                  Column(
                    children: ctrl.topStaff
                        .map(
                          (e) => _rankingTile(
                            e['name'],
                            "${e['count']} Bookings",
                            e['rank'],
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 25),

                //---------------------- POPULAR SERVICES ----------------------
                _sectionCard(
                  "Popular Services",
                  Column(
                    children: ctrl.popularServices
                        .map(
                          (e) => _serviceTile(
                            e['name'],
                            "${e['count']} Bookings",
                            e['rank'],
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------- KPI CARD ----------------
  Widget _kpiCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 30),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------- SECTION CARD ----------------
  Widget _sectionCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  // ---------------- RANKING TILE ----------------
  Widget _rankingTile(String name, String subtitle, int rank) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade300,
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(subtitle),
      trailing: Text(
        "#$rank",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
        ),
      ),
    );
  }

  // ---------------- SERVICE TILE ----------------
  Widget _serviceTile(String name, String subtitle, int rank) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.pink.shade50,
        child: const Icon(Icons.spa, color: Colors.pinkAccent),
      ),
      title: Text(name),
      subtitle: Text(subtitle),
      trailing: Text(
        "#$rank",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
        ),
      ),
    );
  }
}
