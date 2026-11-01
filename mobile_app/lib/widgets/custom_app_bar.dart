import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/cart/cart_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCart;
  final bool showActions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showCart = true,
    this.showActions = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_pizza, color: AppColors.secondary, size: 26),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: showActions
          ? [
              // Language switch button
              IconButton(
                icon: Text(
                  settingsProvider.isArabic ? 'EN' : 'عربي',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                tooltip: 'تغيير اللغة / Change Language',
                onPressed: () => settingsProvider.toggleLanguage(),
              ),
              // Dark / Light mode toggle
              IconButton(
                icon: Icon(
                  settingsProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'الوضع الليلي / Dark Mode',
                onPressed: () => settingsProvider.toggleDarkMode(),
              ),
              // Cart badge icon
              if (showCart)
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                          tooltip: 'سلة الطلبات',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CartScreen()),
                            );
                          },
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              const SizedBox(width: 6),
            ]
          : null,
    );
  }
}
