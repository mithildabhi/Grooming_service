// lib/models/staff_model.dart
class StaffModel {
  final String name;
  final String role;
  final String phone;

  StaffModel({
    required this.name,
    required this.role,
    required this.phone,
    required String id,
    required String profileImage,
    required String position,
    required List<String> serviceIds,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'role': role,
    'phone': phone,
    'createdAt': DateTime.now(),
  };

  factory StaffModel.fromMap(Map<String, dynamic> map) => StaffModel(
    name: map['name'] ?? '',
    role: map['role'] ?? '',
    phone: map['phone'] ?? '',
    id: '',
    profileImage: '',
    position: '',
    serviceIds: [],
  );
}
