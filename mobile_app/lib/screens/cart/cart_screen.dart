import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/settings_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سلة الطلبات' : 'Shopping Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: isArabic ? 'تفريغ السلة' : 'Clear Cart',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isArabic ? 'تفريغ السلة' : 'Clear Cart'),
                    content: Text(isArabic
                        ? 'هل أنت متأكد من رغبتك في حذف جميع الأصناف من السلة؟'
                        : 'Are you sure you want to clear all items in your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          cart.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: Text(isArabic ? 'تفريغ' : 'Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isArabic ? 'سلة المشتريات فارغة' : 'Your Cart is Empty',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'استكشف أشهى وجبات بيتزا أولاد الشيخ وأضف ما يعجبك!'
                          : 'Explore Awlad Alsheikh delicious meals and add what you love!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.restaurant_menu),
                      label: Text(isArabic ? 'تصفح قائمة الطعام' : 'Browse Menu'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Delivery / Takeaway Selector Pill
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          selected: cart.orderType == OrderType.delivery,
                          label: Center(
                            child: Text(
                              isArabic ? 'توصيل للمنزل 🛵' : 'Delivery 🛵',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cart.orderType == OrderType.delivery ? Colors.white : null,
                              ),
                            ),
                          ),
                          selectedColor: AppColors.primary,
                          onSelected: (_) => cart.setOrderType(OrderType.delivery),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          selected: cart.orderType == OrderType.takeaway,
                          label: Center(
                            child: Text(
                              isArabic ? 'استلام من المطعم 🛍️' : 'Takeaway 🛍️',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cart.orderType == OrderType.takeaway ? Colors.white : null,
                              ),
                            ),
                          ),
                          selectedColor: AppColors.primary,
                          onSelected: (_) => cart.setOrderType(OrderType.takeaway),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 75,
                                    height: 75,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.fastfood, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Item details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic ? item.product.nameAr : item.product.nameEn,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item.selectedSize != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${isArabic ? 'الحجم:' : 'Size:'} ${isArabic ? item.selectedSize!.nameAr : item.selectedSize!.nameEn}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                    if (item.selectedExtras.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${isArabic ? 'الإضافات:' : 'Extras:'} ${item.selectedExtras.map((e) => isArabic ? e.nameAr : e.nameEn).join('، ')}',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.secondary),
                                      ),
                                    ],
                                    if (item.notes.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${isArabic ? 'ملاحظة:' : 'Note:'} ${item.notes}',
                                        style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                    const SizedBox(height: 8),

                                    // Price & Quantity controls
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item.totalPrice.toStringAsFixed(2)} ${isArabic ? 'جنيه' : 'EGP'}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        // Quantity counter
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () => cart.updateQuantity(item.id, item.quantity - 1),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(Icons.remove, size: 18),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => cart.updateQuantity(item.id, item.quantity + 1),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(Icons.add, size: 18),
                                                ),
                                              ),
                                            ],
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
                ),

                // Bill Breakdown & Checkout Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isArabic ? 'المجموع الفرعي:' : 'Subtotal:'),
                            Text('${cart.subtotal.toStringAsFixed(2)} ${isArabic ? 'جنيه' : 'EGP'}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Delivery fee
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isArabic ? 'رسوم التوصيل:' : 'Delivery Fee:'),
                            Text(cart.orderType == OrderType.takeaway
                                ? (isArabic ? 'مجاناً (تيك أواي)' : 'Free (Takeaway)')
                                : '${cart.deliveryFee.toStringAsFixed(2)} ${isArabic ? 'جنيه' : 'EGP'}'),
                          ],
                        ),
                        if (cart.discount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? 'الخصم:' : 'Discount:', style: const TextStyle(color: AppColors.success)),
                              Text('-${cart.discount.toStringAsFixed(2)} ${isArabic ? 'جنيه' : 'EGP'}',
                                  style: const TextStyle(color: AppColors.success)),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        // Final Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isArabic ? 'الإجمالي النهائي:' : 'Final Total:',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${cart.finalTotal.toStringAsFixed(2)} ${isArabic ? 'جنيه مصري' : 'EGP'}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Checkout Navigation Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              isArabic ? 'متابعة إتمام الطلب' : 'Proceed to Checkout',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
