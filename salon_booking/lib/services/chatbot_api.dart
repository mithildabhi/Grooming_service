// lib/services/chatbot_api.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class ChatbotApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Allow chatbot without auth for public info
      return {
        'Content-Type': 'application/json',
      };
    }
    
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Send message to chatbot and get response
  static Future<String> sendMessage(String message) async {
    try {
      final headers = await _getHeaders();
      
      print('🤖 Sending to chatbot: $message');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/admin/'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Chatbot response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Bot reply: ${data['response']}');
        return data['response'] as String;
      } else if (response.statusCode == 404) {
        return 'Sorry, the chatbot service is currently unavailable. Please try again later.';
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Chatbot error: $e');
      
      // Return fallback responses for common questions
      return _getFallbackResponse(message);
    }
  }

  /// Get quick suggestions
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
      return _getDefaultSuggestions();
    }
  }

  /// Fallback responses when backend is unavailable
  static String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('hour') || lowerMessage.contains('time') || lowerMessage.contains('open')) {
      return 'Our salon is typically open Monday to Saturday, 9:00 AM - 7:00 PM. Closed on Sundays. For exact hours, please contact us directly.';
    }
    
    if (lowerMessage.contains('service') || lowerMessage.contains('price')) {
      return 'We offer haircuts, styling, coloring, treatments, and more. Please check our Services tab for the complete list and pricing.';
    }
    
    if (lowerMessage.contains('staff') || lowerMessage.contains('stylist') || lowerMessage.contains('available')) {
      return 'You can view our staff and their availability in the Staff tab. Would you like me to show you that?';
    }
    
    if (lowerMessage.contains('location') || lowerMessage.contains('address') || lowerMessage.contains('where')) {
      return 'You can find our location details in the Profile section. We\'re happy to help you find us!';
    }
    
    if (lowerMessage.contains('book') || lowerMessage.contains('appointment')) {
      return 'To book an appointment, please go to the Bookings tab where you can schedule your visit.';
    }
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      return 'Hello! 👋 How can I help you today? You can ask me about our services, staff, hours, or location.';
    }
    
    return 'I apologize, but I\'m having trouble connecting to the server right now. Please try asking about:\n\n• Opening hours\n• Services and pricing\n• Staff availability\n• Location\n• Booking appointments';
  }

  static List<String> _getDefaultSuggestions() {
    return [
      'What are your opening hours?',
      'Show me your services',
      'Who is available today?',
      'Where is your salon located?',
      'How do I book an appointment?',
    ];
  }
}