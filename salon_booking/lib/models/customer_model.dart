class CustomerModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String pincode;
  final String gender;
  final String? dateOfBirth;
  final String? profilePicture;
  final bool isVerified;
  final int totalBookings;
  final int completedBookings;
  final int upcomingBookings;
  final int cancelledBookings;
  final double totalSpent;
  final double averageBookingValue;
  final String loyaltyTier;

  CustomerModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address = '',
    this.city = '',
    this.pincode = '',
    this.gender = 'NOT_SPECIFIED',
    this.dateOfBirth,
    this.profilePicture,
    this.isVerified = false,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.upcomingBookings = 0,
    this.cancelledBookings = 0,
    this.totalSpent = 0.0,
    this.averageBookingValue = 0.0,
    this.loyaltyTier = 'NEW',
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    // ✅ Debug print to see what backend returns
    print('🔍 CustomerModel.fromJson received: $json');
    
    return CustomerModel(
      // ✅ Handle both 'user' (string ID) and user object
      userId: json['user']?.toString() ?? '',
      
      // ✅ IMPORTANT: Check multiple possible field names
      fullName: json['full_name'] ?? json['name'] ?? json['fullName'] ?? '',
      
      email: json['email'] ?? '',
      
      // ✅ Check multiple possible field names for phone
      phone: json['phone'] ?? json['phone_number'] ?? json['phoneNumber'] ?? '',
      
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      gender: json['gender'] ?? 'NOT_SPECIFIED',
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'],
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      
      // ✅ Statistics from backend
      totalBookings: json['total_bookings'] ?? json['totalBookings'] ?? 0,
      completedBookings: json['completed_bookings'] ?? json['completedBookings'] ?? 0,
      upcomingBookings: json['upcoming_bookings'] ?? json['upcomingBookings'] ?? 0,
      cancelledBookings: json['cancelled_bookings'] ?? json['cancelledBookings'] ?? 0,
      totalSpent: _parseDouble(json['total_spent'] ?? json['totalSpent']),
      averageBookingValue: _parseDouble(json['average_booking_value'] ?? json['averageBookingValue']),
      loyaltyTier: json['loyalty_tier'] ?? json['loyaltyTier'] ?? 'NEW',
    );
  }

  /// Helper to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'pincode': pincode,
      'gender': gender,
    };

    // Only include date_of_birth if it's not null
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      json['date_of_birth'] = dateOfBirth;
    }

    return json;
  }

  CustomerModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? pincode,
    String? gender,
    String? dateOfBirth,
    String? profilePicture,
    bool? isVerified,
    int? totalBookings,
    int? completedBookings,
    int? upcomingBookings,
    int? cancelledBookings,
    double? totalSpent,
    double? averageBookingValue,
    String? loyaltyTier,
  }) {
    return CustomerModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePicture: profilePicture ?? this.profilePicture,
      isVerified: isVerified ?? this.isVerified,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      totalSpent: totalSpent ?? this.totalSpent,
      averageBookingValue: averageBookingValue ?? this.averageBookingValue,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
    );
  }

  @override
  String toString() {
    return 'CustomerModel(userId: $userId, fullName: $fullName, email: $email, phone: $phone)';
  }
}