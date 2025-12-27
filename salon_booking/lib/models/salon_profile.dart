class SalonProfile {
  final String id;
  final String? ownerId;
  final String? ownerEmail;
  final String name;
  final String? salonType;
  final String address;
  final String phone;
  final String? about;
  final String? imageUrl;
  final Map<String, dynamic>? hours;
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
    required this.phone,
    this.about,
    this.imageUrl,
    this.hours,
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
      phone: json['phone'] ?? '',
      about: json['about'],
      imageUrl: json['image_url'],
      hours: json['hours'] != null ? Map<String, dynamic>.from(json['hours']) : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
      isOpen: json['is_open'] ?? true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /// Convert to JSON (for sending to Django API)
  /// NOTE: Don't include 'owner' or readonly fields
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'salon_type': salonType ?? 'unisex',
      'address': address,
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
    String? phone,
    String? about,
    String? imageUrl,
    Map<String, dynamic>? hours,
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
      phone: phone ?? this.phone,
      about: about ?? this.about,
      imageUrl: imageUrl ?? this.imageUrl,
      hours: hours ?? this.hours,
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SalonProfile(id: $id, name: $name, phone: $phone, address: $address)';
  }
}