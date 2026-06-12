import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/products';

  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];

      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<void> createProduct({
    required String name,
    required double price,
    String? description,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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

  static Future<void> updateProduct({
    required int id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
}
