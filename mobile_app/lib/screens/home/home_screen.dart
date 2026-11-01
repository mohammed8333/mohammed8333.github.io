import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';

import '../../core/utils/whatsapp_launcher.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/hero_banner_slider.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/product_card.dart';


class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToMenu;

  const HomeScreen({super.key, required this.onNavigateToMenu});

  @override
  Widget build(BuildContext context) {
    final menu = Provider.of<MenuProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;
    final rSettings = settings.settings;

    return RefreshIndicator(
      onRefresh: () => menu.loadData(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo Announcement Banner (if any)
            if (rSettings.announcementAr.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: AppColors.secondary,
                child: Row(
                  children: [
                    const Icon(Icons.campaign, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic ? rSettings.announcementAr : rSettings.announcementEn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                decoration: InputDecoration(
                  hintText: isArabic ? 'ابحث عن بيتزا، كريب، حواوشي...' : 'Search pizza, crepes, hawawshi...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: menu.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => menu.setSearchQuery(''),
                        )
                      : null,
                ),
                onChanged: (val) {
                  menu.setSearchQuery(val);
                  if (val.trim().isNotEmpty) {
                    onNavigateToMenu();
                  }
                },
              ),
            ),

            // Hero Promotional Banners
            const HeroBannerSlider(),

            // Quick WhatsApp & Call Action Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => WhatsAppLauncher.launchWhatsAppWithMessage(
                        isArabic ? 'مرحباً، أود معرفة عروض بيتزا أولاد الشيخ اليوم.' : 'Hello, I want to know today offers.',
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.whatsApp.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.whatsApp.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat, color: AppColors.whatsApp, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'طلب سريع عبر واتساب' : 'Quick WhatsApp Order',
                              style: const TextStyle(
                                color: AppColors.whatsApp,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => WhatsAppLauncher.makePhoneCall(rSettings.phone),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'اتصال بالفرع 24 ساعة' : 'Call 24/7 Branch',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? 'الأقسام الرئيسية' : 'Categories',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: onNavigateToMenu,
                    child: Text(isArabic ? 'عرض القائمة بالكامل' : 'View Full Menu'),
                  ),
                ],
              ),
            ),

            // Categories Chips
            CategoryChips(
              categories: menu.categories,
              selectedCategoryId: menu.selectedCategoryId,
              onCategorySelected: (catId) {
                menu.selectCategory(catId);
                onNavigateToMenu();
              },
            ),
            const SizedBox(height: 12),

            // Best Sellers Section
            if (menu.bestSellerProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: AppColors.secondary, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      isArabic ? 'الأكثر طلباً ومبيعاً 🔥' : 'Best Sellers 🔥',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ...menu.bestSellerProducts.take(3).map((p) => ProductCard(product: p)),
            ],

            // Featured Products Section
            if (menu.featuredProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.accent, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      isArabic ? 'أصناف مميزة يقترحها الشيف ⭐' : 'Chef Specials ⭐',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ...menu.featuredProducts.take(3).map((p) => ProductCard(product: p)),
            ],

            // Restaurant Location & Google Maps Card
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'موقع مطعم بيتزا أولاد الشيخ:' : 'Restaurant Location:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? rSettings.addressAr : rSettings.addressEn,
                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: Text(isArabic ? 'فتح في خرائط جوجل' : 'Open in Google Maps'),
                      onPressed: () => WhatsAppLauncher.openGoogleMaps(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
