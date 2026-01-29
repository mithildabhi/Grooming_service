// lib/models/salon_profile.dart
// ✅ UPDATED: Complete location fields (city, state, pincode)

class SalonProfile {
  final String id;
  final String? ownerId;
  final String? ownerEmail;
  final String name;
  final String? salonType;
  final String address;
  
  // ✅ NEW: Location fields
  final String city;
  final String state;
  final String pincode;
  
  final String phone;
  final String? about;
  final String? imageUrl;
  final Map<String, dynamic>? hours;
  
  // ✅ NEW: Coordinates (optional)
  final double? latitude;
  final double? longitude;
  
  final double rating;
  final bool isOpen;
  final String? createdAt;
  final String? updatedAt;

  SalonProfile({
    required this.id,
    this.ownerId,
    this.ownerEmail,
    required this.name,
    this.salonType,
    required this.address,
    this.city = '',           // ✅ NEW
    this.state = '',          // ✅ NEW
    this.pincode = '',        // ✅ NEW
    required this.phone,
    this.about,
    this.imageUrl,
    this.hours,
    this.latitude,            // ✅ NEW
    this.longitude,           // ✅ NEW
    this.rating = 0.0,
    this.isOpen = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (from Django API)
  factory SalonProfile.fromJson(Map<String, dynamic> json) {
    return SalonProfile(
      id: json['id'].toString(),
      ownerId: json['owner_id']?.toString(),
      ownerEmail: json['owner_email'],
      name: json['name'] ?? '',
      salonType: json['salon_type'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',               // ✅ NEW
      state: json['state'] ?? '',             // ✅ NEW
      pincode: json['pincode'] ?? '',         // ✅ NEW
      phone: json['phone'] ?? '',
      about: json['about'],
      imageUrl: json['image_url'],
      hours: json['hours'] != null ? Map<String, dynamic>.from(json['hours']) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,   // ✅ NEW
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null, // ✅ NEW
      rating: (json['rating'] ?? 0.0).toDouble(),
      isOpen: json['is_open'] ?? true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /// Convert to JSON (for sending to Django API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'salon_type': salonType ?? 'unisex',
      'address': address,
      'city': city,                   // ✅ NEW
      'state': state,                 // ✅ NEW
      'pincode': pincode,             // ✅ NEW
      'phone': phone,
      'about': about ?? '',
      'image_url': imageUrl ?? '',
      'hours': hours ?? {
        'Mon': '09:00-19:00',
        'Tue': '09:00-19:00',
        'Wed': '09:00-19:00',
        'Thu': '09:00-19:00',
        'Fri': '09:00-19:00',
        'Sat': '09:00-19:00',
        'Sun': 'Closed',
      },
      // ✅ NEW: Include coordinates if available
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  /// Create a copy with updated fields
  SalonProfile copyWith({
    String? id,
    String? ownerId,
    String? ownerEmail,
    String? name,
    String? salonType,
    String? address,
    String? city,             // ✅ NEW
    String? state,            // ✅ NEW
    String? pincode,          // ✅ NEW
    String? phone,
    String? about,
    String? imageUrl,
    Map<String, dynamic>? hours,
    double? latitude,         // ✅ NEW
    double? longitude,        // ✅ NEW
    double? rating,
    bool? isOpen,
    String? createdAt,
    String? updatedAt,
  }) {
    return SalonProfile(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      name: name ?? this.name,
      salonType: salonType ?? this.salonType,
      address: address ?? this.address,
      city: city ?? this.city,                   // ✅ NEW
      state: state ?? this.state,                // ✅ NEW
      pincode: pincode ?? this.pincode,          // ✅ NEW
      phone: phone ?? this.phone,
      about: about ?? this.about,
      imageUrl: imageUrl ?? this.imageUrl,
      hours: hours ?? this.hours,
      latitude: latitude ?? this.latitude,       // ✅ NEW
      longitude: longitude ?? this.longitude,    // ✅ NEW
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full formatted address
  String get fullAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }

  /// Get short location (city + state)
  String get shortLocation {
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    } else if (city.isNotEmpty) {
      return city;
    } else if (state.isNotEmpty) {
      return state;
    }
    return 'Location not set';
  }

  /// Check if location is complete
  bool get hasCompleteLocation {
    return address.isNotEmpty && city.isNotEmpty;
  }

  /// Check if has coordinates
  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  @override
  String toString() {
    return 'SalonProfile(id: $id, name: $name, city: $city, phone: $phone)';
  }
}