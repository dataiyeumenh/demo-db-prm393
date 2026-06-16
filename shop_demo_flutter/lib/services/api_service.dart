import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Lấy toàn bộ danh mục thể loại
  static Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((item) => CategoryModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Lấy toàn bộ game kèm điểm đánh giá
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Lấy chi tiết một game (bao gồm danh sách reviews bên trong)
  static Future<Product> getProductDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Product.fromJson(body['data']);
    } else {
      throw Exception('Failed to load product detail');
    }
  }

  // Hàm tạo sản phẩm mới - BẮT BUỘC có categoryId
  static Future<void> createProduct({
    required int categoryId,
    required String name,
    required double price,
    String? description,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category_id': categoryId,
        'name': name,
        'price': price,
        'description': description,
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create product');
    }
  }

  // Hàm cập nhật sản phẩm - BẮT BUỘC có categoryId
  static Future<void> updateProduct({
    required int id,
    required int categoryId,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category_id': categoryId,
        'name': name,
        if (price != null) 'price': price,
        'description': description,
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // Gửi review bình luận mới cho game
  static Future<void> addReview({
    required int productId,
    required String reviewerName,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/$productId/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reviewer_name': reviewerName,
        'rating': rating,
        'comment': comment,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add review');
    }
  }
}
