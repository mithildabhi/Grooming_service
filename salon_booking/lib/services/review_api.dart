// lib/services/review_api.dart
// 🌟 COMPLETE REVIEW API SERVICE - FIXED ALL ISSUES

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../models/review_model.dart';

class ReviewApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final token = await user.getIdToken();
    if (token == null) throw Exception('Failed to get authentication token');

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<Map<String, String>> _getPublicHeaders() async {
    return {'Content-Type': 'application/json'};
  }

  /// ✅ FIXED: Get salon reviews with proper error handling
  static Future<Map<String, dynamic>> getSalonReviews({
    required int salonId,
    int? rating,
    int? serviceId,
    bool verifiedOnly = false,
    String sort = 'recent', // recent, helpful, rating_high, rating_low
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final headers = await _getPublicHeaders();

      // Build query parameters
      List<String> params = [];
      if (rating != null) params.add('rating=$rating');
      if (serviceId != null) params.add('service_id=$serviceId');
      if (verifiedOnly) params.add('verified_only=true');
      params.add('sort=$sort');
      params.add('page=$page');
      params.add('page_size=$pageSize');

      final queryString = params.join('&');
      final url = '$baseUrl/reviews/salon/$salonId/?$queryString';

      print('📖 Fetching salon reviews: $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📊 Reviews response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ FIXED: Parse reviews with proper type handling
        final List<ReviewModel> reviews = [];
        if (data['results'] != null) {
          for (var reviewJson in data['results']) {
            try {
              reviews.add(ReviewModel.fromJson(reviewJson));
            } catch (e) {
              print('⚠️ Error parsing review: $e');
              // Continue with other reviews
            }
          }
        }

        return {
          'reviews': reviews,
          'count': data['count'] ?? 0,
          'next': data['next'],
          'previous': data['previous'],
        };
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting salon reviews: $e');
      rethrow;
    }
  }

  /// ✅ FIXED: Get salon review stats with proper type casting
  static Future<ReviewStats> getSalonReviewStats(int salonId) async {
    try {
      final headers = await _getPublicHeaders();

      final url = '$baseUrl/reviews/salon/$salonId/stats/';

      print('📊 Fetching review stats: $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReviewStats.fromJson(data);
      } else {
        throw Exception('Failed to load review stats');
      }
    } catch (e) {
      print('❌ Error getting review stats: $e');
      rethrow;
    }
  }

  /// Get service reviews
  static Future<Map<String, dynamic>> getServiceReviews({
    required int serviceId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final headers = await _getPublicHeaders();

      final url =
          '$baseUrl/reviews/service/$serviceId/?page=$page&page_size=$pageSize';

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<ReviewModel> reviews = [];
        if (data['results'] != null) {
          for (var reviewJson in data['results']) {
            try {
              reviews.add(ReviewModel.fromJson(reviewJson));
            } catch (e) {
              print('⚠️ Error parsing service review: $e');
            }
          }
        }

        return {
          'reviews': reviews,
          'count': data['count'] ?? 0,
          'next': data['next'],
          'previous': data['previous'],
        };
      } else {
        throw Exception('Failed to load service reviews');
      }
    } catch (e) {
      print('❌ Error getting service reviews: $e');
      rethrow;
    }
  }

  /// ✅ NEW: Get MY reviews (user's own reviews)
  static Future<List<ReviewModel>> getMyReviews({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final headers = await _getHeaders();

      final url = '$baseUrl/reviews/my-reviews/?page=$page&page_size=$pageSize';

      print('📖 Fetching my reviews: $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<ReviewModel> reviews = [];
        if (data['results'] != null) {
          for (var reviewJson in data['results']) {
            try {
              reviews.add(ReviewModel.fromJson(reviewJson));
            } catch (e) {
              print('⚠️ Error parsing my review: $e');
            }
          }
        }

        return reviews;
      } else if (response.statusCode == 401) {
        throw Exception('Please login to view your reviews');
      } else {
        throw Exception('Failed to load your reviews');
      }
    } catch (e) {
      print('❌ Error getting my reviews: $e');
      rethrow;
    }
  }

  /// ✅ PRODUCTION-READY: Create review with proper validation & error handling
  static Future<ReviewModel> createReview({
    required int rating,
    required String comment,
    String title = '',
    int? bookingId,
    int? serviceId,
    int? salonId,
    int? serviceQualityRating,
    int? staffBehaviorRating,
    int? ambianceRating,
    int? valueForMoneyRating,
  }) async {
    try {
      final headers = await _getHeaders();

      // ✅ Must have at least one: booking_id, service_id, or salon_id
      if (bookingId == null && serviceId == null && salonId == null) {
        throw Exception('Must specify booking, service, or salon');
      }

      // ✅ Validate rating
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      // ✅ Validate comment
      final trimmedComment = comment.trim();
      if (trimmedComment.isEmpty) {
        throw Exception('Please add a comment for your review');
      }

      // ✅ Build body — only include non-null, non-empty values
      final body = <String, dynamic>{
        'rating': rating,
        'comment': trimmedComment,
      };

      // Only send title if non-empty
      final trimmedTitle = title.trim();
      if (trimmedTitle.isNotEmpty) {
        body['title'] = trimmedTitle;
      }

      if (bookingId != null) body['booking_id'] = bookingId;
      if (serviceId != null) body['service_id'] = serviceId;
      if (salonId != null) body['salon_id'] = salonId;
      if (serviceQualityRating != null)
        body['service_quality_rating'] = serviceQualityRating;
      if (staffBehaviorRating != null)
        body['staff_behavior_rating'] = staffBehaviorRating;
      if (ambianceRating != null) body['ambiance_rating'] = ambianceRating;
      if (valueForMoneyRating != null)
        body['value_for_money_rating'] = valueForMoneyRating;

      print('✍️ Creating review: $body');

      final response = await http
          .post(
            Uri.parse('$baseUrl/reviews/create/'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('📝 Create review response: ${response.statusCode}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ReviewModel.fromJson(data);
      } else if (response.statusCode == 409) {
        // Duplicate review
        final error = jsonDecode(response.body);
        throw Exception(
          error['error'] ?? 'You have already reviewed this booking',
        );
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Invalid review data');
      } else if (response.statusCode == 401) {
        throw Exception('Please login to submit a review');
      } else {
        // Log unexpected errors for debugging
        print('❌ Unexpected review response: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        throw Exception('Failed to create review. Please try again.');
      }
    } catch (e) {
      print('❌ Error creating review: $e');
      rethrow;
    }
  }

  /// Update review
  static Future<ReviewModel> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
    String title = '',
    int? serviceQualityRating,
    int? staffBehaviorRating,
    int? ambianceRating,
    int? valueForMoneyRating,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = {
        'rating': rating,
        'comment': comment,
        'title': title,
        if (serviceQualityRating != null)
          'service_quality_rating': serviceQualityRating,
        if (staffBehaviorRating != null)
          'staff_behavior_rating': staffBehaviorRating,
        if (ambianceRating != null) 'ambiance_rating': ambianceRating,
        if (valueForMoneyRating != null)
          'value_for_money_rating': valueForMoneyRating,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/reviews/$reviewId/update/'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReviewModel.fromJson(data);
      } else {
        throw Exception('Failed to update review');
      }
    } catch (e) {
      print('❌ Error updating review: $e');
      rethrow;
    }
  }

  /// Delete review
  static Future<void> deleteReview(int reviewId) async {
    try {
      final headers = await _getHeaders();

      final response = await http
          .delete(
            Uri.parse('$baseUrl/reviews/$reviewId/delete/'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete review');
      }
    } catch (e) {
      print('❌ Error deleting review: $e');
      rethrow;
    }
  }

  /// Mark review as helpful/not helpful
  static Future<Map<String, int>> markReviewHelpful({
    required int reviewId,
    required bool isHelpful,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = {'is_helpful': isHelpful};

      final response = await http
          .post(
            Uri.parse('$baseUrl/reviews/$reviewId/helpful/'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'helpful_count': data['helpful_count'] as int,
          'not_helpful_count': data['not_helpful_count'] as int,
        };
      } else {
        throw Exception('Failed to mark review');
      }
    } catch (e) {
      print('❌ Error marking review helpful: $e');
      rethrow;
    }
  }

  /// Report review
  static Future<void> reportReview({
    required int reviewId,
    required String reason,
    String description = '',
  }) async {
    try {
      final headers = await _getHeaders();

      final body = {'reason': reason, 'description': description};

      final response = await http
          .post(
            Uri.parse('$baseUrl/reviews/$reviewId/report/'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to report review');
      }
    } catch (e) {
      print('❌ Error reporting review: $e');
      rethrow;
    }
  }
}
