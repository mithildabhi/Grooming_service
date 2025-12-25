// lib/models/salon_profile.dart
class SalonProfile {
  final String id;
  final String name;
  final String type; // Male|Female|Unisex
  final Map<String, dynamic> hours;
  final String address;
  final String phone;
  final String about;
  final String imageUrl;

  SalonProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.hours,
    required this.address,
    required this.phone,
    required this.about,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'hours': hours,
        'address': address,
        'phone': phone,
        'about': about,
        'imageUrl': imageUrl,
      };

  /// Create from Django API response
  factory SalonProfile.fromMap(Map<String, dynamic> m, String id) {
    return SalonProfile(
      id: id,
      name: m['name']?.toString() ?? '',
      type: _formatType(m['salon_type']?.toString() ?? 'unisex'),
      hours: _parseHours(m['hours']),
      address: m['address']?.toString() ?? '',
      phone: m['phone']?.toString() ?? '',
      about: m['about']?.toString() ?? '',
      imageUrl: m['image_url']?.toString() ?? '',
    );
  }

  /// Format type from Django (male/female/unisex) to Flutter (Male/Female/Unisex)
  static String _formatType(String type) {
    switch (type.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'unisex':
        return 'Unisex';
      default:
        return 'Unisex';
    }
  }

  /// Parse hours from Django format
  static Map<String, dynamic> _parseHours(dynamic hours) {
    if (hours is Map) {
      return Map<String, dynamic>.from(hours);
    }
    return _defaultHours();
  }

  static Map<String, dynamic> _defaultHours() {
    return {
      'Mon': '09:00-19:00',
      'Tue': '09:00-19:00',
      'Wed': '09:00-19:00',
      'Thu': '09:00-19:00',
      'Fri': '09:00-19:00',
      'Sat': '09:00-19:00',
      'Sun': 'Closed',
    };
  }
}