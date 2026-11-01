import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pizza_awlad_alsheikh/core/utils/whatsapp_launcher.dart';
import 'package:pizza_awlad_alsheikh/models/cart_item.dart';
import 'package:pizza_awlad_alsheikh/models/order_model.dart';
import 'package:pizza_awlad_alsheikh/models/product.dart';
import 'package:pizza_awlad_alsheikh/models/product_size.dart';
import 'package:pizza_awlad_alsheikh/models/product_extra.dart';
import 'package:pizza_awlad_alsheikh/providers/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pizza Awlad Alsheikh - Quality Assurance & Calculation Tests', () {
    late ProductModel testPizza;
    late ProductSizeModel sizeMedium;
    late ProductSizeModel sizeLarge;
    late ProductExtraModel extraCheese;
    late ProductExtraModel extraMushroom;

    setUp(() {
      SharedPreferences.setMockInitialValues({});

      testPizza = ProductModel(
        id: 'pizza-test-1',
        categoryId: 'cat-1',
        nameAr: 'بيتزا سوبر سوبريم أولاد الشيخ',
        nameEn: 'Super Supreme Pizza',
        basePrice: 130.0,
      );

      sizeMedium = ProductSizeModel(
        id: 's-m',
        productId: 'pizza-test-1',
        nameAr: 'وسط',
        nameEn: 'Medium',
        price: 130.0,
        isDefault: true,
      );

      sizeLarge = ProductSizeModel(
        id: 's-l',
        productId: 'pizza-test-1',
        nameAr: 'كبير',
        nameEn: 'Large',
        price: 175.0,
      );

      extraCheese = ProductExtraModel(
        id: 'e-1',
        productId: 'pizza-test-1',
        nameAr: 'جبنة موتزاريلا إضافية',
        nameEn: 'Extra Mozzarella',
        price: 25.0,
      );

      extraMushroom = ProductExtraModel(
        id: 'e-2',
        productId: 'pizza-test-1',
        nameAr: 'مشروم طازج',
        nameEn: 'Fresh Mushroom',
        price: 20.0,
      );
    });

    test('Dynamic Price Calculation with Size and Extras', () {
      final cartItem = CartItem(
        id: 'item-1',
        product: testPizza,
        selectedSize: sizeLarge, // 175 EGP
        selectedExtras: [extraCheese, extraMushroom], // +25 + 20 = +45 EGP
        quantity: 2,
      );

      // Unit price: 175 + 25 + 20 = 220 EGP
      expect(cartItem.unitPrice, 220.0);
      // Total price: 220 * 2 = 440 EGP
      expect(cartItem.totalPrice, 440.0);
    });

    test('WhatsApp Arabic Message Encoding & Formatting', () {
      final orderItem = OrderItemModel(
        productId: 'p-1',
        productNameAr: 'بيتزا سوبر سوبريم أولاد الشيخ',
        selectedSizeNameAr: 'كبير',
        selectedSizePrice: 175.0,
        quantity: 2,
        unitPrice: 200.0,
        totalPrice: 400.0,
        notes: 'بدون بصل',
        extras: [
          OrderItemExtraModel(extraNameAr: 'جبنة موتزاريلا إضافية', extraPrice: 25.0),
        ],
      );

      final order = OrderModel(
        id: 'ord-1001',
        orderReference: '#ORD-1001',
        customerName: 'محمد أحمد',
        customerPhone: '01112962692',
        deliveryAddress: 'امتداد شارع الوحدة، المنيرة، إمبابة',
        area: 'المنيرة',
        orderType: OrderType.delivery,
        paymentMethod: 'الدفع عند الاستلام',
        notes: 'الرجاء الاتصال قبل الوصول',
        latitude: 30.0880921,
        longitude: 31.2103625,
        subtotal: 400.0,
        deliveryFee: 20.0,
        discount: 0.0,
        totalAmount: 420.0,
        createdAt: DateTime.now(),
        items: [orderItem],
      );

      final message = WhatsAppLauncher.formatOrderMessage(order);

      // Verify all required Arabic fields are in the formatted WhatsApp message
      expect(message.contains('بيتزا أولاد الشيخ'), isTrue);
      expect(message.contains('#ORD-1001'), isTrue);
      expect(message.contains('محمد أحمد'), isTrue);
      expect(message.contains('01112962692'), isTrue);
      expect(message.contains('توصيل للمنزل'), isTrue);
      expect(message.contains('امتداد شارع الوحدة'), isTrue);
      expect(message.contains('30.0880921,31.2103625'), isTrue);
      expect(message.contains('كبير'), isTrue);
      expect(message.contains('جبنة موتزاريلا إضافية'), isTrue);
      expect(message.contains('بدون بصل'), isTrue);
      expect(message.contains('420.00'), isTrue);
      expect(message.contains('يرجى تأكيد الطلب ووقت التجهيز والتوصيل.'), isTrue);
    });

    test('Cart Provider Calculations and Order Type Switch', () {
      final cart = CartProvider();
      cart.setDeliveryFee(20.0);

      cart.addToCart(
        product: testPizza,
        size: sizeMedium,
        quantity: 1,
      );

      expect(cart.subtotal, 130.0);
      expect(cart.deliveryFee, 20.0);
      expect(cart.finalTotal, 150.0);

      // Switch to takeaway -> delivery fee becomes 0
      cart.setOrderType(OrderType.takeaway);
      expect(cart.deliveryFee, 0.0);
      expect(cart.finalTotal, 130.0);
    });
  });
}
