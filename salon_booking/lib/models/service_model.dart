class ServiceModel {
  final int id;
  final int salon;
  final String name;
  final String description;
  final String category;
  final double price;
  final int duration;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.salon,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      salon: json['salon'],
      name: json['name'],
      description: json['description'] ?? '',
      category: json['category'],
      price: double.parse(json['price'].toString()),
      duration: json['duration'],
      isActive: json['is_active'],
    );
  }
}
