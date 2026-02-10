// lib/controllers/revenue_controller.dart
// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../services/revenue_api.dart';
import '../widgets/custom_snackbar.dart';

class RevenueController extends GetxController {
  // ========================
  // STATE
  // ========================
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> revenueData = <String, dynamic>{}.obs;
  final RxList<dynamic> dailyRevenue = [].obs;
  final RxList<dynamic> weeklyRevenue = [].obs;
  final RxList<dynamic> monthlyRevenue = [].obs;
  final RxList<dynamic> serviceRevenue = [].obs;
  final RxList<dynamic> staffPerformance = [].obs;
  final RxList<dynamic> categoryRevenue = [].obs;
  final RxList<dynamic> peakHours = [].obs;

  // ========================
  // COMPUTED PROPERTIES
  // ========================
  
  double get totalRevenue => 
      (revenueData['revenue']?['total'] ?? 0).toDouble();
  
  double get todayRevenue => 
      (revenueData['revenue']?['today'] ?? 0).toDouble();
  
  double get weekRevenue => 
      (revenueData['revenue']?['this_week'] ?? 0).toDouble();
  
  double get monthRevenue => 
      (revenueData['revenue']?['this_month'] ?? 0).toDouble();
  
  double get yearRevenue => 
      (revenueData['revenue']?['this_year'] ?? 0).toDouble();
  
  double get pendingRevenue => 
      (revenueData['revenue']?['pending'] ?? 0).toDouble();
  
  int get totalBookings => 
      (revenueData['bookings']?['total'] ?? 0).toInt();
  
  int get todayBookings => 
      (revenueData['bookings']?['today'] ?? 0).toInt();
  
  double get averageBookingValue => 
      (revenueData['metrics']?['average_booking_value'] ?? 0).toDouble();
  
  double get completionRate => 
      (revenueData['metrics']?['completion_rate'] ?? 0).toDouble();

  // Top earning service
  Map<String, dynamic>? get topService {
    if (serviceRevenue.isEmpty) return null;
    return serviceRevenue.first;
  }

  // Top performing staff
  Map<String, dynamic>? get topStaff {
    if (staffPerformance.isEmpty) return null;
    return staffPerformance.first;
  }

  @override
  void onInit() {
    super.onInit();
    fetchRevenueOverview();
  }

  // ========================
  // FETCH REVENUE DATA
  // ========================
  
  Future<void> fetchRevenueOverview() async {
    try {
      isLoading.value = true;
      print('💰 Fetching revenue overview...');
      
      final data = await RevenueApi.getRevenueOverview();
      revenueData.value = data;
      
      print('✅ Revenue loaded: ₹$totalRevenue');
      print('   Today: ₹$todayRevenue');
      print('   This Week: ₹$weekRevenue');
      print('   This Month: ₹$monthRevenue');
    } catch (e) {
      print('❌ Revenue fetch error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load revenue data', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDailyRevenue({String? startDate, String? endDate}) async {
    try {
      final data = await RevenueApi.getDailyRevenue(
        startDate: startDate,
        endDate: endDate,
      );
      dailyRevenue.value = data['daily_breakdown'] ?? [];
      print('✅ Daily revenue loaded: ${dailyRevenue.length} days');
    } catch (e) {
      print('❌ Daily revenue error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load daily revenue', isError: true);
    }
  }

  Future<void> fetchWeeklyRevenue({int weeks = 12}) async {
    try {
      final data = await RevenueApi.getWeeklyRevenue(weeks: weeks);
      weeklyRevenue.value = data['weekly_breakdown'] ?? [];
      print('✅ Weekly revenue loaded: ${weeklyRevenue.length} weeks');
    } catch (e) {
      print('❌ Weekly revenue error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load weekly revenue', isError: true);
    }
  }

  Future<void> fetchMonthlyRevenue({int months = 12}) async {
    try {
      final data = await RevenueApi.getMonthlyRevenue(months: months);
      monthlyRevenue.value = data['monthly_breakdown'] ?? [];
      print('✅ Monthly revenue loaded: ${monthlyRevenue.length} months');
    } catch (e) {
      print('❌ Monthly revenue error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load monthly revenue', isError: true);
    }
  }

  Future<void> fetchServiceRevenue() async {
    try {
      final data = await RevenueApi.getServiceRevenue();
      serviceRevenue.value = data['services'] ?? [];
      print('✅ Service revenue loaded: ${serviceRevenue.length} services');
    } catch (e) {
      print('❌ Service revenue error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load service revenue', isError: true);
    }
  }

  Future<void> fetchStaffPerformance() async {
    try {
      final data = await RevenueApi.getStaffPerformance();
      staffPerformance.value = data['staff_performance'] ?? [];
      print('✅ Staff performance loaded: ${staffPerformance.length} staff');
    } catch (e) {
      print('❌ Staff performance error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load staff performance', isError: true);
    }
  }

  Future<void> fetchCategoryRevenue() async {
    try {
      final data = await RevenueApi.getCategoryRevenue();
      categoryRevenue.value = data['categories'] ?? [];
      print('✅ Category revenue loaded: ${categoryRevenue.length} categories');
    } catch (e) {
      print('❌ Category revenue error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load category revenue', isError: true);
    }
  }

  Future<void> fetchPeakHours() async {
    try {
      final data = await RevenueApi.getPeakHours();
      peakHours.value = data['peak_hours'] ?? [];
      print('✅ Peak hours loaded: ${peakHours.length} hours');
    } catch (e) {
      print('❌ Peak hours error: $e');
      CustomSnackbar.show(title: 'Error', message: 'Failed to load peak hours', isError: true);
    }
  }

  // ========================
  // FETCH ALL DATA
  // ========================
  
  Future<void> fetchAllRevenueData() async {
    await Future.wait([
      fetchRevenueOverview(),
      fetchServiceRevenue(),
      fetchStaffPerformance(),
      fetchCategoryRevenue(),
      fetchMonthlyRevenue(months: 6),
    ]);
  }

  // ========================
  // REFRESH
  // ========================
  
  @override
  Future<void> refresh() async {
    await fetchRevenueOverview();
  }
}