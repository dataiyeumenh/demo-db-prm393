import 'review_model.dart';

class Product {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final double avgRating;
  final int reviewCount;
  final List<ReviewModel> reviews;

  Product({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.avgRating,
    required this.reviewCount,
    this.reviews = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var reviewList = <ReviewModel>[];
    if (json['reviews'] != null) {
      var list = json['reviews'] as List;
      reviewList = list.map((r) => ReviewModel.fromJson(r)).toList();
    }

    return Product(
      id: json['id'],
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      name: json['name'] ?? '',
      price: double.parse(json['price'].toString()),
      description: json['description'],
      imageUrl: json['image_url'],
      avgRating: double.parse((json['avg_rating'] ?? 0).toString()),
      reviewCount: json['review_count'] ?? 0,
      reviews: reviewList,
    );
  }
}
