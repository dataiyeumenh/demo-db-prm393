import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = ApiService.getProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadProducts();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${product.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    // Đã bọc ngoặc nhọn {} để sửa cảnh báo curly_braces_in_flow_control_structures
    if (confirm != true) {
      return;
    }

    await ApiService.deleteProduct(product.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Xóa thành công')));
    _refresh();
  }

  Future<void> _openForm({Product? product}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (changed == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nintendo Game Store'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(productId: product.id),
                        ),
                      );
                      _refresh();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty)
                          Image.network(
                            product.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // Sửa cảnh báo unnecessary_underscores tại đây
                            errorBuilder: (ctx, err, stack) => Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 48),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                // FIX lỗi MainAxisAlignment.between -> spaceBetween
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(
                                      product.categoryName,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.avgRating > 0
                                            ? '${product.avgRating.toStringAsFixed(1)} (${product.reviewCount})'
                                            : 'Chưa có đánh giá',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.price.toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              if (product.description != null &&
                                  product.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  product.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () =>
                                        _openForm(product: product),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Sửa'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _deleteProduct(product),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm Game'),
      ),
    );
  }
}
