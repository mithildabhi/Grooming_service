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
  TabController? _tabController;

  final tabs = ['today', 'upcoming', 'completed'];

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
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "All Bookings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
        bottom: TabBar(
          controller: _tabController!,
          labelColor: const Color(0xFF22E6D3),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF22E6D3),
          tabs: const [
            Tab(text: "Today"),
            Tab(text: "Upcoming"),
            Tab(text: "Completed"),
          ],
        ),
      ),

      // ---------------- BODY ----------------
      body: Obx(() {
        final bookings = ctrl.bookingsList;

        return TabBarView(
          controller: _tabController!,
          children: tabs.map((type) {
            final filtered = _filterBookings(bookings, type);

            if (filtered.isEmpty) {
              return _emptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _bookingCard(filtered[i]),
            );
          }).toList(),
        );
      }),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22E6D3),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // ---------------- FILTER BOOKINGS ----------------
  List<Map<String, dynamic>> _filterBookings(
    List<Map<String, dynamic>> all,
    String type,
  ) {
    final now = DateTime.now();

    if (type == 'today') {
      return all.where((b) {
        final d = b['startAt'];
        return d is DateTime &&
            d.day == now.day &&
            d.month == now.month &&
            d.year == now.year;
      }).toList();
    }

    if (type == 'upcoming') {
      return all.where((b) {
        final d = b['startAt'];
        return d is DateTime && d.isAfter(now);
      }).toList();
    }

    return all.where((b) => b['status'] == 'completed').toList();
  }

  // ---------------- BOOKING CARD ----------------
  Widget _bookingCard(Map<String, dynamic> b) {
    final String id = b['id'] ?? '';
    final String customer = b['customerName'] ?? 'Customer';
    final String service = b['serviceName'] ?? 'Service';
    final String staff = b['staffName'] ?? 'Alex';
    final String status = b['status'] ?? 'created';
    final DateTime? time = b['startAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162B2B),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- HEADER --------
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF22E6D3),
                child: Text(
                  customer[0],
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      service,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 12),

          // -------- TIME & STAFF --------
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                time != null
                    ? TimeOfDay.fromDateTime(time).format(context)
                    : '--',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.person, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(staff, style: const TextStyle(color: Colors.white54)),
            ],
          ),

          // -------- ACTIONS --------
          if (status == 'created') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ctrl.cancelBooking(id, "Declined by admin"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22E6D3),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      final staffId = ctrl.employeesList.isNotEmpty
                          ? ctrl.employeesList.first['id']
                          : 'auto_staff';
                      ctrl.approveBooking(id, staffId);
                    },
                    child: const Text("Accept Request"),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- STATUS BADGE ----------------
  Widget _statusBadge(String status) {
    final colors = {
      'created': Colors.orange,
      'approved': Colors.blue,
      'completed': Colors.green,
      'cancelled': Colors.red,
    };

    final c = colors[status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: c, fontSize: 10),
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.white24),
          SizedBox(height: 10),
          Text("No bookings found", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
