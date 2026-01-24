import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../models/booking_model.dart';

class AdminBookingsScreen extends StatelessWidget {
  AdminBookingsScreen({super.key});

  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  final BookingController controller = Get.put(BookingController());
  final RxInt selectedFilter = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Bookings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchBookings,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        final bookings = _getFilteredBookings();

        return RefreshIndicator(
          onRefresh: controller.fetchBookings,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _statisticsCard(),
              const SizedBox(height: 16),
              _filterTabs(),
              const SizedBox(height: 20),
              if (bookings.isEmpty)
                _emptyState()
              else
                ...bookings.map((b) => _bookingTile(b)),
            ],
          ),
        );
      }),
    );
  }

  // ===========================
  // GET FILTERED BOOKINGS
  // ===========================
  List<BookingModel> _getFilteredBookings() {
    switch (selectedFilter.value) {
      case 1: // Remaining (Confirmed only)
        return controller.remainingBookings;
      case 2: // Completed
        return controller.completedBookings;
      case 3: // Cancelled
        return controller.cancelledBookings;
      case 4: // Service Time Passed (NEW)
        return controller.bookings.where((booking) {
          return booking.status == 'CONFIRMED' && 
                 controller.isBookingPast(booking);
        }).toList();
      default: // All
        return controller.bookings;
    }
  }

  // ===========================
  // FILTER TABS (UPDATED)
  // ===========================
  Widget _filterTabs() {
    return Obx(() {
      // Calculate service time passed count
      final passedCount = controller.bookings.where((booking) {
        return booking.status == 'CONFIRMED' && controller.isBookingPast(booking);
      }).length;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', 0, controller.totalBookingsCount, Icons.apps),
            const SizedBox(width: 8),
            _filterChip('Remaining', 1, controller.remainingBookings.length, Icons.schedule),
            const SizedBox(width: 8),
            _filterChip('Completed', 2, controller.completedCount, Icons.check_circle),
            const SizedBox(width: 8),
            _filterChip('Cancelled', 3, controller.cancelledCount, Icons.cancel),
            const SizedBox(width: 8),
            // ✅ NEW: Service Time Passed Filter
            _filterChip('Time Passed', 4, passedCount, Icons.warning, 
                        color: Colors.orange),
          ],
        ),
      );
    });
  }

  Widget _filterChip(String label, int index, int count, IconData icon, {Color? color}) {
    final isSelected = selectedFilter.value == index;
    final chipColor = color ?? accent;
    
    return GestureDetector(
      onTap: () => selectedFilter.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? chipColor : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.black : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black26 : chipColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // BOOKING TILE
  // ===========================
  Widget _bookingTile(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final dateTime = _formatDateTime(booking.date, booking.time);
    final isPast = controller.isBookingPast(booking);

    return GestureDetector(
      onTap: () => _showDetails(booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: isPast && booking.status == 'CONFIRMED'
              ? Border.all(color: Colors.orange, width: 2)
              : booking.status == 'CANCELLED'
                  ? Border.all(color: Colors.red.withOpacity(0.5), width: 1.5)
                  : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(
                _getStatusIcon(booking.status),
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.serviceName,
                    style: TextStyle(
                      color: booking.status == 'CANCELLED'
                          ? Colors.white54
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: booking.status == 'CANCELLED'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateTime,
                    style: TextStyle(
                      color: booking.status == 'CANCELLED'
                          ? Colors.white38
                          : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customer: ${booking.customerName}',
                    style: TextStyle(
                      color: booking.status == 'CANCELLED'
                          ? Colors.white38
                          : Colors.white60,
                    ),
                  ),
                  Text(
                    'Staff: ${booking.staffName ?? 'Unassigned'}',
                    style: TextStyle(
                      color: booking.status == 'CANCELLED'
                          ? Colors.white38
                          : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${booking.id.toString()}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  // ✅ IMPROVED: Service time passed warning
if (isPast && booking.status == 'CONFIRMED')
  Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.withOpacity(0.5)),
    ),
    child: Row(
      children: const [
        Icon(Icons.warning_amber, color: Colors.orange, size: 16),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Service time passed - Update status',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),


                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusChip(booking.status, statusColor),
                const SizedBox(height: 8),
                _buildActionMenu(booking, isPast),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // ACTION MENU
  // ===========================
  Widget _buildActionMenu(BookingModel booking, bool isPast) {
    if (booking.status == 'COMPLETED' || booking.status == 'CANCELLED') {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white54),
      color: card,
      onSelected: (value) {
      final bookingId = int.tryParse(booking.id.toString());
      if (bookingId == null) return;
        
        if (value == 'COMPLETED') {
          _confirmAction(
            title: 'Mark as Completed?',
            message: 'This will mark the booking as completed and add ₹${booking.price.toStringAsFixed(0)} to revenue.',
            onConfirm: () => controller.updateStatus(bookingId, 'COMPLETED'),
          );
        } else if (value == 'CANCELLED') {
          _confirmAction(
            title: 'Cancel Booking?',
            message: 'This action cannot be undone.',
            onConfirm: () => controller.updateStatus(bookingId, 'CANCELLED'),
            isDestructive: true,
          );
        } else if (value == 'NO_SHOW') {
          _confirmAction(
            title: 'Mark as No Show?',
            message: 'Customer did not show up for the appointment.',
            onConfirm: () => controller.updateStatus(bookingId, 'NO_SHOW'),
            isDestructive: true,
          );
        } else {
          controller.updateStatus(bookingId, value);
        }
      },
      itemBuilder: (_) {
        if (booking.status == 'PENDING') {
          return [
            const PopupMenuItem(
              value: 'CONFIRMED',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Confirm', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'CANCELLED',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Cancel', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ];
        }

        if (booking.status == 'CONFIRMED') {
          return [
            const PopupMenuItem(
              value: 'COMPLETED',
              child: Row(
                children: [
                  Icon(Icons.done_all, color: Colors.purple, size: 20),
                  SizedBox(width: 8),
                  Text('Mark Completed', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'NO_SHOW',
              child: Row(
                children: [
                  Icon(Icons.person_off, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Mark No Show', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'CANCELLED',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Cancel', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ];
        }

        return [];
      },
    );
  }

  // ===========================
  // CONFIRMATION DIALOG
  // ===========================
  void _confirmAction({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: card,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                color: isDestructive ? Colors.red : accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // DETAILS BOTTOM SHEET
  // ===========================
  void _showDetails(BookingModel booking) {
    final isPast = controller.isBookingPast(booking);
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusChip(booking.status, _getStatusColor(booking.status)),
              ],
            ),
            // ✅ Show warning in details if time passed
            if (isPast && booking.status == 'CONFIRMED')
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Service time has passed. Please update the booking status.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24, color: Colors.white24),
            _detail('Customer', booking.customerName),
            _detail('Phone', booking.userPhone),
            _detail('Staff', booking.staffName ?? 'Unassigned'),
            _detail('Date & Time', _formatDateTime(booking.date, booking.time)),
            _detail('Duration', '${booking.durationMinutes} min'),
            _detail('Amount', '₹${booking.price.toStringAsFixed(0)}'),
            _detail('Booking ID', '#${booking.id}'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ===========================
  // STATISTICS CARD (UPDATED)
  // ===========================
  Widget _statisticsCard() {
    return Obx(() {
      // Calculate service time passed count
      final passedCount = controller.bookings.where((booking) {
        return booking.status == 'CONFIRMED' && controller.isBookingPast(booking);
      }).length;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Total', controller.totalBookingsCount, Colors.blue),
                _stat('Confirmed', controller.confirmedCount, Colors.green),
                _stat('Completed', controller.completedCount, Colors.purple),
                _stat('Cancelled', controller.cancelledCount, Colors.red),
              ],
            ),
            // ✅ Add Time Passed count
            if (passedCount > 0) ...[
              const Divider(height: 20, color: Colors.white24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$passedCount booking${passedCount > 1 ? 's' : ''} time passed',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 24, color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _revenueStat('Today', controller.todayRevenue),
                _revenueStat('Total', controller.totalRevenue),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _revenueStat(String label, double value) {
    return Column(
      children: [
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: const TextStyle(
            color: accent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$label Revenue',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  // ===========================
  // HELPERS
  // ===========================
  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    String message = 'No bookings found';
    IconData icon = Icons.event_busy;

    switch (selectedFilter.value) {
      case 1:
        message = 'No remaining bookings';
        icon = Icons.event_available;
        break;
      case 2:
        message = 'No completed bookings';
        icon = Icons.check_circle_outline;
        break;
      case 3:
        message = 'No cancelled bookings';
        icon = Icons.cancel_outlined;
        break;
      case 4:
        message = 'No bookings with passed service time';
        icon = Icons.warning_amber_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.blueAccent;
      case 'COMPLETED':
        return Colors.greenAccent;
      case 'CANCELLED':
        return Colors.redAccent;
      case 'NO_SHOW':
        return Colors.orange;
      default:
        return Colors.orangeAccent;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'COMPLETED':
        return Icons.done_all;
      case 'CANCELLED':
        return Icons.cancel;
      case 'NO_SHOW':
        return Icons.person_off;
      default:
        return Icons.event;
    }
  }

  String _formatDateTime(String date, String time) {
    try {
      final d = DateTime.parse(date);
      final t = time.split(':');
      final dt = DateTime(d.year, d.month, d.day, int.parse(t[0]), int.parse(t[1]));
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
    } catch (_) {
      return '$date $time';
    }
  }
}