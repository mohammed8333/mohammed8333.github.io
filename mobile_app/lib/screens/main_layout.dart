import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'home/home_screen.dart';
import 'menu/menu_screen.dart';
import 'cart/cart_screen.dart';
import 'restaurant_info/restaurant_info_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_login_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final isArabic = settings.isArabic;

    final titles = [
      isArabic ? 'بيتزا أولاد الشيخ' : 'Pizza Awlad Alsheikh',
      isArabic ? 'قائمة الطعام' : 'Menu',
      isArabic ? 'سلة الطلبات' : 'Cart',
      isArabic ? 'معلومات المطعم' : 'Restaurant Info',
      auth.isAuthenticated
          ? (isArabic ? 'لوحة الإدارة' : 'Admin')
          : (isArabic ? 'دخول الإدارة' : 'Admin Login'),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: titles[_currentIndex],
        showCart: _currentIndex != 2, // hide cart icon when on cart page
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigateToMenu: () => _onTabTapped(1)),
          const MenuScreen(),
          const CartScreen(),
          const RestaurantInfoScreen(),
          auth.isAuthenticated ? const AdminDashboardScreen() : const AdminLoginScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        indicatorColor: AppColors.primary.withAlpha(40),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: isArabic ? 'الرئيسية' : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu, color: AppColors.primary),
            label: isArabic ? 'المنيو' : 'Menu',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag, color: AppColors.primary),
            ),
            label: isArabic ? 'السلة' : 'Cart',
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront, color: AppColors.primary),
            label: isArabic ? 'المطعم' : 'Info',
          ),
          NavigationDestination(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
            label: isArabic ? 'الإدارة' : 'Admin',
          ),
        ],
      ),
    );
  }
}
