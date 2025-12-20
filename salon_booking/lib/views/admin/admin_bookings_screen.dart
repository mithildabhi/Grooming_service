import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminBookingsScreen extends StatefulWidget {
  final String salonId;
  const AdminBookingsScreen({super.key, required this.salonId});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final AdminController ctrl;
  late final TabController _tabController;

  final tabs = ['new', 'approved', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<AdminController>();

    if (widget.salonId.isNotEmpty) {
      ctrl.setActiveSalon(widget.salonId);
    }

    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.salonId.isEmpty) {
      return const Scaffold(body: Center(child: Text("Salon not selected")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF9F5F2),
        title: const Text(
          "Manage Bookings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.pinkAccent,
          tabs: const [
            Tab(text: "New"),
            Tab(text: "Ongoing"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      body: Obx(() {
        final all = ctrl.bookingsList;

        return TabBarView(
          controller: _tabController,
          children: tabs.map((status) {
            final list = status == 'new'
                ? all
                      .where((b) => (b['status'] ?? 'created') == 'created')
                      .toList()
                : all.where((b) => (b['status'] ?? '') == status).toList();

            if (list.isEmpty) {
              return _emptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _bookingCard(list[i]),
            );
          }).toList(),
        );
      }),
    );
  }

  // ---------------- BOOKING CARD ----------------
  Widget _bookingCard(Map<String, dynamic> b) {
    final String id = b['id'] ?? '';
    final String customer = b['customerName'] ?? 'Customer';
    final String services = b['services'] is List
        ? (b['services'] as List).join(', ')
        : b['serviceName'] ?? 'Service';
    final String price = (b['price'] ?? 0).toString();
    final String status = (b['status'] ?? 'created').toString();

    final DateTime? time = b['startAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // name + time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customer,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (time != null)
                Text(
                  TimeOfDay.fromDateTime(time).format(context),
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),

          const SizedBox(height: 10),
          Text(services),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹$price",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _statusChip(status),
            ],
          ),

          if (status == 'created') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ctrl.cancelBooking(id, "Rejected by admin"),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                    ),
                    onPressed: () {
                      final staffId = ctrl.employeesList.isNotEmpty
                          ? ctrl.employeesList.first['id']
                          : 'auto_staff';
                      ctrl.approveBooking(id, staffId);
                    },
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add),
              label: const Text("Assign Staff"),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- STATUS CHIP ----------------
  Widget _statusChip(String s) {
    final map = {
      'created': Colors.orange,
      'approved': Colors.blue,
      'completed': Colors.green,
      'cancelled': Colors.red,
    };

    final c = map[s] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(s.toUpperCase(), style: TextStyle(fontSize: 10, color: c)),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No More Bookings",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text("Check back later"),
        ],
      ),
    );
  }
}
