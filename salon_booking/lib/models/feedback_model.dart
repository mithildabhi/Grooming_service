class FeedbackModel {
  String? id;
  String userId;
  String staffId;
  String serviceId;
  int rating;
  String comment;

  FeedbackModel({this.id, required this.userId, required this.staffId, required this.serviceId, required this.rating, required this.comment});

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'staffId': staffId,
        'serviceId': serviceId,
        'rating': rating,
        'comment': comment,
      };

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) => FeedbackModel(
        id: id,
        userId: map['userId'],
        staffId: map['staffId'],
        serviceId: map['serviceId'],
        rating: map['rating'],
        comment: map['comment'],
      );
}
