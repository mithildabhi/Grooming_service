import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool acceptingBookings = true;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        elevation: 0,
        title: const Text(
          "Salon Hub",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, ProfileScreen() as Route<Object?>);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            const Text(
              "Hello, Luxe Cuts",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's what's happening today.",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // Profile Completeness
            _profileCompletion(),

            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                _statCard(
                  title: "Today",
                  value: "14",
                  subtitle: "+12% vs last week",
                  icon: Icons.calendar_today,
                ),
                const SizedBox(width: 12),
                _statCard(
                  title: "Revenue",
                  value: "₹1,240",
                  subtitle: "+5% vs yesterday",
                  icon: Icons.currency_rupee,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Accepting Bookings Toggle
            _bookingToggle(),

            const SizedBox(height: 30),

            const Text(
              "Management",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _managementCard(
                  title: "Salon Info",
                  subtitle: "Update name, bio & contacts",
                  icon: Icons.store,
                ),
                _managementCard(
                  title: "Gallery",
                  subtitle: "Manage portfolio images",
                  icon: Icons.photo_library,
                ),
                _managementCard(
                  title: "Timings",
                  subtitle: "Set opening hours",
                  icon: Icons.access_time,
                ),
                _managementCard(
                  title: "Location",
                  subtitle: "Map & address settings",
                  icon: Icons.location_on,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Promo Card
            _promoCard(),
          ],
        ),
      ),

      // ---------------- BOTTOM NAV ----------------
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: const Color(0xFF0F1E1E),
      //   selectedItemColor: const Color(0xFF22E6D3),
      //   unselectedItemColor: Colors.white54,
      //   currentIndex: selectedIndex,
      //   onTap: (i) => setState(() => selectedIndex = i),
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Hub"),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.calendar_month),
      //       label: "Calendar",
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.people), label: "Staff"),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: "Settings",
      //     ),
      //   ],
      // ),
    );
  }

  // ---------------- WIDGETS ----------------

  Widget _profileCompletion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Profile Completeness",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "85%",
                style: TextStyle(
                  color: Color(0xFF22E6D3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.85,
            backgroundColor: Colors.white24,
            color: const Color(0xFF22E6D3),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          const Text(
            "Complete your location details to reach 100%",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF22E6D3)),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF22E6D3), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Accepting Bookings", style: TextStyle(color: Colors.white)),
              Text(
                "Salon is currently visible",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: acceptingBookings,
            activeColor: const Color(0xFF22E6D3),
            onChanged: (v) => setState(() => acceptingBookings = v),
          ),
        ],
      ),
    );
  }

  Widget _managementCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF22E6D3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _promoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PRO FEATURE",
            style: TextStyle(
              color: Color(0xFF22E6D3),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Boost Your Visibility",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Promote your salon to get more bookings this weekend.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22E6D3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Start Campaign"),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF162B2B),
      borderRadius: BorderRadius.circular(18),
    );
  }
}
