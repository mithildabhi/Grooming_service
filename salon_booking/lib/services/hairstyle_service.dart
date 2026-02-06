// lib/services/hairstyle_service.dart
// 🎨 HAIRSTYLE ML SERVICE - Image Upload & Analysis

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';

class HairstyleService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Get authentication headers
  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Upload image and analyze hairstyle
  static Future<HairstyleAnalysisResult> analyzeHairstyle({
    required File imageFile,
    required String gender, // 'male', 'female', or 'unisex'
    Map<String, dynamic>? preferences,
  }) async {
    try {
      print('🎨 HAIRSTYLE: Starting analysis...');
      print('   Image: ${imageFile.path}');
      print('   Gender: $gender');

      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/hairstyle/analyze/');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(headers);

      // Add image file with explicit content type
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeTypeData = mimeType.split('/');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      // Add gender
      request.fields['gender'] = gender;

      // Add preferences if provided
      if (preferences != null && preferences.isNotEmpty) {
        request.fields['preferences'] = jsonEncode(preferences);
      }

      print('📤 HAIRSTYLE: Sending request...');

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 HAIRSTYLE: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ HAIRSTYLE: Analysis successful!');
        print('   Face shape: ${data['face_shape']}');

        return HairstyleAnalysisResult.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Analysis failed');
      }
    } catch (e) {
      print('❌ HAIRSTYLE: Error: $e');
      rethrow;
    }
  }

  /// Get analysis history
  static Future<List<HairstyleHistoryItem>> getAnalysisHistory({
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.get(
        Uri.parse('$baseUrl/hairstyle/history/?limit=$limit'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final historyList = data['history'] as List;

        return historyList
            .map((item) => HairstyleHistoryItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('❌ HAIRSTYLE HISTORY: Error: $e');
      rethrow;
    }
  }

  /// Get detailed analysis by ID
  static Future<HairstyleAnalysisResult> getAnalysisDetail(int analysisId) async {
    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.get(
        Uri.parse('$baseUrl/hairstyle/analysis/$analysisId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HairstyleAnalysisResult.fromJson(data['analysis']);
      } else {
        throw Exception('Failed to load analysis details');
      }
    } catch (e) {
      print('❌ HAIRSTYLE DETAIL: Error: $e');
      rethrow;
    }
  }

  /// Submit feedback on recommendation
  static Future<bool> submitFeedback({
    required int analysisId,
    required String recommendationName,
    required bool liked,
    bool tried = false,
    String? comment,
  }) async {
    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$baseUrl/hairstyle/analysis/$analysisId/feedback/'),
        headers: headers,
        body: jsonEncode({
          'recommendation_name': recommendationName,
          'liked': liked,
          'tried': tried,
          'comment': comment ?? '',
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ HAIRSTYLE FEEDBACK: Error: $e');
      return false;
    }
  }

  /// Delete analysis
  static Future<bool> deleteAnalysis(int analysisId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/hairstyle/analysis/$analysisId/delete/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ HAIRSTYLE DELETE: Error: $e');
      return false;
    }
  }
}

// ==================== MODELS ====================

class HairstyleAnalysisResult {
  final bool success;
  final int? analysisId;
  final String? faceShape;
  final CurrentHairstyle? currentHairstyle;
  final List<HairstyleRecommendation>? recommendations;
  final List<String>? stylingTips;
  final List<String>? recommendedProducts;
  final String? imageUrl;
  final String? error;

  HairstyleAnalysisResult({
    required this.success,
    this.analysisId,
    this.faceShape,
    this.currentHairstyle,
    this.recommendations,
    this.stylingTips,
    this.recommendedProducts,
    this.imageUrl,
    this.error,
  });

  factory HairstyleAnalysisResult.fromJson(Map<String, dynamic> json) {
    return HairstyleAnalysisResult(
      success: json['success'] ?? false,
      analysisId: json['analysis_id'],
      faceShape: json['face_shape'],
      currentHairstyle: json['current_hairstyle'] != null
          ? CurrentHairstyle.fromJson(json['current_hairstyle'])
          : null,
      recommendations: json['recommendations'] != null
          ? (json['recommendations'] as List)
              .map((item) => HairstyleRecommendation.fromJson(item))
              .toList()
          : null,
      stylingTips: json['styling_tips'] != null
          ? List<String>.from(json['styling_tips'])
          : null,
      recommendedProducts: json['recommended_products'] != null
          ? List<String>.from(json['recommended_products'])
          : null,
      imageUrl: json['image_url'],
      error: json['error'],
    );
  }
}

class CurrentHairstyle {
  final String length;
  final String color;
  final String description;

  CurrentHairstyle({
    required this.length,
    required this.color,
    required this.description,
  });

  factory CurrentHairstyle.fromJson(Map<String, dynamic> json) {
    return CurrentHairstyle(
      length: json['length'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class HairstyleRecommendation {
  final String name;
  final String difficulty;
  final String maintenance;
  final String description;

  HairstyleRecommendation({
    required this.name,
    required this.difficulty,
    required this.maintenance,
    required this.description,
  });

  factory HairstyleRecommendation.fromJson(Map<String, dynamic> json) {
    return HairstyleRecommendation(
      name: json['name'] ?? '',
      difficulty: json['difficulty'] ?? '',
      maintenance: json['maintenance'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class HairstyleHistoryItem {
  final int id;
  final String? faceShape;
  final String? currentHairLength;
  final String? currentHairColor;
  final int recommendationsCount;
  final String? imageUrl;
  final String createdAt;
  final String gender;

  HairstyleHistoryItem({
    required this.id,
    this.faceShape,
    this.currentHairLength,
    this.currentHairColor,
    required this.recommendationsCount,
    this.imageUrl,
    required this.createdAt,
    required this.gender,
  });

  factory HairstyleHistoryItem.fromJson(Map<String, dynamic> json) {
    return HairstyleHistoryItem(
      id: json['id'],
      faceShape: json['face_shape'],
      currentHairLength: json['current_hair_length'],
      currentHairColor: json['current_hair_color'],
      recommendationsCount: json['recommendations_count'] ?? 0,
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      gender: json['gender'] ?? 'unisex',
    );
  }
}