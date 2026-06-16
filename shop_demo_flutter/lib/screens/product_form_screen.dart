import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

  int? _selectedCategoryId;
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.product?.imageUrl ?? '',
    );
    _selectedCategoryId = widget.product?.categoryId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final res = await ApiService.getCategories();
      setState(() {
        _categories = res;
        _isLoadingCategories = false;
        if (!isEdit && _categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    } catch (_) {
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null)
      return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    try {
      if (isEdit) {
        await ApiService.updateProduct(
          id: widget.product!.id,
          categoryId:
              _selectedCategoryId!, // Đã fix chuẩn tham số truyền vào hàm
          name: name,
          price: price,
          description: description,
          imageUrl: imageUrl,
        );
      } else {
        await ApiService.createProduct(
          categoryId:
              _selectedCategoryId!, // Đã fix chuẩn tham số truyền vào hàm
          name: name,
          price: price,
          description: description,
          imageUrl: imageUrl,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Cập nhật thành công' : 'Thêm thành công'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa game' : 'Thêm game mới')),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Thể loại game',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategoryId = val),
                          validator: (v) =>
                              v == null ? 'Vui lòng chọn thể loại' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên game',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Vui lòng nhập tên game'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá bán',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Vui lòng nhập giá';
                            if (double.tryParse(v.trim()) == null)
                              return 'Giá không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả nội dung game',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL hình ảnh bìa',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _saveProduct,
                            label: Text(
                              _isSaving ? 'Đang xử lý...' : 'Lưu thông tin',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
