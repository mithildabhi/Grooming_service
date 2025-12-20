// lib/models/salon_profile.dart
class SalonProfile {
  final String id;
  final String name;
  final String type; // Male|Female|Unisex
  final Map<String, dynamic>
  hours; // per_day schedule: e.g. {'monday': {'open':'09:00','close':'20:00','closed':false}, ...}
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

  factory SalonProfile.fromMap(Map<String, dynamic> m, String id) =>
      SalonProfile(
        id: id,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? 'Unisex') as String,
        hours: Map<String, dynamic>.from(m['hours'] ?? _defaultHours()),
        address: (m['address'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        about: (m['about'] ?? '') as String,
        imageUrl: (m['imageUrl'] ?? '') as String,
      );

  static Map<String, dynamic> _defaultHours() {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final Map<String, dynamic> result = {};
    for (var d in days) {
      result[d] = {'open': '09:00', 'close': '20:00', 'closed': false};
    }
    return result;
  }

  void operator [](String other) {}
}
