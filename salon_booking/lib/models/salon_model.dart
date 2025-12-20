class SalonModel {
  final String id;
  final String name;
  final String type; // Male | Female | Unisex
  final Map<String, dynamic>
  hours; // per_day: monday..sunday -> {open, close, closed}
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

  Map<String, dynamic> toMap() => {
    'name': name,
    'type': type,
    'hours': hours,
    'address': address,
    'phone': phone,
    'about': about,
    'imageUrl': imageUrl,
  };

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
