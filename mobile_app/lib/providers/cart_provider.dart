import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_size.dart';
import '../models/product_extra.dart';
import '../models/order_model.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_constants.dart';
import '../services/storage_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  OrderType _orderType = OrderType.delivery;
  double _deliveryFee = AppConstants.defaultDeliveryFee;
  double _discount = 0.0;
  String _customerName = '';
  String _customerPhone = '';
  String _deliveryAddress = '';
  String _selectedArea = AppConstants.deliveryAreas.first;
  String _paymentMethod = 'الدفع عند الاستلام';
  String _orderNotes = '';
  double? _latitude;
  double? _longitude;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  OrderType get orderType => _orderType;
  double get deliveryFee => _orderType == OrderType.takeaway ? 0.0 : _deliveryFee;
  double get discount => _discount;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get deliveryAddress => _deliveryAddress;
  String get selectedArea => _selectedArea;
  String get paymentMethod => _paymentMethod;
  String get orderNotes => _orderNotes;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  CartProvider() {
    _loadPersistedCart();
  }

  Future<void> _loadPersistedCart() async {
    final loaded = await StorageService.loadCart();
    if (loaded.isNotEmpty) {
      _items.clear();
      _items.addAll(loaded);
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    await StorageService.saveCart(_items);
  }

  /// Dynamic Subtotal calculation
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Final Total including delivery fee and discounts
  double get finalTotal => max(0.0, subtotal + deliveryFee - _discount);

  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void setCustomerDetails({
    String? name,
    String? phone,
    String? address,
    String? area,
    String? payment,
    String? notes,
    double? lat,
    double? lng,
  }) {
    if (name != null) _customerName = name;
    if (phone != null) _customerPhone = phone;
    if (address != null) _deliveryAddress = address;
    if (area != null) _selectedArea = area;
    if (payment != null) _paymentMethod = payment;
    if (notes != null) _orderNotes = notes;
    if (lat != null) _latitude = lat;
    if (lng != null) _longitude = lng;
    notifyListeners();
  }

  void addToCart({
    required ProductModel product,
    ProductSizeModel? size,
    List<ProductExtraModel>? extras,
    int quantity = 1,
    String notes = '',
  }) {
    // Check if an identical product with the exact same size, extras, and notes already exists
    final extrasIds = (extras ?? []).map((e) => e.id).toSet();
    
    int existingIndex = -1;
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.product.id == product.id &&
          item.selectedSize?.id == size?.id &&
          item.notes.trim() == notes.trim() &&
          item.selectedExtras.map((e) => e.id).toSet().containsAll(extrasIds) &&
          extrasIds.containsAll(item.selectedExtras.map((e) => e.id).toSet())) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: 'cart-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}',
        product: product,
        selectedSize: size ?? product.defaultSize,
        selectedExtras: extras != null ? List.from(extras) : [],
        quantity: quantity,
        notes: notes,
      ));
    }

    _persist();
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    final idx = _items.indexWhere((i) => i.id == cartItemId);
    if (idx != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx].quantity = newQuantity;
      }
      _persist();
      notifyListeners();
    }
  }

  void removeFromCart(String cartItemId) {
    _items.removeWhere((i) => i.id == cartItemId);
    _persist();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _persist();
    notifyListeners();
  }

  /// Converts the current cart state into a ready-to-submit OrderModel
  OrderModel createOrderModel() {
    final randomNum = 1000 + Random().nextInt(9000);
    final ref = "#ORD-$randomNum";

    final orderItems = _items.map((cartItem) {
      return OrderItemModel(
        productId: cartItem.product.id,
        productNameAr: cartItem.product.nameAr,
        productNameEn: cartItem.product.nameEn,
        selectedSizeNameAr: cartItem.selectedSize?.nameAr ?? '',
        selectedSizePrice: cartItem.selectedSize?.price ?? cartItem.product.basePrice,
        quantity: cartItem.quantity,
        unitPrice: cartItem.unitPrice,
        totalPrice: cartItem.totalPrice,
        notes: cartItem.notes,
        extras: cartItem.selectedExtras.map((e) {
          return OrderItemExtraModel(
            extraNameAr: e.nameAr,
            extraPrice: e.price,
          );
        }).toList(),
      );
    }).toList();

    return OrderModel(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      orderReference: ref,
      customerName: _customerName.trim(),
      customerPhone: _customerPhone.trim(),
      deliveryAddress: _deliveryAddress.trim(),
      area: _selectedArea,
      orderType: _orderType,
      paymentMethod: _paymentMethod,
      notes: _orderNotes.trim(),
      latitude: _latitude,
      longitude: _longitude,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: _discount,
      totalAmount: finalTotal,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      items: orderItems,
    );
  }
}
