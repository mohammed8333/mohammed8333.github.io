class ProductSizeModel {
  final String id;
  final String productId;
  final String nameAr;
  final String nameEn;
  final double price;
  final bool isDefault;

  ProductSizeModel({
    required this.id,
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.isDefault = false,
  });

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'price': price,
      'isDefault': isDefault,
    };
  }
}

class ProductExtraModel {
  final String id;
  final String productId;
  final String nameAr;
  final String nameEn;
  final double price;
  final bool isAvailable;

  ProductExtraModel({
    required this.id,
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.isAvailable = true,
  });

  factory ProductExtraModel.fromJson(Map<String, dynamic> json) {
    return ProductExtraModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}
