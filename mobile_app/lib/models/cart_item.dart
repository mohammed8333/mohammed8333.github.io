import 'product.dart';
import 'product_size.dart';

class CartItem {
  final String id;
  final ProductModel product;
  ProductSizeModel? selectedSize;
  List<ProductExtraModel> selectedExtras;
  int quantity;
  String notes;

  CartItem({
    required this.id,
    required this.product,
    this.selectedSize,
    List<ProductExtraModel>? selectedExtras,
    this.quantity = 1,
    this.notes = '',
  }) : selectedExtras = selectedExtras ?? [];

  /// Calculate unit price dynamically based on selected size + selected extras
  double get unitPrice {
    double price = selectedSize?.price ?? product.basePrice;
    for (final extra in selectedExtras) {
      price += extra.price;
    }
    return price;
  }

  /// Dynamic Total Price for this item
  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': product.id,
      'product': product.toJson(),
      'selectedSize': selectedSize?.toJson(),
      'selectedExtras': selectedExtras.map((e) => e.toJson()).toList(),
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      selectedSize: json['selectedSize'] != null
          ? ProductSizeModel.fromJson(json['selectedSize'] as Map<String, dynamic>)
          : null,
      selectedExtras: (json['selectedExtras'] as List? ?? [])
          .map((e) => ProductExtraModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] ?? '',
    );
  }
}
