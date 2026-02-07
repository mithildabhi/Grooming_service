// lib/services/admin_chatbot_api.dart
// 🔒 ADMIN-SPECIFIC CHATBOT API SERVICE
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../controllers/chatbot_controller.dart';

/// Admin Chatbot API - Uses admin-specific endpoints with full salon analytics
class AdminChatbotApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Admin not authenticated');
    }
    
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Send message to ADMIN chatbot - Has access to all salon data
  static Future<String> sendMessage(String message) async {
    try {
      final headers = await _getHeaders();
      
      print('🤖 [ADMIN] Sending: $message');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/admin/'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['response'] as String;
        print('✅ [ADMIN] Response received');
        return responseText;
      } else if (response.statusCode == 404) {
        return 'The admin chatbot service is currently unavailable. Please ensure the backend is running.';
      } else {
        throw Exception('Admin chatbot error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ADMIN] Chatbot error: $e');
      return _getAdminFallbackResponse(message);
    }
  }

  /// Get comprehensive ADMIN salon analytics
  static Future<SalonAnalytics> getSalonAnalytics() async {
    try {
      final headers = await _getHeaders();
      
      print('📊 [ADMIN] Fetching salon analytics...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/admin/analytics/'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      print('📥 [ADMIN] Analytics status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ADMIN] Analytics loaded successfully');
        return SalonAnalytics.fromJson(data['analytics']);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ADMIN] Analytics error: $e');
      rethrow;
    }
  }

  /// Get ADMIN quick suggestions based on salon state
  static Future<List<String>> getQuickSuggestions() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/admin/suggestions/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['suggestions']);
      }
      
      return _getDefaultAdminSuggestions();
    } catch (e) {
      print('❌ [ADMIN] Suggestions error: $e');
      return _getDefaultAdminSuggestions();
    }
  }

  /// Clear ADMIN chat history
  static Future<bool> clearChatHistory() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/chatbot/admin/clear/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [ADMIN] Clear history error: $e');
      return false;
    }
  }

  /// Admin fallback responses when backend unavailable
  static String _getAdminFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('today') && lowerMessage.contains('booking')) {
      return '📊 I apologize, but I cannot access your booking data right now.\n\n'
             'Please check the Dashboard or Bookings tab for real-time data.\n\n'
             '💡 Tip: The dashboard shows today\'s bookings and revenue.';
    }
    
    if (lowerMessage.contains('revenue') || lowerMessage.contains('earning')) {
      return '💰 Revenue data is temporarily unavailable.\n\n'
             'Please check:\n'
             '• Dashboard for quick stats\n'
             '• Revenue screen for detailed breakdown\n\n'
             '🔄 Try refreshing or check your internet connection.';
    }
    
    if (lowerMessage.contains('staff') || lowerMessage.contains('team')) {
      return '👥 Staff information is currently inaccessible.\n\n'
             'Visit the Staff tab to:\n'
             '• View team members\n'
             '• Check performance\n'
             '• Manage schedules';
    }
    
    return '🤖 SalonCare Admin AI is temporarily unavailable.\n\n'
           'You can still access:\n'
           '📊 Dashboard - Real-time overview\n'
           '📅 Bookings - Manage appointments\n'
           '💰 Revenue - Financial insights\n'
           '👥 Staff - Team management\n\n'
           'Please try again in a moment!';
  }

  static List<String> _getDefaultAdminSuggestions() {
    return [
      'Show today\'s bookings and revenue',
      'Weekly performance report',
      'Who are my top staff members?',
      'Most profitable services',
      'Customer retention analysis',
      'Business growth recommendations',
    ];
  }
}
