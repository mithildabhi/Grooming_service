class BookingModel {
  final String id;
  final String userId;
  final String customerName;
  final String userPhone;
  final String serviceId;
  final String serviceName;
  final String staffId;
  final String staffName;
  final String date; // yyyy-mm-dd
  final String time; // hh:mm
  final int durationMinutes;
  final String status;
  final double price;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.userPhone,
    required this.serviceId,
    required this.serviceName,
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.status,
    required this.price,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'customerName': customerName,
    'userPhone': userPhone,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'staffId': staffId,
    'staffName': staffName,
    'date': date,
    'time': time,
    'durationMinutes': durationMinutes,
    'status': status,
    'price': price,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory BookingModel.fromMap(String id, Map<String, dynamic> m) =>
      BookingModel(
        id: id,
        userId: m['userId'] ?? '',
        customerName: m['customerName'] ?? '',
        userPhone: m['userPhone'] ?? '',
        serviceId: m['serviceId'] ?? '',
        serviceName: m['serviceName'] ?? '',
        staffId: m['staffId'] ?? '',
        staffName: m['staffName'] ?? '',
        date: m['date'] ?? '',
        time: m['time'] ?? '',
        durationMinutes: (m['durationMinutes'] ?? 30).toInt(),
        status: m['status'] ?? 'REQUESTED',
        price: (m['price'] ?? 0).toDouble(),
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt'])
            : null,
      );
}
