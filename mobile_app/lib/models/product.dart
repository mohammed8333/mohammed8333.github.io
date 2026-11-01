import 'product_size.dart';

class ProductModel {
  final String id;
  final String categoryId;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imageUrl;
  final double basePrice;
  final bool isAvailable;
  final bool isSampleRequiringAdminConfirmation;
  final String preparationNotes;
  final bool isFeatured;
  final bool isBestSeller;
  final List<ProductSizeModel> sizes;
  final List<ProductExtraModel> extras;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.imageUrl = '',
    required this.basePrice,
    this.isAvailable = true,
    this.isSampleRequiringAdminConfirmation = true,
    this.preparationNotes = '',
    this.isFeatured = false,
    this.isBestSeller = false,
    this.sizes = const [],
    this.extras = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var rawSizes = json['sizes'] as List? ?? [];
    var rawExtras = json['extras'] as List? ?? [];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
      isSampleRequiringAdminConfirmation: json['isSampleRequiringAdminConfirmation'] ?? true,
      preparationNotes: json['preparationNotes'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      isBestSeller: json['isBestSeller'] ?? false,
      sizes: rawSizes.map((s) => ProductSizeModel.fromJson(s as Map<String, dynamic>)).toList(),
      extras: rawExtras.map((e) => ProductExtraModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'basePrice': basePrice,
      'isAvailable': isAvailable,
      'isSampleRequiringAdminConfirmation': isSampleRequiringAdminConfirmation,
      'preparationNotes': preparationNotes,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
      'sizes': sizes.map((s) => s.toJson()).toList(),
      'extras': extras.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper to get default size or fallback to base price
  ProductSizeModel? get defaultSize {
    if (sizes.isEmpty) return null;
    return sizes.firstWhere((s) => s.isDefault, orElse: () => sizes.first);
  }

  double get displayPrice {
    if (sizes.isNotEmpty) {
      return defaultSize?.price ?? basePrice;
    }
    return basePrice;
  }
}
