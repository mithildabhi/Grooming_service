// lib/controllers/chatbot_controller.dart - ENHANCED VERSION
// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../services/chatbot_api.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.intent,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SalonAnalytics {
  final String salonName;
  final int todayBookings;
  final double todayRevenue;
  final int weekBookings;
  final double weekRevenue;
  final int monthBookings;
  final double monthRevenue;
  final double revenueGrowth;
  final int totalStaff;
  final List<String> staffNames;
  final List<Map<String, dynamic>> popularServices;
  final List<Map<String, dynamic>> topStaff;
  final int uniqueCustomers;
  final double repeatCustomerRate;
  final double cancellationRate;
  
  SalonAnalytics({
    required this.salonName,
    required this.todayBookings,
    required this.todayRevenue,
    required this.weekBookings,
    required this.weekRevenue,
    required this.monthBookings,
    required this.monthRevenue,
    required this.revenueGrowth,
    required this.totalStaff,
    required this.staffNames,
    required this.popularServices,
    required this.topStaff,
    required this.uniqueCustomers,
    required this.repeatCustomerRate,
    required this.cancellationRate,
  });
  
  factory SalonAnalytics.fromJson(Map<String, dynamic> json) {
    return SalonAnalytics(
      salonName: json['salon_name'] ?? 'Your Salon',
      todayBookings: json['today_bookings_count'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      weekBookings: json['week_bookings_count'] ?? 0,
      weekRevenue: (json['week_revenue'] ?? 0).toDouble(),
      monthBookings: json['month_bookings_count'] ?? 0,
      monthRevenue: (json['month_revenue'] ?? 0).toDouble(),
      revenueGrowth: (json['revenue_growth_percentage'] ?? 0).toDouble(),
      totalStaff: json['total_staff'] ?? 0,
      staffNames: List<String>.from(json['staff_names'] ?? []),
      popularServices: List<Map<String, dynamic>>.from(
        (json['popular_services'] ?? []).map((s) => Map<String, dynamic>.from(s))
      ),
      topStaff: List<Map<String, dynamic>>.from(
        (json['top_staff'] ?? []).map((s) => Map<String, dynamic>.from(s))
      ),
      uniqueCustomers: json['monthly_unique_customers'] ?? 0,
      repeatCustomerRate: (json['repeat_customer_rate'] ?? 0).toDouble(),
      cancellationRate: (json['cancellation_rate'] ?? 0).toDouble(),
    );
  }
}

class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<SalonAnalytics?> analytics = Rx<SalonAnalytics?>(null);
  final RxBool analyticsLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    // Load analytics in background
    loadAnalytics();
    
    // Show welcome message
    messages.add(ChatMessage(
      text: '👋 Hello! I\'m SalonCare AI, your intelligent business assistant.\n\n'
            'I have access to your complete salon data and can help you with:\n\n'
            '📊 Real-time performance analytics\n'
            '💰 Revenue tracking & forecasts\n'
            '📅 Booking insights & patterns\n'
            '👥 Staff performance analysis\n'
            '✂️ Service popularity trends\n'
            '👤 Customer behavior insights\n'
            '💡 Data-driven recommendations\n\n'
            'Loading your salon data... What would you like to know?',
      isUser: false,
    ));
  }
  
  Future<void> loadAnalytics() async {
    try {
      analyticsLoading.value = true;
      final data = await ChatbotApi.getSalonAnalytics();
      analytics.value = data;
      print('✅ Analytics loaded: ${data.salonName}');
    } catch (e) {
      print('❌ Analytics error: $e');
    } finally {
      analyticsLoading.value = false;
    }
  }
  
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    messages.add(ChatMessage(text: text, isUser: true));
    
    try {
      isLoading.value = true;
      
      // Get AI response from backend (with all salon data)
      final response = await ChatbotApi.sendMessage(text);
      
      // Add bot response
      messages.add(ChatMessage(text: response, isUser: false));
      
      // Reload analytics after certain actions
      if (text.toLowerCase().contains('add staff') || 
          text.toLowerCase().contains('analytics')) {
        loadAnalytics();
      }
      
    } catch (e) {
      print('❌ Error: $e');
      messages.add(ChatMessage(
        text: 'Sorry, I encountered an error. Please try again or check your connection.',
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }
  
  void clearChat() {
    messages.clear();
    onInit(); // Reload welcome message
    ChatbotApi.clearChatHistory();
  }
  
  // === QUICK ACTION METHODS ===
  
  void askTodayBookings() {
    if (analytics.value != null) {
      sendMessage('How many bookings do I have today and what\'s the revenue?');
    } else {
      sendMessage('Show me today\'s performance');
    }
  }
  
  void askWeeklyRevenue() {
    sendMessage('Show me detailed weekly revenue and booking analysis');
  }
  
  void askMonthlyReport() {
    sendMessage('Give me a comprehensive monthly business report');
  }
  
  void askStaffPerformance() {
    sendMessage('Who are my top performing staff members this month?');
  }
  
  void askPopularServices() {
    sendMessage('What are my most popular and profitable services?');
  }
  
  void askCustomerInsights() {
    sendMessage('Tell me about my customer retention and behavior patterns');
  }
  
  void askRecommendations() {
    sendMessage('Analyze my business data and give me actionable recommendations');
  }
  
  void askPeakHours() {
    sendMessage('What are my peak hours and busiest days?');
  }
  
  void askRevenueGrowth() {
    sendMessage('How is my revenue growth compared to last month?');
  }
  
  void askStaffAvailability() {
    sendMessage('Who is on my team and how many staff members do I have?');
  }
  
  // === ANALYTICS GETTERS ===
  
  String get todayBookingsText => 
    analytics.value != null 
      ? '${analytics.value!.todayBookings} bookings'
      : 'Loading...';
      
  String get todayRevenueText => 
    analytics.value != null 
      ? '₹${analytics.value!.todayRevenue.toStringAsFixed(0)}'
      : '₹0';
      
  String get weekRevenueText => 
    analytics.value != null 
      ? '₹${analytics.value!.weekRevenue.toStringAsFixed(0)}'
      : '₹0';
      
  String get monthRevenueText => 
    analytics.value != null 
      ? '₹${analytics.value!.monthRevenue.toStringAsFixed(0)}'
      : '₹0';
      
  String get staffCountText => 
    analytics.value != null 
      ? '${analytics.value!.totalStaff} members'
      : '0 members';
}