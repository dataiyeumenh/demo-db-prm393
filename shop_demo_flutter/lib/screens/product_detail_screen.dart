import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int
  productId; // Khai báo chuẩn tên productId để đồng bộ với List Screen
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _detailFuture;
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    _detailFuture = ApiService.getProductDetail(widget.productId);
  }

  Future<void> _submitReview() async {
    if (_nameController.text.trim().isEmpty ||
        _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đủ tên và bình luận')),
      );
      return;
    }

    try {
      await ApiService.addReview(
        productId: widget.productId,
        reviewerName: _nameController.text.trim(),
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      _nameController.clear();
      _commentController.clear();
      setState(() {
        _rating = 5;
        _loadDetail();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi gửi đánh giá: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết game & Đánh giá')),
      body: FutureBuilder<Product>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final product = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Thể loại: ${product.categoryName}',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${product.price.toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'Không có mô tả',
                  style: const TextStyle(fontSize: 15),
                ),
                const Divider(height: 32),

                Text(
                  'Đánh giá từ cộng đồng (${product.reviews.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                if (product.reviews.isEmpty)
                  const Text('Chưa có đánh giá nào cho tựa game này.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: product.reviews.length,
                    itemBuilder: (context, idx) {
                      final rev = product.reviews[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // Đã fix lỗi .between
                            children: [
                              Text(
                                rev.reviewerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 16,
                                    color: i < rev.rating
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(rev.comment ?? ''),
                        ),
                      );
                    },
                  ),

                const Divider(height: 32),
                Text(
                  'Gửi đánh giá của bạn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên của bạn',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _rating,
                  decoration: const InputDecoration(
                    labelText: 'Số sao chấm điểm',
                    border: OutlineInputBorder(),
                  ),
                  items: [5, 4, 3, 2, 1]
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s, child: Text('$s Sao')),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _rating = v ?? 5),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung bình luận',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: _submitReview,
                    child: const Text('Gửi Bình Luận'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
