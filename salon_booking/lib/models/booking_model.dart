class BookingModel {
  final int? id;
  final int userId;
  final int salonId;
  final String salonName;
  final int serviceId;
  final String serviceName;
  final int? staffId;
  final String? staffName;
  final String? staffRole;
  final String date;
  final String time;
  final String? endTime;
  final int durationMinutes;
  final double price;
  final String status;
  final String? statusDisplay;
  final String customerName;
  final String userPhone;
  final String? customerEmail;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final bool isRated;

  BookingModel({
    this.id,
    required this.userId,
    required this.salonId,
    required this.salonName,
    required this.serviceId,
    required this.serviceName,
    this.staffId,
    this.staffName,
    this.staffRole,
    required this.date,
    required this.time,
    this.endTime,
    required this.durationMinutes,
    required this.price,
    required this.status,
    this.statusDisplay,
    required this.customerName,
    required this.userPhone,
    this.customerEmail,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.isRated = false,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user']) ?? 0,
      salonId: _parseInt(json['salon']) ?? 0,
      salonName: json['salon_name'] as String? ?? '',
      serviceId: _parseInt(json['service']) ?? 0,
      serviceName: json['service_name'] as String? ?? '',
      staffId: _parseInt(json['staff']),
      staffName: json['staff_name'] as String?,
      staffRole: json['staff_role'] as String?,
      date: json['booking_date'] as String? ?? '',
      time: json['booking_time'] as String? ?? '',
      endTime: json['end_time'] as String?,
      durationMinutes: _parseInt(json['service_duration']) ?? 0,
      price: _parsePrice(json['service_price']),
      status: json['status'] as String? ?? 'PENDING',
      statusDisplay: json['status_display'] as String?,
      customerName: json['customer_name'] as String? ?? '',
      userPhone: json['customer_phone'] as String? ?? '',
      customerEmail: json['customer_email'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      isRated: json['is_rated'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'salon': salonId,
      'salon_name': salonName,
      'service': serviceId,
      'service_name': serviceName,
      'staff': staffId,
      'staff_name': staffName,
      'staff_role': staffRole,
      'booking_date': date,
      'booking_time': time,
      'end_time': endTime,
      'service_duration': durationMinutes,
      'service_price': price,
      'status': status,
      'status_display': statusDisplay,
      'customer_name': customerName,
      'customer_phone': userPhone,
      'customer_email': customerEmail,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // ✅ Parse int from various types
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // ✅ Parse double from various types
  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  BookingModel copyWith({
    int? id,
    int? userId,
    int? salonId,
    String? salonName,
    int? serviceId,
    String? serviceName,
    int? staffId,
    String? staffName,
    String? staffRole,
    String? date,
    String? time,
    String? endTime,
    int? durationMinutes,
    double? price,
    String? status,
    String? statusDisplay,
    String? customerName,
    String? userPhone,
    String? customerEmail,
    String? notes,
    String? createdAt,
    String? updatedAt,
    bool? isRated,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      staffRole: staffRole ?? this.staffRole,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      customerName: customerName ?? this.customerName,
      userPhone: userPhone ?? this.userPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRated: isRated ?? this.isRated,
    );
  }
}
