class SalonModel {
  final String id;
  final String name;
  final String type; // Male | Female | Unisex
  final Map<String, dynamic> hours; // per_day: monday..sunday -> {open, close, closed}
  final String address;
  final String phone;
  final String about;
  final String imageUrl;

  SalonModel({
    required this.id,
    required this.name,
    required this.type,
    required this.hours,
    required this.address,
    required this.phone,
    required this.about,
    required this.imageUrl,
  });

  // ✅ ADDED: displayImage getter
  String get displayImage {
    if (imageUrl.isNotEmpty) {
      return imageUrl;
    }
    return 'https://via.placeholder.com/400x300?text=Salon+Image';
  }

  // ✅ ADDED: rating getter (default for now, can be made dynamic later)
  double get rating {
    // TODO: Get actual rating from backend
    return 4.5; // Default rating
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
      phone: (m['phone'] ?? '') as String,
      about: (m['about'] ?? '') as String,
      imageUrl: (m['imageUrl'] ?? '') as String,
    );
  }

  // ✅ ADDED: fromJson factory method (for Django backend)
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
      phone: json['phone'] as String? ?? '',
      about: json['about'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
    );
  }

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