class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String category;
  final String gender;
  final String description;
  final String image;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.category,
    required this.gender,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'durationMinutes': durationMinutes,
    'category': category,
    'gender': gender,
    'description': description,
    'image': image,
  };

  factory ServiceModel.fromMap(String id, Map<String, dynamic> m) =>
      ServiceModel(
        id: id,
        name: (m['name'] ?? '') as String,
        price: (m['price'] ?? 0).toDouble(),
        durationMinutes: (m['durationMinutes'] ?? 30) is int
            ? (m['durationMinutes'] as int)
            : (m['durationMinutes'] ?? 30).toInt(),
        category: (m['category'] ?? '') as String,
        gender: (m['gender'] ?? 'Unisex') as String,
        description: (m['description'] ?? '') as String,
        image: (m['image'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {'id': id, ...toMap()};
}
