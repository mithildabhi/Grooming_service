class SalonModel {
  final String id;
  final String name;
  final String type; // Male | Female | Unisex
  final Map<String, dynamic> hours; // per_day: monday..sunday -> {open, close, closed}
  final String address;
  final String city;      // ✅ NEW
  final String state;     // ✅ NEW
  final String pincode;   // ✅ NEW
  final String phone;
  final String about;
  final String imageUrl;

  // ✅ UI SUPPORT
  final double rating;
  final double distance;
  final List<String> services;

  SalonModel({
    required this.id,
    required this.name,
    required this.type,
    required this.hours,
    required this.address,
    this.city = '',         // ✅ NEW with default
    this.state = '',        // ✅ NEW with default
    this.pincode = '',      // ✅ NEW with default
    required this.phone,
    required this.about,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.services,
  });

  // ✅ ADDED: displayImage getter
  String get displayImage {
    if (imageUrl.isNotEmpty) {
      return imageUrl;
    }
    return 'https://via.placeholder.com/400x300?text=Salon+Image';
  }

  // ✅ ADDED: salonTypeDisplay getter
  String get salonTypeDisplay {
    switch (type.toLowerCase()) {
      case 'male':
        return 'Men\'s Salon';
      case 'female':
        return 'Women\'s Salon';
      case 'unisex':
        return 'Unisex Salon';
      default:
        return 'Salon';
    }
  }

  // ✅ NEW: Get formatted full address with city
  String get fullAddress {
    List<String> parts = [];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }

  // ✅ NEW: Get short location (city + state)
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

  // ✅ FIXED: isOpen method (was returning null)
  bool get isOpen {
    if (hours.isEmpty) {
      return true; // Assume open if no hours set
    }

    final now = DateTime.now();
    final dayName = _getDayName(now.weekday).toLowerCase();
    final todayHours = hours[dayName];

    if (todayHours == null) {
      return true; // Assume open if day not found
    }

    // Check if closed
    if (todayHours['closed'] == true) {
      return false;
    }

    // Parse hours like "09:00" and "20:00"
    try {
      final openTime = todayHours['open'] as String;
      final closeTime = todayHours['close'] as String;

      final openMinutes = _parseTime(openTime);
      final closeMinutes = _parseTime(closeTime);
      final currentMinutes = now.hour * 60 + now.minute;

      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    } catch (e) {
      return true; // Assume open if parsing fails
    }
  }

  // ✅ ADDED: Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  // ✅ ADDED: Helper method to parse time string to minutes
  int _parseTime(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'hours': hours,
        'address': address,
        'city': city,           // ✅ NEW
        'state': state,         // ✅ NEW
        'pincode': pincode,     // ✅ NEW
        'phone': phone,
        'about': about,
        'imageUrl': imageUrl,
      };

  // ✅ ADDED: toJson method (alias for toMap)
  Map<String, dynamic> toJson() => toMap();

  factory SalonModel.fromMap(String id, Map<String, dynamic> m) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    Map<String, dynamic> hours = {};
    if (m['hours'] != null && m['hours'] is Map) {
      hours = Map<String, dynamic>.from(m['hours']);
    } else {
      for (var d in days) {
        hours[d] = {'open': '09:00', 'close': '20:00', 'closed': false};
      }
    }

    return SalonModel(
      id: id,
      name: (m['name'] ?? 'My Salon') as String,
      type: (m['type'] ?? 'Unisex') as String,
      hours: hours,
      address: (m['address'] ?? '') as String,
      city: (m['city'] ?? '') as String,         // ✅ NEW
      state: (m['state'] ?? '') as String,       // ✅ NEW
      pincode: (m['pincode'] ?? '') as String,   // ✅ NEW
      phone: (m['phone'] ?? '') as String,
      about: (m['about'] ?? '') as String,
      imageUrl: (m['imageUrl'] ?? '') as String,
      rating: 4.5,
      distance: 2,
      services: [],
    );
  }

  // ✅ UPDATED: fromJson factory method with city support
  factory SalonModel.fromJson(Map<String, dynamic> json) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    
    Map<String, dynamic> hours = {};
    if (json['hours'] != null && json['hours'] is Map) {
      hours = Map<String, dynamic>.from(json['hours']);
    } else {
      // Create default hours
      for (var d in days) {
        hours[d] = {'open': '09:00', 'close': '20:00', 'closed': false};
      }
    }

    return SalonModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'My Salon',
      type: json['type'] as String? ?? json['salon_type'] as String? ?? 'Unisex',
      hours: hours,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',           // ✅ NEW
      state: json['state'] as String? ?? '',         // ✅ NEW
      pincode: json['pincode'] as String? ?? '',     // ✅ NEW
      phone: json['phone'] as String? ?? '',
      about: json['about'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      distance: (json['distance'] as num?)?.toDouble() ?? 2.0,
      services: [],
    );
  }

  get description => null;
  get servicesList => null;

  static Map<String, dynamic> defaultHours() {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final Map<String, dynamic> res = {};
    for (var d in days) {
      res[d] = {'open': '09:00', 'close': '20:00', 'closed': false};
    }
    return res;
  }
}