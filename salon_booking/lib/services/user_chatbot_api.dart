// lib/services/user_chatbot_api.dart
// 🤖 USER CHATBOT API WITH HAIRSTYLE ML INTEGRATION

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class UserChatbotApi {
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

  /// Send message to user chatbot
  static Future<ChatbotResponse> sendMessage(String message) async {
    try {
      final headers = await _getHeaders();

      print('🤖 USER CHAT: Sending: $message');

      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/user/'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 USER CHAT: Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ USER CHAT: Response received');

        return ChatbotResponse(
          response: data['response'] as String,
          intent: data['intent'] as String?,
          actions: data['actions'] as Map<String, dynamic>?,
        );
      } else if (response.statusCode == 404) {
        return ChatbotResponse(
          response: 'Sorry, the chatbot service is currently unavailable. Please try again later.',
          intent: 'error',
        );
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ USER CHAT: Error: $e');
      return ChatbotResponse(
        response: _getFallbackResponse(message),
        intent: 'fallback',
      );
    }
  }

  /// Get contextual quick suggestions
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
      print('❌ USER SUGGESTIONS: Error: $e');
      return _getDefaultSuggestions();
    }
  }

  /// Clear chat history
  static Future<bool> clearChatHistory() async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/chatbot/user/clear/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ CLEAR HISTORY: Error: $e');
      return false;
    }
  }

  /// Fallback responses when backend is unavailable
  static String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('hairstyle') || 
        lowerMessage.contains('hair') ||
        lowerMessage.contains('face shape')) {
      return '💇 **Hairstyle Recommendations**\n\n'
          'I can help you find the perfect hairstyle! Just upload your photo using the camera button below.\n\n'
          '📷 Tap the camera icon to get started!';
    }

    if (lowerMessage.contains('booking') || lowerMessage.contains('appointment')) {
      return '📅 **Your Bookings**\n\n'
          'I\'m having trouble accessing your booking data right now. '
          'Please check the Bookings tab or try again in a moment.';
    }

    if (lowerMessage.contains('salon') || lowerMessage.contains('find')) {
      return '🔍 **Find Salons**\n\n'
          'Browse amazing salons in the Explore tab! '
          'You can filter by location, ratings, and services.';
    }

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return '👋 **Hello!**\n\n'
          'I\'m your SalonCare AI assistant! I can help you with:\n\n'
          '• 💇 Hairstyle recommendations\n'
          '• 🔍 Finding salons\n'
          '• 📅 Managing bookings\n'
          '• 💅 Beauty tips\n\n'
          'What would you like to do today?';
    }

    return '🤖 **I\'m Here to Help!**\n\n'
        'I apologize, but I\'m having trouble connecting right now. '
        'You can ask me about:\n\n'
        '• Hairstyle recommendations (upload your photo!)\n'
        '• Finding salons near you\n'
        '• Booking appointments\n'
        '• Beauty and haircare tips\n\n'
        'What would you like to know?';
  }

  static List<String> _getDefaultSuggestions() {
    return [
      '📷 Get hairstyle recommendations',
      'Find salons near me',
      'Show my bookings',
      'Haircare tips',
      'Popular services',
      'How to book?',
    ];
  }
}

// ==================== MODELS ====================

class ChatbotResponse {
  final String response;
  final String? intent;
  final Map<String, dynamic>? actions;

  ChatbotResponse({
    required this.response,
    this.intent,
    this.actions,
  });

  // Check if response is about hairstyles
  bool get isHairstyleIntent {
    return intent == 'hairstyle_recommendation' ||
        intent == 'hairstyle' ||
        (actions != null && actions!.containsKey('hairstyle'));
  }

  // Check if user needs to upload photo
  bool get needsPhotoUpload {
    return actions?['needs_upload'] == true ||
        (!hasAnalysis && isHairstyleIntent);
  }

  // Check if user has existing analysis
  bool get hasAnalysis {
    return actions?['has_analysis'] == true;
  }

  // Get analysis ID if available
  int? get analysisId {
    return actions?['analysis_id'];
  }

  // Get face shape if available
  String? get faceShape {
    return actions?['face_shape'];
  }
}