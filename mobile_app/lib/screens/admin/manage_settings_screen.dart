import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../../models/restaurant_settings.dart';
import '../../providers/settings_provider.dart';

class ManageSettingsScreen extends StatefulWidget {
  const ManageSettingsScreen({super.key});

  @override
  State<ManageSettingsScreen> createState() => _ManageSettingsScreenState();
}

class _ManageSettingsScreenState extends State<ManageSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameArController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsAppController;
  late TextEditingController _addressArController;
  late TextEditingController _deliveryFeeController;
  late TextEditingController _minOrderController;
  late TextEditingController _announcementController;
  late TextEditingController _hoursController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
    _nameArController = TextEditingController(text: settings.restaurantNameAr);
    _phoneController = TextEditingController(text: settings.phone);
    _whatsAppController = TextEditingController(text: settings.whatsApp);
    _addressArController = TextEditingController(text: settings.addressAr);
    _deliveryFeeController = TextEditingController(text: settings.defaultDeliveryFee.toStringAsFixed(0));
    _minOrderController = TextEditingController(text: settings.minimumOrderValue.toStringAsFixed(0));
    _announcementController = TextEditingController(text: settings.announcementAr);
    _hoursController = TextEditingController(text: settings.openingHoursAr);
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _phoneController.dispose();
    _whatsAppController.dispose();
    _addressArController.dispose();
    _deliveryFeeController.dispose();
    _minOrderController.dispose();
    _announcementController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final updated = RestaurantSettingsModel(
      restaurantNameAr: _nameArController.text.trim(),
      restaurantNameEn: provider.settings.restaurantNameEn,
      phone: _phoneController.text.trim(),
      whatsApp: _whatsAppController.text.trim(),
      addressAr: _addressArController.text.trim(),
      addressEn: provider.settings.addressEn,
      googleMapsUrl: provider.settings.googleMapsUrl,
      latitude: provider.settings.latitude,
      longitude: provider.settings.longitude,
      openingHoursAr: _hoursController.text.trim(),
      openingHoursEn: provider.settings.openingHoursEn,
      defaultDeliveryFee: double.tryParse(_deliveryFeeController.text) ?? 20.0,
      minimumOrderValue: double.tryParse(_minOrderController.text) ?? 50.0,
      announcementAr: _announcementController.text.trim(),
      announcementEn: provider.settings.announcementEn,
    );

    provider.updateSettings(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('تم حفظ وتحديث إعدادات المطعم بنجاح!'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات المطعم والتوصيل' : 'Restaurant Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'البيانات الأساسية للمطعم:' : 'Restaurant Basic Info:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Restaurant Name
              TextFormField(
                controller: _nameArController,
                decoration: const InputDecoration(
                  labelText: 'اسم المطعم بالعربية *',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'أدخل اسم المطعم' : null,
              ),
              const SizedBox(height: 12),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم هاتف الاتصال المباشر *',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'أدخل رقم الهاتف' : null,
              ),
              const SizedBox(height: 12),

              // WhatsApp Number
              TextFormField(
                controller: _whatsAppController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الواتساب لاستقبال الطلبات (صيغة دولية بدون +) *',
                  hintText: '201112962692',
                  prefixIcon: Icon(Icons.chat),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'أدخل رقم الواتساب' : null,
              ),
              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _addressArController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'العنوان التفصيلي للمطعم *',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'أدخل العنوان' : null,
              ),
              const SizedBox(height: 12),

              // Opening Hours
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'مواعيد العمل *',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                isArabic ? 'إعدادات التوصيل والحد الأدنى:' : 'Delivery & Ordering Settings:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Default Delivery Fee
              TextFormField(
                controller: _deliveryFeeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رسوم التوصيل الافتراضية (جنيه مصري) *',
                  prefixIcon: Icon(Icons.delivery_dining),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'أدخل رسوم التوصيل' : null,
              ),
              const SizedBox(height: 12),

              // Minimum Order Value
              TextFormField(
                controller: _minOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الحد الأدنى للطلب (جنيه مصري) *',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
              ),
              const SizedBox(height: 12),

              // Announcement
              TextFormField(
                controller: _announcementController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'الإعلان والشريط الترويجي أعلى التطبيق',
                  prefixIcon: Icon(Icons.campaign),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.save),
                  label: Text(
                    isArabic ? 'حفظ وتحديث الإعدادات' : 'Save Settings',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _saveSettings,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
