class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;
  final int displayOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon = 'local_pizza',
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      icon: json['icon'] ?? 'local_pizza',
      displayOrder: json['displayOrder'] is int ? json['displayOrder'] : 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'icon': icon,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }
}
