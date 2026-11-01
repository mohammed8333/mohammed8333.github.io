import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_constants.dart';
import '../../core/utils/whatsapp_launcher.dart';
import '../../models/order_model.dart';
import '../../providers/settings_provider.dart';
import '../main_layout.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'حالة الطلب' : 'Order Status'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Success Icon Animation / Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 80,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'تم إنشاء الطلب بنجاح!' : 'Order Placed Successfully!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isArabic ? 'رقم الطلب:' : 'Order Ref:'} ${order.orderReference}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'حالة الطلب الحالية:' : 'Current Status:'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isArabic ? order.statusArabic : order.status.name,
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'العميل:' : 'Customer:'),
                          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'نوع الطلب:' : 'Order Type:'),
                          Text(order.orderType == OrderType.delivery
                              ? (isArabic ? 'توصيل للمنزل' : 'Delivery')
                              : (isArabic ? 'استلام من المطعم' : 'Takeaway')),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'الإجمالي المطلوب:' : 'Total Amount:'),
                          Text(
                            '${order.totalAmount.toStringAsFixed(2)} ${isArabic ? 'جنيه' : 'EGP'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mandatory Pending Confirmation Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.unverifiedTagBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning, width: 1.2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'تنبيه تأكيد الطلب' : 'Important Notice',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isArabic
                          ? AppConstants.whatsAppPendingDisclaimer
                          : AppConstants.whatsAppPendingDisclaimerEn,
                      style: const TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              // Re-open WhatsApp Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsApp,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.chat),
                  label: Text(
                    isArabic ? 'إعادة فتح محادثة واتساب 💬' : 'Re-open WhatsApp Chat 💬',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () => WhatsAppLauncher.launchWhatsAppOrder(order),
                ),
              ),
              const SizedBox(height: 12),

              // Direct Phone Call Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.phone_in_talk),
                  label: Text(
                    isArabic
                        ? 'اتصال هاتفي مباشر بالمطعم (${AppConstants.phone})'
                        : 'Call Restaurant Direct (${AppConstants.phone})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => WhatsAppLauncher.makePhoneCall(AppConstants.phone),
                ),
              ),
              const SizedBox(height: 12),

              // Return Home Button
              TextButton.icon(
                icon: const Icon(Icons.home),
                label: Text(isArabic ? 'العودة للصفحة الرئيسية' : 'Return to Home'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainLayout()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
