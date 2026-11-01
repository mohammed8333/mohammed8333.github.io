class RestaurantSettingsModel {
  String restaurantNameAr;
  String restaurantNameEn;
  String phone;
  String whatsApp;
  String addressAr;
  String addressEn;
  String googleMapsUrl;
  double latitude;
  double longitude;
  String openingHoursAr;
  String openingHoursEn;
  double defaultDeliveryFee;
  double minimumOrderValue;
  String announcementAr;
  String announcementEn;

  RestaurantSettingsModel({
    this.restaurantNameAr = "بيتزا أولاد الشيخ",
    this.restaurantNameEn = "Pizza Awlad Alsheikh",
    this.phone = "01112962692",
    this.whatsApp = "201112962692",
    this.addressAr = "امتداد شارع الوحدة، المنيرة، إمبابة، الجيزة، مصر",
    this.addressEn = "El-Wehda St Ext, El-Monira, Imbaba, Giza, Egypt",
    this.googleMapsUrl = "https://maps.app.goo.gl/Hi55NFkp5H8ZNDqV6",
    this.latitude = 30.0880921,
    this.longitude = 31.2103625,
    this.openingHoursAr = "24 ساعة يومياً (طوال أيام الأسبوع)",
    this.openingHoursEn = "24 Hours Daily",
    this.defaultDeliveryFee = 20.0,
    this.minimumOrderValue = 50.0,
    this.announcementAr = "أهلاً بكم في بيتزا أولاد الشيخ بإمبابة! خدمة التوصيل متوفرة 24 ساعة يومياً. (الأسعار في التطبيق عينات تتطلب اعتماد الإدارة)",
    this.announcementEn = "Welcome to Pizza Awlad Alsheikh! 24/7 Delivery & Takeaway. Sample menu records require admin verification.",
  });

  factory RestaurantSettingsModel.fromMap(Map<String, String> map) {
    return RestaurantSettingsModel(
      restaurantNameAr: map['RestaurantNameAr'] ?? "بيتزا أولاد الشيخ",
      restaurantNameEn: map['RestaurantNameEn'] ?? "Pizza Awlad Alsheikh",
      phone: map['Phone'] ?? "01112962692",
      whatsApp: map['WhatsApp'] ?? "201112962692",
      addressAr: map['AddressAr'] ?? "امتداد شارع الوحدة، المنيرة، إمبابة، الجيزة، مصر",
      addressEn: map['AddressEn'] ?? "El-Wehda St Ext, El-Monira, Imbaba, Giza, Egypt",
      googleMapsUrl: map['GoogleMapsUrl'] ?? "https://maps.app.goo.gl/Hi55NFkp5H8ZNDqV6",
      latitude: double.tryParse(map['Latitude'] ?? '') ?? 30.0880921,
      longitude: double.tryParse(map['Longitude'] ?? '') ?? 31.2103625,
      openingHoursAr: map['OpeningHoursAr'] ?? "24 ساعة يومياً",
      openingHoursEn: map['OpeningHoursEn'] ?? "24 Hours Daily",
      defaultDeliveryFee: double.tryParse(map['DeliveryFeeDefault'] ?? '') ?? 20.0,
      minimumOrderValue: double.tryParse(map['MinimumOrderValue'] ?? '') ?? 50.0,
      announcementAr: map['AnnouncementAr'] ?? "",
      announcementEn: map['AnnouncementEn'] ?? "",
    );
  }
}
