import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_service.dart';
import '../../core/utils/whatsapp_launcher.dart';
import '../order_success/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  String _selectedArea = AppConstants.deliveryAreas.first;
  String _paymentMethod = 'الدفع عند الاستلام';
  bool _isFetchingLocation = false;
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    _nameController = TextEditingController(text: cart.customerName);
    _phoneController = TextEditingController(text: cart.customerPhone);
    _addressController = TextEditingController(text: cart.deliveryAddress);
    _notesController = TextEditingController(text: cart.orderNotes);
    _selectedArea = cart.selectedArea.isNotEmpty ? cart.selectedArea : AppConstants.deliveryAreas.first;
    _latitude = cart.latitude;
    _longitude = cart.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('تم تحديد موقعك الجغرافي عبر GPS بنجاح!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.warning,
              content: Text('يرجى منح إذن الوصول للموقع لتحديده تلقائياً'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.info,
            content: Text('تعذر جلب إحداثيات GPS تلقائياً: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _submitOrderAndLaunchWhatsApp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سلة المشتريات فارغة!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Save customer details in provider
    cart.setCustomerDetails(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      area: _selectedArea,
      payment: _paymentMethod,
      notes: _notesController.text.trim(),
      lat: _latitude,
      lng: _longitude,
    );

    // Create Order Model
    final order = cart.createOrderModel();

    // Submit to Backend API (or save locally if offline)
    final api = ApiService();
    OrderModel finalOrder = order;
    try {
      finalOrder = await api.submitOrder(order);
    } catch (_) {}

    // Open WhatsApp with properly formatted message
    await WhatsAppLauncher.launchWhatsAppOrder(finalOrder);

    // Clear cart after submitting
    cart.clearCart();

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: finalOrder),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;
    final isDelivery = cart.orderType == OrderType.delivery;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إتمام الطلب والدفع' : 'Checkout & Payment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Type Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'نوع استلام الطلب:' : 'Order Type:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<OrderType>(
                              value: OrderType.delivery,
                              groupValue: cart.orderType,
                              activeColor: AppColors.primary,
                              title: Text(isArabic ? 'توصيل للمنزل' : 'Delivery'),
                              onChanged: (val) {
                                if (val != null) cart.setOrderType(val);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<OrderType>(
                              value: OrderType.takeaway,
                              groupValue: cart.orderType,
                              activeColor: AppColors.primary,
                              title: Text(isArabic ? 'استلام (تيك أواي)' : 'Takeaway'),
                              onChanged: (val) {
                                if (val != null) cart.setOrderType(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Customer Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'بيانات العميل:' : 'Customer Information:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الاسم بالكامل *' : 'Full Name *',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return isArabic ? 'يرجى إدخال اسم العميل' : 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Mobile Phone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'رقم الهاتف المحمول (مصر) *' : 'Egyptian Mobile Number *',
                          hintText: '01XXXXXXXXX',
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter mobile number';
                          }
                          final clean = value.replaceAll(' ', '').trim();
                          if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(clean)) {
                            return isArabic
                                ? 'يرجى إدخال رقم هاتف مصري صحيح (مثال: 01112962692)'
                                : 'Please enter valid Egyptian phone number (e.g. 01112962692)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Delivery Details Card (only for Delivery)
              if (isDelivery) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'عنوان التوصيل في إمبابة وضواحيها:' : 'Delivery Address:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),

                        // Area Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedArea,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'المنطقة / الحي *' : 'Area / Neighborhood *',
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          items: AppConstants.deliveryAreas.map((area) {
                            return DropdownMenuItem(
                              value: area,
                              child: Text(area),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedArea = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Detailed Address
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'العنوان بالتفصيل *' : 'Detailed Address *',
                            hintText: isArabic
                                ? 'اسم الشارع، رقم العمارة، رقم الشقة، الطابق، علامة مميزة'
                                : 'Street name, building #, floor, landmark',
                            prefixIcon: const Icon(Icons.home),
                          ),
                          validator: (value) {
                            if (isDelivery && (value == null || value.trim().isEmpty)) {
                              return isArabic ? 'يرجى إدخال عنوان التوصيل' : 'Please enter delivery address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Share GPS Location Button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _latitude != null ? AppColors.success : AppColors.primary,
                            ),
                          ),
                          icon: _isFetchingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _latitude != null ? Icons.check_circle : Icons.my_location,
                                  color: _latitude != null ? AppColors.success : null,
                                ),
                          label: Text(
                            _latitude != null
                                ? (isArabic ? 'تم التقاط إحداثيات موقعك بنجاح ✓' : 'GPS Coordinates Captured ✓')
                                : (isArabic ? 'تحديد موقعي الحالي عبر GPS' : 'Share Current GPS Location'),
                            style: TextStyle(
                              color: _latitude != null ? AppColors.success : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Payment Method Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'طريقة الدفع:' : 'Payment Method:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      RadioListTile<String>(
                        value: 'الدفع عند الاستلام',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        title: Text(isArabic ? 'الدفع نقدياً عند الاستلام (كاش) 💵' : 'Cash on Delivery 💵'),
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                      ),
                      RadioListTile<String>(
                        value: 'فودافون كاش / إنستاباي',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        title: Text(isArabic ? 'فودافون كاش / إنستاباي 📱' : 'Vodafone Cash / InstaPay 📱'),
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                      ),
                      RadioListTile<String>(
                        value: 'بطاقة ائتمان عند الاستلام',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        title: Text(isArabic ? 'بطاقة بنكية عند الاستلام 💳' : 'Credit Card at Door 💳'),
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Additional Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'تعليمات إضافية للمطعم / الدليفري:' : 'Additional Notes:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: isArabic
                              ? 'مثال: الاتصال عند الوصول، بدون رن جرس الباب...'
                              : 'e.g. Call upon arrival, do not ring doorbell...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Order Summary Card
              Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'ملخص الفاتورة:' : 'Order Summary:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ...cart.items.map((i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${i.quantity}x ${isArabic ? i.product.nameAr : i.product.nameEn}'),
                                Text('${i.totalPrice.toStringAsFixed(2)} ${isArabic ? 'ج' : 'EGP'}'),
                              ],
                            ),
                          )),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'المجموع الفرعي:' : 'Subtotal:'),
                          Text('${cart.subtotal.toStringAsFixed(2)} ${isArabic ? 'ج' : 'EGP'}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'رسوم التوصيل:' : 'Delivery Fee:'),
                          Text('${cart.deliveryFee.toStringAsFixed(2)} ${isArabic ? 'ج' : 'EGP'}'),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'الإجمالي النهائي المطلوب:' : 'Final Amount:',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${cart.finalTotal.toStringAsFixed(2)} ${isArabic ? 'جنيه' : 'EGP'}',
                            style: const TextStyle(
                              fontSize: 18,
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

              // Pending Confirmation Disclaimer Required by Section 8
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.unverifiedTagBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withAlpha(120)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isArabic
                            ? AppConstants.whatsAppPendingDisclaimer
                            : AppConstants.whatsAppPendingDisclaimerEn,
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Send via WhatsApp Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsApp,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.chat_bubble_outline, size: 24),
                  label: Text(
                    isArabic ? 'إرسال الطلب عبر واتساب 📲' : 'Submit Order via WhatsApp 📲',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isSubmitting ? null : _submitOrderAndLaunchWhatsApp,
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
