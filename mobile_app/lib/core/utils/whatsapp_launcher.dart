import 'package:url_launcher/url_launcher.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_constants.dart';
import '../../models/order_model.dart';

class WhatsAppLauncher {
  /// Generates the standard Arabic order message specified for Pizza Awlad Alsheikh
  static String formatOrderMessage(OrderModel order) {
    final buffer = StringBuffer();

    buffer.writeln("مرحباً مطعم ${AppConstants.restaurantNameAr} 🍕");
    buffer.writeln();
    buffer.writeln("أريد تأكيد الطلب التالي:");
    buffer.writeln();
    buffer.writeln("رقم الطلب: ${order.orderReference}");
    buffer.writeln();
    buffer.writeln("بيانات العميل:");
    buffer.writeln("الاسم: ${order.customerName}");
    buffer.writeln("الهاتف: ${order.customerPhone}");
    
    final orderTypeStr = order.orderType == OrderType.delivery
        ? "توصيل للمنزل 🛵"
        : "استلام من المطعم (تيك أواي) 🛍️";
    buffer.writeln("نوع الطلب: $orderTypeStr");

    if (order.orderType == OrderType.delivery) {
      buffer.writeln("العنوان: ${order.deliveryAddress}");
      if (order.area.isNotEmpty) {
        buffer.writeln("المنطقة: ${order.area}");
      }
      if (order.latitude != null && order.longitude != null) {
        buffer.writeln("الموقع على الخريطة: https://maps.google.com/?q=${order.latitude},${order.longitude}");
      }
    }

    if (order.paymentMethod.isNotEmpty) {
      buffer.writeln("طريقة الدفع: ${order.paymentMethod}");
    }

    if (order.notes.isNotEmpty) {
      buffer.writeln("ملاحظات خاصة: ${order.notes}");
    }

    buffer.writeln();
    buffer.writeln("الطلبات:");

    for (int i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      buffer.writeln("${i + 1}. ${item.productNameAr}");
      if (item.selectedSizeNameAr.isNotEmpty) {
        buffer.writeln("   الحجم: ${item.selectedSizeNameAr}");
      }
      if (item.extras.isNotEmpty) {
        final extrasStr = item.extras
            .map((e) => "${e.extraNameAr} (+${e.extraPrice.toStringAsFixed(0)} ج)")
            .join("، ");
        buffer.writeln("   الإضافات: $extrasStr");
      }
      if (item.notes.isNotEmpty) {
        buffer.writeln("   ملاحظات: ${item.notes}");
      }
      buffer.writeln("   الكمية: ${item.quantity}");
      buffer.writeln("   السعر: ${item.totalPrice.toStringAsFixed(2)} جنيه");
      buffer.writeln();
    }

    buffer.writeln("الحساب الإجمالي:");
    buffer.writeln("• المجموع الفرعي: ${order.subtotal.toStringAsFixed(2)} جنيه");
    if (order.orderType == OrderType.delivery) {
      buffer.writeln("• رسوم التوصيل: ${order.deliveryFee.toStringAsFixed(2)} جنيه");
    }
    if (order.discount > 0) {
      buffer.writeln("• الخصم: -${order.discount.toStringAsFixed(2)} جنيه");
    }
    buffer.writeln("• الإجمالي: ${order.totalAmount.toStringAsFixed(2)} جنيه");
    buffer.writeln();
    buffer.writeln("يرجى تأكيد الطلب ووقت التجهيز والتوصيل.");

    return buffer.toString();
  }

  /// Launches WhatsApp with the prefilled Arabic message
  static Future<bool> launchWhatsAppOrder(OrderModel order) async {
    final message = formatOrderMessage(order);
    return launchWhatsAppWithMessage(message);
  }

  /// Launches WhatsApp with any text message to the restaurant WhatsApp number
  static Future<bool> launchWhatsAppWithMessage(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final urlString = "https://wa.me/${AppConstants.whatsAppNumber}?text=$encodedMessage";
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to platform default launch
        return await launchUrl(uri);
      }
    } catch (e) {
      return false;
    }
  }

  /// Direct phone call to restaurant
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse("tel:$cleanNumber");
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Open Google Maps with restaurant location or directions
  static Future<bool> openGoogleMaps({double? lat, double? lng}) async {
    final targetLat = lat ?? AppConstants.latitude;
    final targetLng = lng ?? AppConstants.longitude;
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$targetLat,$targetLng");
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
