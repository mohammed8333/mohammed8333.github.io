import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../models/product.dart';
import '../providers/menu_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/product_details/product_details_screen.dart';
import 'unverified_price_badge.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final isArabic = settings.isArabic;
    final isFav = menuProvider.isFavorite(product.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Stack
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Gradient for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(80),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Featured / BestSeller Tag
                if (product.isFeatured || product.isBestSeller)
                  Positioned(
                    top: 10,
                    right: isArabic ? 10 : null,
                    left: isArabic ? null : 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isBestSeller ? AppColors.secondary : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Text(
                        product.isBestSeller
                            ? (isArabic ? 'الأكثر طلباً 🔥' : 'Best Seller 🔥')
                            : (isArabic ? 'مميز ⭐' : 'Featured ⭐'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favorite Heart Button
                Positioned(
                  top: 8,
                  left: isArabic ? 8 : null,
                  right: isArabic ? null : 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(220),
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.primary : Colors.black87,
                        size: 20,
                      ),
                      onPressed: () => menuProvider.toggleFavorite(product.id),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unverified price badge requirement
                  if (product.isSampleRequiringAdminConfirmation)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: UnverifiedPriceBadge(
                        isCompact: true,
                        language: settings.language,
                      ),
                    ),

                  // Product Title
                  Text(
                    isArabic ? product.nameAr : product.nameEn,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    isArabic ? product.descriptionAr : product.descriptionEn,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Price and Customize Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'السعر يبدأ من:' : 'Starts from:',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            '${product.displayPrice.toStringAsFixed(0)} ${isArabic ? 'جنيه' : 'EGP'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: Text(
                          isArabic ? 'تخصيص وطلب' : 'Customize',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
  }
}
