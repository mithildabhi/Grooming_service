// lib/controllers/admin_dashboard_controller.dart
import 'package:get/get.dart';
import 'revenue_controller.dart';
import 'booking_controller.dart';
import '../widgets/custom_snackbar.dart';

class AdminDashboardController extends GetxController {
  // Initialize controllers if they don't exist
  late final RevenueController revenueController;
  late final BookingController bookingController;

  AdminDashboardController() {
    // Initialize or get existing controllers
    try {
      revenueController = Get.find<RevenueController>();
    } catch (e) {
      revenueController = Get.put(RevenueController());
    }
    
    try {
      bookingController = Get.find<BookingController>();
    } catch (e) {
      bookingController = Get.put(BookingController());
    }
  }


  // Loading states
  final RxBool isLoading = false.obs;

  // ========================
  // COMPUTED PROPERTIES
  // ========================

  // Today's Stats
  double get todayRevenue => revenueController.todayRevenue;
  int get todayBookings => revenueController.todayBookings;
  int get pendingBookings => bookingController.pendingCount;
  double get completionRate => revenueController.completionRate;

  // Revenue Stats
  double get totalRevenue => revenueController.totalRevenue;
  double get weekRevenue => revenueController.weekRevenue;
  double get monthRevenue => revenueController.monthRevenue;
  double get pendingRevenue => revenueController.pendingRevenue;

  // Booking Stats  
  int get totalBookingsCount => bookingController.totalBookingsCount;
  int get confirmedCount => bookingController.confirmedCount;
  int get completedCount => bookingController.completedCount;
  int get cancelledCount => bookingController.cancelledCount;

  // Recent Bookings
  List<dynamic> get recentBookings => 
      bookingController.bookings.take(5).toList();

  // Chart Data - Weekly Revenue (Last 7 days)
  List<ChartData> get weeklyRevenueChartData {
    final data = revenueController.dailyRevenue;
    if (data.isEmpty) return [];
    
    return data.take(7).map((item) {
      return ChartData(
        label: item['date']?.toString() ?? '',
        value: (item['revenue'] ?? 0).toDouble(),
      );
    }).toList();
  }

  // Chart Data - Service Distribution
  List<ChartData> get serviceRevenueChartData {
    return revenueController.serviceRevenue.take(5).map((item) {
      return ChartData(
        label: item['service__name']?.toString() ?? 'Unknown',
        value: (item['revenue'] ?? 0).toDouble(),
      );
    }).toList();
  }

  // Chart Data - Staff Performance
  List<ChartData> get staffPerformanceChartData {
    return revenueController.staffPerformance.map((item) {
      return ChartData(
        label: item['staff__full_name']?.toString() ?? 'Unknown',
        value: (item['revenue'] ?? 0).toDouble(),
      );
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  // ========================
  // FETCH ALL DATA
  // ========================
  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        revenueController.fetchRevenueOverview(),
        revenueController.fetchDailyRevenue(),
        revenueController.fetchServiceRevenue(),
        revenueController.fetchStaffPerformance(),
        bookingController.fetchBookings(),
      ]);
    } catch (e) {
      // Error fetching dashboard data
      CustomSnackbar.show(title: 'Error', message: 'Failed to load dashboard data', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // REFRESH
  // ========================
  @override
  Future<void> refresh() async {
    await fetchDashboardData();
  }
}

// Chart Data Model
class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});
}
