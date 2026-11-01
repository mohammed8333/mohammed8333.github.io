import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_settings_screen.dart';
import '../main_layout.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final menu = Provider.of<MenuProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    final totalProducts = menu.products.length;
    final availableProducts = menu.products.where((p) => p.isAvailable).length;
    final unverifiedSamples = menu.products.where((p) => p.isSampleRequiringAdminConfirmation).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'لوحة تحكم الإدارة' : 'Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: isArabic ? 'تسجيل الخروج' : 'Logout',
            onPressed: () {
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainLayout()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Welcome Card
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 26,
                      child: Icon(Icons.security, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${isArabic ? 'مرحباً،' : 'Welcome,'} ${auth.adminUsername}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic ? 'مسؤول النظام - بيتزا أولاد الشيخ' : 'System Administrator - Pizza Awlad Alsheikh',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            Text(
              isArabic ? 'نظرة عامة على النظام:' : 'System Overview:',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: isArabic ? 'إجمالي الأصناف' : 'Total Items',
                  value: '$totalProducts',
                  icon: Icons.fastfood,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  title: isArabic ? 'أصناف متاحة' : 'Active Items',
                  value: '$availableProducts',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: isArabic ? 'عينات تحتاج اعتماد' : 'Unverified Samples',
                  value: '$unverifiedSamples',
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  title: isArabic ? 'مواعيد العمل' : 'Hours',
                  value: isArabic ? '24 ساعة' : '24/7',
                  icon: Icons.access_time,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Management Action Tiles
            Text(
              isArabic ? 'المهام الإدارية:' : 'Management Tasks:',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 1. Manage Products
            _buildActionTile(
              context,
              title: isArabic ? 'إدارة المنتجات والأصناف' : 'Manage Products',
              subtitle: isArabic
                  ? 'إضافة، تعديل، حذف، تحديد الأسعار والأحجام وتأكيد العينات'
                  : 'Add, edit, delete products, manage prices & sizes',
              icon: Icons.restaurant_menu,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 2. Manage Orders
            _buildActionTile(
              context,
              title: isArabic ? 'إدارة ومتابعة الطلبات' : 'Manage Orders',
              subtitle: isArabic
                  ? 'متابعة الطلبات الواردة، تحديث الحالات (تأكيد، تجهيز، توصيل)'
                  : 'Track incoming orders and update delivery status',
              icon: Icons.receipt_long,
              color: AppColors.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 3. Restaurant Settings
            _buildActionTile(
              context,
              title: isArabic ? 'إعدادات المطعم والتوصيل' : 'Restaurant Settings',
              subtitle: isArabic
                  ? 'تعديل الهاتف، الواتساب، العنوان، رسوم التوصيل، والإعلانات'
                  : 'Configure phone, WhatsApp, address, delivery fees & promos',
              icon: Icons.settings,
              color: AppColors.info,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageSettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Text(
                    value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
