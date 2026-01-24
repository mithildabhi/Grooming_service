// lib/services/chatbot_api.dart - ENHANCED VERSION
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../controllers/chatbot_controller.dart';

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

  /// Send message to chatbot - Backend has full salon context
  static Future<String> sendMessage(String message) async {
    try {
      final headers = await _getHeaders();
      
      print('🤖 Sending: $message');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');

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

  /// Get comprehensive salon analytics
  static Future<SalonAnalytics> getSalonAnalytics() async {
    try {
      final headers = await _getHeaders();
      
      print('📊 Fetching salon analytics...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/analytics/'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Analytics loaded');
        return SalonAnalytics.fromJson(data['analytics']);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Analytics error: $e');
      rethrow;
    }
  }

  /// Get contextual quick suggestions
  static Future<List<String>> getQuickSuggestions() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/suggestions/'),
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

  /// Clear chat history
  static Future<bool> clearChatHistory() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/chatbot/clear/'),
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