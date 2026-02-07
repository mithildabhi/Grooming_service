// lib/services/chatbot_api.dart - USER CHATBOT API SERVICE
// 👤 USER/CUSTOMER CHATBOT - Uses /chatbot/user/* endpoints
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

/// User/Customer Chatbot API - Uses user-specific endpoints
/// NOTE: For ADMIN chatbot, use AdminChatbotApi instead!
class ChatbotApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Send message to USER chatbot - Backend has user context
  static Future<String> sendMessage(String message) async {
    try {
      final headers = await _getHeaders();
      
      print('🤖 [USER] Sending: $message');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/user/'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 [USER] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Response: ${data['response']?.substring(0, 50)}...');
        return data['response'] as String;
      } else if (response.statusCode == 404) {
        return 'Sorry, the chatbot service is currently unavailable. Please try again later.';
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Chatbot error: $e');
      return _getFallbackResponse(message);
    }
  }



  /// Get contextual quick suggestions for USER
  static Future<List<String>> getQuickSuggestions() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/user/suggestions/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['suggestions']);
      }
      
      return _getDefaultSuggestions();
    } catch (e) {
      print('❌ Suggestions error: $e');
      return _getDefaultSuggestions();
    }
  }

  /// Clear USER chat history
  static Future<bool> clearChatHistory() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/chatbot/user/clear/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Clear history error: $e');
      return false;
    }
  }

  /// Fallback responses when backend is unavailable
  static String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('today') && lowerMessage.contains('booking')) {
      return 'I\'m having trouble accessing your booking data right now. '
             'Please check the Bookings tab or try again in a moment.';
    }
    
    if (lowerMessage.contains('revenue') || lowerMessage.contains('earning')) {
      return 'I cannot retrieve your revenue data at the moment. '
             'Please check your Dashboard for the latest figures.';
    }
    
    if (lowerMessage.contains('staff') || lowerMessage.contains('team')) {
      return 'I\'m unable to access staff information right now. '
             'Please visit the Staff tab to view your team.';
    }
    
    if (lowerMessage.contains('service') || lowerMessage.contains('popular')) {
      return 'Service data is temporarily unavailable. '
             'Please check the Services section for details.';
    }
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return '👋 Hello! I\'m experiencing connection issues. '
             'I can help you with:\n\n'
             '• Today\'s bookings\n'
             '• Revenue tracking\n'
             '• Staff management\n'
             '• Service analytics\n\n'
             'Please try your question again.';
    }
    
    return 'I apologize, but I\'m having trouble connecting to your salon data right now. '
           'Please try again in a moment or check the specific section in the app.\n\n'
           'You can ask me about:\n'
           '• Bookings and appointments\n'
           '• Revenue and earnings\n'
           '• Staff performance\n'
           '• Customer insights\n'
           '• Business recommendations';
  }

  static List<String> _getDefaultSuggestions() {
    return [
      'How many bookings today?',
      'Show weekly revenue',
      'Who are my top staff?',
      'Popular services analysis',
      'Customer retention tips',
      'Business recommendations',
    ];
  }
}