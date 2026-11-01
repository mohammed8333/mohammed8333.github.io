class AppConstants {
  // Restaurant Information
  static const String restaurantNameAr = "بيتزا أولاد الشيخ";
  static const String restaurantNameEn = "Pizza Awlad Alsheikh";
  static const String taglineAr = "أشهى بيتزا شرقية وإيطالية وفطير مشلتت في إمبابة";
  static const String taglineEn = "Authentic Egyptian & Italian Pizza & Pies in Imbaba";

  static const String phone = "01112962692";
  static const String phoneInternational = "+201112962692";
  static const String whatsAppNumber = "201112962692"; // Digits only for wa.me

  static const String addressAr = "امتداد شارع الوحدة، المنيرة، إمبابة، الجيزة، مصر";
  static const String addressEn = "El-Wehda St Ext, El-Monira, Imbaba, Giza, Egypt";

  static const String googleMapsUrl = "https://maps.app.goo.gl/Hi55NFkp5H8ZNDqV6";
  static const double latitude = 30.0880921;
  static const double longitude = 31.2103625;

  static const double googleRating = 3.9;
  static const int reviewCount = 235;

  static const String openingHoursAr = "مفتوح 24 ساعة يومياً (طوال أيام الأسبوع)";
  static const String openingHoursEn = "Open 24/7 Daily";

  // Financial & Operational Defaults
  static const String currencyAr = "جنيه";
  static const String currencyEn = "EGP";
  static const double defaultDeliveryFee = 20.0;
  static const double defaultMinOrder = 50.0;

  // Supported Delivery Areas
  static const List<String> deliveryAreas = [
    "امتداد شارع الوحدة",
    "المنيرة الغربية / الشرقية",
    "إمبابة (وسط البلد)",
    "الوراق",
    "بشتيل",
    "مطار إمبابة",
    "تاج الدول",
    "مدينة الأمل",
    "الكيت كات",
    "المهندسين",
    "العجوزة",
    "أرض اللواء",
    "منطقة أخرى (سيتم تحديد رسوم التوصيل)"
  ];

  // Disclaimers required by specification
  static const String unverifiedSampleDisclaimer =
      "تنبيه: جميع الأسعار والأحجام المعروضة حالياً هي عينات تجريبية قابلة للتعديل وتتطلب اعتماد إدارة المطعم.";

  static const String unverifiedSampleDisclaimerEn =
      "Notice: All prices and sizes displayed are sample records requiring admin confirmation.";

  static const String whatsAppPendingDisclaimer =
      "تنبيه هام: فتح تطبيق واتساب لا يعني قبول الطلب تلقائياً، يعتبر الطلب قيد الانتظار حتى يقوم موظف المطعم بالرد وتأكيد الاستلام ووقت التجهيز والتوصيل.";

  static const String whatsAppPendingDisclaimerEn =
      "Important Notice: Opening WhatsApp does not mean the restaurant has accepted the order. The order remains pending confirmation until the restaurant responds.";

  // API Configuration (configurable via settings or environment)
  static const String defaultApiUrl = "http://localhost:5000/api";
  static const String androidEmulatorApiUrl = "http://10.0.2.2:5000/api";
}
