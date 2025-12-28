class EmployeeModel {
  final int id;
  final int user;
  final int salon;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String primarySkill;
  final List<String> workingDays;
  final DateTime? createdAt;
  final bool isActive;

  EmployeeModel({
    required this.id,
    required this.user,
    required this.salon,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.primarySkill,
    required this.workingDays,
    this.createdAt,
    this.isActive = true,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,
      user: json['user'] as int,
      salon: json['salon'] as int,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'stylist',
      primarySkill: json['primary_skill'] as String? ?? 'hair_styling',
      workingDays: json['working_days'] != null
          ? List<String>.from(json['working_days'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'salon': salon,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'primary_skill': primarySkill,
      'working_days': workingDays,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  EmployeeModel copyWith({
    int? id,
    int? user,
    int? salon,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? primarySkill,
    List<String>? workingDays,
    DateTime? createdAt,
    bool? isActive,

  }) {
    return EmployeeModel(
      id: id ?? this.id,
      user: user ?? this.user,
      salon: salon ?? this.salon,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      primarySkill: primarySkill ?? this.primarySkill,
      workingDays: workingDays ?? this.workingDays,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Calculate performance score based on mock data
  String get performanceScore {
    // Mock calculation based on name
    if (fullName.contains('Alex')) return '92%';
    if (fullName.contains('Sarah')) return '89%';
    if (fullName.contains('John')) return '68%';
    return 'Available';
  }

  // Determine performance status
  String get performanceStatus {
    final score = performanceScore;
    if (score == 'Available') return 'Available';
    
    final numericScore = int.tryParse(score.replaceAll('%', '')) ?? 0;
    if (numericScore >= 85) return 'Top Performer';
    if (numericScore >= 70) return 'Good';
    if (numericScore < 70) return 'Overloaded';
    return 'Available';
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, name: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmployeeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}