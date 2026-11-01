enum OrderType { delivery, takeaway }

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled
}

class OrderItemExtraModel {
  final String extraNameAr;
  final double extraPrice;

  OrderItemExtraModel({
    required this.extraNameAr,
    required this.extraPrice,
  });

  Map<String, dynamic> toJson() => {
        'extraNameAr': extraNameAr,
        'extraPrice': extraPrice,
      };

  factory OrderItemExtraModel.fromJson(Map<String, dynamic> json) =>
      OrderItemExtraModel(
        extraNameAr: json['extraNameAr'] ?? '',
        extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0.0,
      );
}

class OrderItemModel {
  final String? productId;
  final String productNameAr;
  final String productNameEn;
  final String selectedSizeNameAr;
  final double selectedSizePrice;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String notes;
  final List<OrderItemExtraModel> extras;

  OrderItemModel({
    this.productId,
    required this.productNameAr,
    this.productNameEn = '',
    this.selectedSizeNameAr = '',
    required this.selectedSizePrice,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes = '',
    this.extras = const [],
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productNameAr': productNameAr,
        'productNameEn': productNameEn,
        'selectedSizeNameAr': selectedSizeNameAr,
        'selectedSizePrice': selectedSizePrice,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'notes': notes,
        'extras': extras.map((e) => e.toJson()).toList(),
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId']?.toString(),
        productNameAr: json['productNameAr'] ?? '',
        productNameEn: json['productNameEn'] ?? '',
        selectedSizeNameAr: json['selectedSizeNameAr'] ?? '',
        selectedSizePrice: (json['selectedSizePrice'] as num?)?.toDouble() ?? 0.0,
        quantity: json['quantity'] as int? ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] ?? '',
        extras: (json['extras'] as List? ?? [])
            .map((e) => OrderItemExtraModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class OrderModel {
  final String id;
  final String orderReference;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String area;
  final OrderType orderType;
  final String paymentMethod;
  final String notes;
  final double? latitude;
  final double? longitude;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  OrderStatus status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderReference,
    required this.customerName,
    required this.customerPhone,
    this.deliveryAddress = '',
    this.area = '',
    required this.orderType,
    this.paymentMethod = 'الدفع عند الاستلام',
    this.notes = '',
    this.latitude,
    this.longitude,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0.0,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.createdAt,
    required this.items,
  });

  String get statusArabic {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار (في انتظار تأكيد واتساب)';
      case OrderStatus.confirmed:
        return 'مؤكد من المطعم';
      case OrderStatus.preparing:
        return 'جاري التجهيز في المطبخ';
      case OrderStatus.outForDelivery:
        return 'في الطريق مع الدليفري';
      case OrderStatus.delivered:
        return 'تم التسليم بنجاح';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderReference': orderReference,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'deliveryAddress': deliveryAddress,
        'area': area,
        'orderType': orderType == OrderType.delivery ? 1 : 2,
        'paymentMethod': paymentMethod,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'totalAmount': totalAmount,
        'status': status.index + 1,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    int rawType = json['orderType'] is int ? json['orderType'] : 1;
    int rawStatus = json['status'] is int ? json['status'] : 1;

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderReference: json['orderReference'] ?? '#ORD-1001',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      area: json['area'] ?? '',
      orderType: rawType == 2 ? OrderType.takeaway : OrderType.delivery,
      paymentMethod: json['paymentMethod'] ?? 'الدفع عند الاستلام',
      notes: json['notes'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values[
          (rawStatus - 1).clamp(0, OrderStatus.values.length - 1)],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
