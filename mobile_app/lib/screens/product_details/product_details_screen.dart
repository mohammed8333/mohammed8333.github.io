import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../../models/product.dart';
import '../../models/product_size.dart';
import '../../models/product_extra.dart';
import '../../providers/cart_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/unverified_price_badge.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductSizeModel? _selectedSize;
  final Set<ProductExtraModel> _selectedExtras = {};
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default size selection
    _selectedSize = widget.product.defaultSize;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Real-time dynamic price calculation
  double get _currentUnitPrice {
    double price = _selectedSize?.price ?? widget.product.basePrice;
    for (final extra in _selectedExtras) {
      price += extra.price;
    }
    return price;
  }

  double get _currentTotalPrice => _currentUnitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final isArabic = settings.isArabic;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Image AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryDark,
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 80, color: Colors.white54),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(120),
                          Colors.transparent,
                          Colors.black.withAlpha(180),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unverified price badge
                  if (widget.product.isSampleRequiringAdminConfirmation)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UnverifiedPriceBadge(language: settings.language),
                    ),

                  // Product Title
                  Text(
                    isArabic ? widget.product.nameAr : widget.product.nameEn,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    isArabic ? widget.product.descriptionAr : widget.product.descriptionEn,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sizes Section (if available)
                  if (widget.product.sizes.isNotEmpty) ...[
                    Text(
                      isArabic ? 'اختر الحجم المناسب:' : 'Select Size:',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.sizes.map((size) {
                        final isSelected = _selectedSize?.id == size.id;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(
                            '${isArabic ? size.nameAr : size.nameEn} - ${size.price.toStringAsFixed(0)} ${isArabic ? 'ج' : 'EGP'}',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          selectedColor: AppColors.primary,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSize = size);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Extras Section (if available)
                  if (widget.product.extras.isNotEmpty) ...[
                    Text(
                      isArabic ? 'إضافات ومقبلات اختيارية:' : 'Optional Extras:',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: widget.product.extras.map((extra) {
                          final isChecked = _selectedExtras.contains(extra);
                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: AppColors.primary,
                            title: Text(
                              isArabic ? extra.nameAr : extra.nameEn,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '+${extra.price.toStringAsFixed(0)} ${isArabic ? 'جنيه' : 'EGP'}',
                              style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                            ),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedExtras.add(extra);
                                } else {
                                  _selectedExtras.remove(extra);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isArabic ? 'الكمية المطلوبة:' : 'Quantity:',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Special Notes / Instructions
                  Text(
                    isArabic ? 'ملاحظات خاصة بالتحضير:' : 'Special Instructions:',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? 'مثال: بدون فلفل حار، كاتشب ومايونيز زيادة، تسوية زيادة...'
                          : 'e.g. No spicy peppers, extra sauce, well done...',
                    ),
                  ),
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar with Dynamic Real-time Price and Add to Cart Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Dynamic calculated total price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'السعر الإجمالي:' : 'Total Price:',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${_currentTotalPrice.toStringAsFixed(2)} ${isArabic ? 'جنيه' : 'EGP'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    isArabic ? 'إضافة إلى السلة' : 'Add to Cart',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    cart.addToCart(
                      product: widget.product,
                      size: _selectedSize,
                      extras: _selectedExtras.toList(),
                      quantity: _quantity,
                      notes: _notesController.text.trim(),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text(
                          isArabic
                              ? 'تمت إضافة "${widget.product.nameAr}" إلى السلة!'
                              : 'Added "${widget.product.nameEn}" to cart!',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: isArabic ? 'عرض السلة' : 'View Cart',
                          textColor: Colors.white,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
