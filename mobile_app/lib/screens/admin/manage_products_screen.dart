import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';

import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import 'edit_product_dialog.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final menu = Provider.of<MenuProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    var list = menu.products;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.nameAr.toLowerCase().contains(q) || p.nameEn.toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إدارة المنتجات والأصناف' : 'Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: isArabic ? 'إضافة صنف جديد' : 'Add Product',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EditProductDialog(
                  categories: menu.categories,
                  onSave: (newProduct) {
                    menu.addProduct(newProduct);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text('تمت إضافة صنف "${newProduct.nameAr}" بنجاح!'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: isArabic ? 'بحث في الأصناف...' : 'Search products...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Products List
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('لا توجد أصناف مطابقة'))
                : ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final product = list[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 55,
                                height: 55,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.fastfood, size: 28),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isArabic ? product.nameAr : product.nameEn,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              if (product.isSampleRequiringAdminConfirmation)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.unverifiedTagBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'عينة',
                                    style: TextStyle(
                                      color: AppColors.unverifiedTagText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${product.displayPrice.toStringAsFixed(0)} ${isArabic ? 'جنيه' : 'EGP'} • ${product.sizes.length} أحجام',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Switch(
                                    value: product.isAvailable,
                                    activeColor: AppColors.success,
                                    onChanged: (_) => menu.toggleProductAvailability(product.id),
                                  ),
                                  Text(
                                    product.isAvailable
                                        ? (isArabic ? 'متاح للطلب' : 'Available')
                                        : (isArabic ? 'غير متوفر' : 'Unavailable'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: product.isAvailable ? AppColors.success : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.secondary),
                                tooltip: isArabic ? 'تعديل' : 'Edit',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => EditProductDialog(
                                      product: product,
                                      categories: menu.categories,
                                      onSave: (updated) {
                                        menu.updateProduct(updated);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.success,
                                            content: Text('تم تحديث صنف "${updated.nameAr}" بنجاح!'),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                tooltip: isArabic ? 'حذف' : 'Delete',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: Text('هل أنت متأكد من حذف "${product.nameAr}"؟'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                          onPressed: () {
                                            menu.deleteProduct(product.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(isArabic ? 'إضافة صنف جديد' : 'New Product'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => EditProductDialog(
              categories: menu.categories,
              onSave: (newProduct) {
                menu.addProduct(newProduct);
              },
            ),
          );
        },
      ),
    );
  }
}
