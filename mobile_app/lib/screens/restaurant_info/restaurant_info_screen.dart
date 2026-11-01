import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_constants.dart';
import '../../core/utils/whatsapp_launcher.dart';
import '../../providers/settings_provider.dart';

class RestaurantInfoScreen extends StatelessWidget {
  const RestaurantInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;
    final rSettings = settings.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'معلومات المطعم' : 'Restaurant Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Restaurant Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_pizza,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isArabic ? rSettings.restaurantNameAr : rSettings.restaurantNameEn,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isArabic ? AppConstants.taglineAr : AppConstants.taglineEn,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Rating Badge
                    InkWell(
                      onTap: () => WhatsAppLauncher.openGoogleMaps(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AppColors.accent, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '${AppConstants.googleRating} / 5 (${AppConstants.reviewCount} ${isArabic ? 'تقييم على خرائط جوجل' : 'Google Reviews'})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Contact Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.phone),
                    label: Text(
                      isArabic ? 'اتصال مباشر' : 'Direct Call',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => WhatsAppLauncher.makePhoneCall(rSettings.phone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsApp,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.chat),
                    label: Text(
                      isArabic ? 'محادثة واتساب' : 'WhatsApp',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => WhatsAppLauncher.launchWhatsAppWithMessage(
                      isArabic
                          ? 'مرحباً مطعم بيتزا أولاد الشيخ، لدي استفسار بخصوص الطلبات.'
                          : 'Hello Pizza Awlad Alsheikh, I have an inquiry.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location & Address Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'العنوان والموقع الجغرافي:' : 'Address & Location:',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isArabic ? rSettings.addressAr : rSettings.addressEn,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الإحداثيات: ${rSettings.latitude}, ${rSettings.longitude}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: Text(
                          isArabic ? 'فتح في خرائط جوجل والحصول على الاتجاهات' : 'Open in Google Maps & Get Directions',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => WhatsAppLauncher.openGoogleMaps(
                          lat: rSettings.latitude,
                          lng: rSettings.longitude,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Working Hours & Services Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'مواعيد العمل والخدمات:' : 'Opening Hours & Services:',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.alarm_on, color: AppColors.success),
                      title: Text(
                        isArabic ? rSettings.openingHoursAr : rSettings.openingHoursEn,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isArabic ? 'خدمة متواصلة على مدار الساعة طوال أيام الأسبوع' : 'Continuous 24/7 service all week',
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildServiceChip(Icons.delivery_dining, isArabic ? 'توصيل منزلي' : 'Delivery'),
                        _buildServiceChip(Icons.shopping_bag, isArabic ? 'تيك أواي' : 'Takeaway'),
                        _buildServiceChip(Icons.table_restaurant, isArabic ? 'صالة المطعم' : 'Dine-in'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChip(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withAlpha(20),
          radius: 22,
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
