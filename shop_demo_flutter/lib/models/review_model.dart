class ReviewModel {
  final int id;
  final String reviewerName;
  final int rating;
  final String? comment;

  ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.rating,
    this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      reviewerName: json['reviewer_name'] ?? 'Ẩn danh',
      rating: json['rating'] ?? 5,
      comment: json['comment'],
    );
  }
}
