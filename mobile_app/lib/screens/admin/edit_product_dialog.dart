import 'package:flutter/material.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/product_size.dart';


class EditProductDialog extends StatefulWidget {
  final ProductModel? product;
  final List<CategoryModel> categories;
  final ValueChanged<ProductModel> onSave;

  const EditProductDialog({
    super.key,
    this.product,
    required this.categories,
    required this.onSave,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _categoryId;
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _notesController;

  bool _isAvailable = true;
  bool _isSampleRequiringAdminConfirmation = false;
  bool _isFeatured = false;
  bool _isBestSeller = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _categoryId = p?.categoryId ?? (widget.categories.isNotEmpty ? widget.categories.first.id : '');
    _nameArController = TextEditingController(text: p?.nameAr ?? '');
    _nameEnController = TextEditingController(text: p?.nameEn ?? '');
    _descArController = TextEditingController(text: p?.descriptionAr ?? '');
    _descEnController = TextEditingController(text: p?.descriptionEn ?? '');
    _priceController = TextEditingController(text: p?.basePrice.toStringAsFixed(0) ?? '100');
    _imageUrlController = TextEditingController(
      text: p?.imageUrl ?? 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
    );
    _notesController = TextEditingController(text: p?.preparationNotes ?? '');
    _isAvailable = p?.isAvailable ?? true;
    _isSampleRequiringAdminConfirmation = p?.isSampleRequiringAdminConfirmation ?? false;
    _isFeatured = p?.isFeatured ?? false;
    _isBestSeller = p?.isBestSeller ?? false;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 100.0;
    final id = widget.product?.id ?? 'p-${DateTime.now().millisecondsSinceEpoch}';

    // Build default sizes if none exist
    final sizes = widget.product?.sizes.isNotEmpty == true
        ? widget.product!.sizes
        : [
            ProductSizeModel(id: 's-$id-1', productId: id, nameAr: 'وسط', nameEn: 'Medium', price: price, isDefault: true),
            ProductSizeModel(id: 's-$id-2', productId: id, nameAr: 'كبير', nameEn: 'Large', price: price * 1.35),
          ];

    final product = ProductModel(
      id: id,
      categoryId: _categoryId,
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim().isEmpty ? _nameArController.text.trim() : _nameEnController.text.trim(),
      descriptionAr: _descArController.text.trim(),
      descriptionEn: _descEnController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      basePrice: price,
      isAvailable: _isAvailable,
      isSampleRequiringAdminConfirmation: _isSampleRequiringAdminConfirmation,
      preparationNotes: _notesController.text.trim(),
      isFeatured: _isFeatured,
      isBestSeller: _isBestSeller,
      sizes: sizes,
      extras: widget.product?.extras ?? [],
    );

    widget.onSave(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'تعديل صنف' : 'إضافة صنف جديد',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _categoryId.isNotEmpty ? _categoryId : null,
                    decoration: const InputDecoration(labelText: 'القسم *'),
                    items: widget.categories.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.nameAr));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _categoryId = val);
                    },
                    validator: (v) => (v == null || v.isEmpty) ? 'اختر القسم' : null,
                  ),
                  const SizedBox(height: 10),

                  // Name Arabic
                  TextFormField(
                    controller: _nameArController,
                    decoration: const InputDecoration(labelText: 'الاسم بالعربية *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'أدخل اسم الصنف بالعربية' : null,
                  ),
                  const SizedBox(height: 10),

                  // Name English
                  TextFormField(
                    controller: _nameEnController,
                    decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية (اختياري)'),
                  ),
                  const SizedBox(height: 10),

                  // Base Price
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'السعر الأساسي (جنيه مصري) *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'أدخل السعر' : null,
                  ),
                  const SizedBox(height: 10),

                  // Image URL
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'رابط الصورة (URL)'),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  TextFormField(
                    controller: _descArController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'وصف الصنف والمكونات'),
                  ),
                  const SizedBox(height: 12),

                  // Verification Checkbox (Crucial requirement)
                  SwitchListTile(
                    title: const Text('عينة تتطلب تأكيد الإدارة؟', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('إذا كان مفعلاً، سيظهر تحذير للمستخدم أن الأسعار تجريبية'),
                    value: _isSampleRequiringAdminConfirmation,
                    activeColor: AppColors.warning,
                    onChanged: (val) => setState(() => _isSampleRequiringAdminConfirmation = val),
                  ),

                  // Available Switch
                  SwitchListTile(
                    title: const Text('متاح للطلب الآن'),
                    value: _isAvailable,
                    activeColor: AppColors.success,
                    onChanged: (val) => setState(() => _isAvailable = val),
                  ),

                  // Featured Switch
                  SwitchListTile(
                    title: const Text('صنف مميز (يظهر في الواجهة)'),
                    value: _isFeatured,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isFeatured = val),
                  ),

                  // Best Seller Switch
                  SwitchListTile(
                    title: const Text('الأكثر مبيعاً 🔥'),
                    value: _isBestSeller,
                    activeColor: AppColors.secondary,
                    onChanged: (val) => setState(() => _isBestSeller = val),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: _submit,
                        child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة الصنف'),
                      ),
                    ],
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
