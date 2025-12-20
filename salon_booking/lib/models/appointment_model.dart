class Appointment {
  String? id;
  String userId;
  String staffId;
  String serviceId;
  String date;
  String time;
  String status;

  Appointment({this.id, required this.userId, required this.staffId, required this.serviceId, required this.date, required this.time, required this.status});

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'staffId': staffId,
        'serviceId': serviceId,
        'date': date,
        'time': time,
        'status': status,
      };

  factory Appointment.fromMap(Map<String, dynamic> map, String id) => Appointment(
        id: id,
        userId: map['userId'],
        staffId: map['staffId'],
        serviceId: map['serviceId'],
        date: map['date'],
        time: map['time'],
        status: map['status'],
      );
}
