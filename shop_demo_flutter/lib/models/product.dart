class Product {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      price: double.parse(json['price'].toString()),
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}
