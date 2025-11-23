class AppRating {
  final int id;
  final int userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  AppRating({
    required this.id,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory AppRating.fromJson(Map<String, dynamic> json) {
    return AppRating(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}