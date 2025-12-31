// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../services/chatbot_api.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Welcome message for salon admin
    messages.add(ChatMessage(
      text: '👋 Hello! I\'m SalonCare AI, your intelligent salon management assistant.\n\nI can help you with:\n\n📊 Business analytics & insights\n💰 Revenue tracking\n📅 Booking management\n👥 Staff scheduling\n✂️ Service performance\n📦 Inventory alerts\n💡 Smart recommendations\n\nWhat would you like to know about your salon?',
      isUser: false,
    ));
  }
  
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    messages.add(ChatMessage(text: text, isUser: true));
    
    try {
      isLoading.value = true;
      
      // Get AI response from backend
      final response = await ChatbotApi.sendMessage(text);
      
      // Add bot response
      messages.add(ChatMessage(text: response, isUser: false));
      
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
    onInit(); // Add welcome message again
  }
  
  // Quick action methods
  void askTodayBookings() {
    sendMessage('How many bookings do I have today?');
  }
  
  void askWeeklyRevenue() {
    sendMessage('Show me this week\'s revenue');
  }
  
  void askStaffAvailability() {
    sendMessage('Who is working today?');
  }
  
  void askPopularServices() {
    sendMessage('What are my most popular services?');
  }
  
  void askRecommendations() {
    sendMessage('Give me business recommendations');
  }
}