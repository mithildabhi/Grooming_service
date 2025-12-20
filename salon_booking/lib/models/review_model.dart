class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final String reply;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.reply,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'reply': reply,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory ReviewModel.fromMap(String id, Map<String, dynamic> m) => ReviewModel(
    id: id,
    userId: m['userId'] ?? '',
    userName: m['userName'] ?? '',
    rating: (m['rating'] ?? 0).toInt(),
    comment: m['comment'] ?? '',
    reply: m['reply'] ?? '',
    createdAt: m['createdAt'] != null
        ? DateTime.tryParse(m['createdAt'])
        : null,
  );
}
