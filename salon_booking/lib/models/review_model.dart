// models/review_model.dart
// ✅ FIXED: Proper type casting and null safety

// ignore_for_file: avoid_print

class ReviewModel {
  final int id;
  final ReviewerInfo user;
  final String salonName;
  final ServiceInfo? service;
  final int rating;
  final String title;
  final String comment;
  
  // Detailed Ratings (Optional)
  final int? serviceQualityRating;
  final int? staffBehaviorRating;
  final int? ambianceRating;
  final int? valueForMoneyRating;
  
  // Status
  final bool isVerified;
  final bool isEdited;
  
  // Owner Reply
  final String? ownerReply;
  final DateTime? ownerRepliedAt;
  
  // Helpfulness
  final int helpfulCount;
  final int notHelpfulCount;
  final int helpfulnessPercentage;
  final String? userVoted; // 'helpful', 'not_helpful', or null
  
  // Media
  final List<String> images;
  
  // Timestamps
  final String timeAgo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.user,
    required this.salonName,
    this.service,
    required this.rating,
    this.title = '',
    required this.comment,
    this.serviceQualityRating,
    this.staffBehaviorRating,
    this.ambianceRating,
    this.valueForMoneyRating,
    this.isVerified = false,
    this.isEdited = false,
    this.ownerReply,
    this.ownerRepliedAt,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.helpfulnessPercentage = 0,
    this.userVoted,
    this.images = const [],
    required this.timeAgo,
    required this.createdAt,
    this.updatedAt,
  });

  // ✅ FIXED: Robust JSON parsing with type safety
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReviewModel(
        id: _parseInt(json['id']),
        user: ReviewerInfo.fromJson(json['user'] as Map<String, dynamic>),
        salonName: json['salon_name']?.toString() ?? '',
        service: json['service'] != null 
            ? ServiceInfo.fromJson(json['service'] as Map<String, dynamic>)
            : null,
        rating: _parseInt(json['rating']),
        title: json['title']?.toString() ?? '',
        comment: json['comment']?.toString() ?? '',
        serviceQualityRating: _parseIntOrNull(json['service_quality_rating']),
        staffBehaviorRating: _parseIntOrNull(json['staff_behavior_rating']),
        ambianceRating: _parseIntOrNull(json['ambiance_rating']),
        valueForMoneyRating: _parseIntOrNull(json['value_for_money_rating']),
        isVerified: json['is_verified'] == true,
        isEdited: json['is_edited'] == true,
        ownerReply: json['owner_reply']?.toString(),
        ownerRepliedAt: json['owner_replied_at'] != null
            ? DateTime.tryParse(json['owner_replied_at'].toString())
            : null,
        helpfulCount: _parseInt(json['helpful_count'], defaultValue: 0),
        notHelpfulCount: _parseInt(json['not_helpful_count'], defaultValue: 0),
        helpfulnessPercentage: _parseInt(json['helpfulness_percentage'], defaultValue: 0),
        userVoted: json['user_voted']?.toString(),
        images: _parseStringList(json['images']),
        timeAgo: json['time_ago']?.toString() ?? 'Recently',
        createdAt: DateTime.parse(json['created_at'].toString()),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      print('❌ Error parsing ReviewModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  // ✅ Helper: Safe integer parsing
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // ✅ Helper: Safe nullable integer parsing
  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // ✅ Helper: Safe string list parsing
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'title': title,
      'comment': comment,
      'service_quality_rating': serviceQualityRating,
      'staff_behavior_rating': staffBehaviorRating,
      'ambiance_rating': ambianceRating,
      'value_for_money_rating': valueForMoneyRating,
      'images': images,
    };
  }

  // Check if review has detailed ratings
  bool get hasDetailedRatings {
    return serviceQualityRating != null ||
        staffBehaviorRating != null ||
        ambianceRating != null ||
        valueForMoneyRating != null;
  }

  // Calculate average of detailed ratings
  double? get averageDetailedRating {
    if (!hasDetailedRatings) return null;
    
    final ratings = [
      serviceQualityRating,
      staffBehaviorRating,
      ambianceRating,
      valueForMoneyRating,
    ].where((r) => r != null).cast<int>().toList();
    
    if (ratings.isEmpty) return null;
    
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}


class ReviewerInfo {
  final int id;
  final String displayName;
  final String initial;
  final int totalReviews;

  ReviewerInfo({
    required this.id,
    required this.displayName,
    required this.initial,
    required this.totalReviews,
  });

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) {
    return ReviewerInfo(
      id: ReviewModel._parseInt(json['id']),
      displayName: json['display_name']?.toString() ?? 'User',
      initial: json['initial']?.toString() ?? '?',
      totalReviews: ReviewModel._parseInt(json['total_reviews'], defaultValue: 0),
    );
  }
}


class ServiceInfo {
  final int id;
  final String name;
  final String category;
  final double price;

  ServiceInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: ReviewModel._parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: _parseDouble(json['price']),
    );
  }

  // ✅ Helper: Safe double parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}


class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final Map<int, RatingDistribution> ratingDistribution;
  final int verifiedReviewsCount;
  
  // Detailed averages
  final double avgServiceQuality;
  final double avgStaffBehavior;
  final double avgAmbiance;
  final double avgValueForMoney;

  ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.verifiedReviewsCount,
    required this.avgServiceQuality,
    required this.avgStaffBehavior,
    required this.avgAmbiance,
    required this.avgValueForMoney,
  });

  // ✅ FIXED: Robust parsing with proper type handling
  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final Map<int, RatingDistribution> distribution = {};
    
    try {
      final distJson = json['rating_distribution'] as Map<String, dynamic>;
      distJson.forEach((key, value) {
        final starRating = int.parse(key);
        if (value is Map<String, dynamic>) {
          distribution[starRating] = RatingDistribution.fromJson(value);
        }
      });
    } catch (e) {
      print('⚠️ Error parsing rating distribution: $e');
    }

    return ReviewStats(
      totalReviews: ReviewModel._parseInt(json['total_reviews'], defaultValue: 0),
      averageRating: _parseDouble(json['average_rating']),
      ratingDistribution: distribution,
      verifiedReviewsCount: ReviewModel._parseInt(json['verified_reviews_count'], defaultValue: 0),
      avgServiceQuality: _parseDouble(json['avg_service_quality']),
      avgStaffBehavior: _parseDouble(json['avg_staff_behavior']),
      avgAmbiance: _parseDouble(json['avg_ambiance']),
      avgValueForMoney: _parseDouble(json['avg_value_for_money']),
    );
  }

  // ✅ Helper: Safe double parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Get percentage for specific rating
  double getPercentage(int rating) {
    return ratingDistribution[rating]?.percentage ?? 0.0;
  }

  // Get count for specific rating
  int getCount(int rating) {
    return ratingDistribution[rating]?.count ?? 0;
  }
}


class RatingDistribution {
  final int count;
  final double percentage;

  RatingDistribution({
    required this.count,
    required this.percentage,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) {
    return RatingDistribution(
      count: ReviewModel._parseInt(json['count'], defaultValue: 0),
      percentage: _parseDouble(json['percentage']),
    );
  }

  // ✅ Helper: Safe double parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}