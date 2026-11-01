// بيانات مطعم بيتزا أولاد الشيخ (Pizza Awlad Alsheikh)
// فرع إمبابة، المنيرة - الجيزة

const DEFAULT_SETTINGS = {
  restaurantNameAr: "بيتزا أولاد الشيخ",
  restaurantNameEn: "Pizza Awlad Alsheikh",
  phone: "01112962692",
  phoneDisplay: "01112962692",
  whatsApp: "201112962692", // الرقم الدولي الصحيح
  addressAr: "امتداد شارع الوحدة، المنيرة، إمبابة، الجيزة، مصر",
  addressEn: "El-Wehda St Ext, El-Monira, Imbaba, Giza, Egypt",
  latitude: 30.0880921,
  longitude: 31.2103625,
  googleMapsUrl: "https://maps.app.goo.gl/Hi55NFkp5H8ZNDqV6",
  googleRating: 3.9,
  reviewsCount: 235,
  openingHoursAr: "24 ساعة يومياً (طوال أيام الأسبوع)",
  openingHoursEn: "Open 24/7 Daily",
  defaultDeliveryFee: 20.0,
  minimumOrderValue: 50.0,
  announcementAr: "أهلاً بكم في بيتزا أولاد الشيخ بإمبابة! خدمة التوصيل متوفرة 24 ساعة يومياً 🍕 (الأسعار في التطبيق عينات تجريبية تتطلب اعتماد الإدارة)",
  announcementEn: "Welcome to Pizza Awlad Alsheikh! 24/7 Delivery & Takeaway. Sample menu records require admin verification."
};

const DELIVERY_AREAS = [
  "امتداد شارع الوحدة",
  "المنيرة الغربية",
  "المنيرة الشرقية",
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

const DEFAULT_CATEGORIES = [
  { id: "cat-1", nameAr: "بيتزا (إيطالي وشرقي)", nameEn: "Pizza (Italian & Eastern)", icon: "fa-pizza-slice" },
  { id: "cat-2", nameAr: "كريب", nameEn: "Crepes", icon: "fa-bread-slice" },
  { id: "cat-3", nameAr: "برجر", nameEn: "Burgers", icon: "fa-burger" },
  { id: "cat-4", nameAr: "سندوتشات", nameEn: "Sandwiches", icon: "fa-hotdog" },
  { id: "cat-5", nameAr: "فطير مشلتت وحلو وحادق", nameEn: "Feteer (Sweet & Savory)", icon: "fa-pie-chart" },
  { id: "cat-6", nameAr: "حواوشي", nameEn: "Hawawshi", icon: "fa-drumstick-bite" },
  { id: "cat-7", nameAr: "إضافات ومشروبات", nameEn: "Extras & Drinks", icon: "fa-bottle-water" }
];

// قائمة العروض والخصومات الافتراضية
const DEFAULT_OFFERS = [
  {
    id: "off-1",
    titleAr: "عرض الصحاب (2 بيتزا لارج + لتر بيبسي)",
    titleEn: "Friends Deal (2 Large Pizzas + 1L Pepsi)",
    descriptionAr: "أي 2 بيتزا حجم كبير (سوبريم، مكس جبن، سجق، فراخ باربيكيو) مع لتر بيبسي بارد وبطاطس مقرمشة مجاناً.",
    descriptionEn: "Any 2 Large Pizzas of your choice + 1L Pepsi & French fries.",
    imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800",
    badge: "وفر 25%",
    originalPrice: 350.0,
    offerPrice: 265.0,
    isActive: true,
    isSample: true, // تتطلب تأكيد الإدارة
    expiryDate: "2026-12-31"
  },
  {
    id: "off-2",
    titleAr: "كومبو الكريب العملاق (2 كريب كرانشي + كانز)",
    titleEn: "Giant Crepe Combo (2 Crispy Crepes + Can)",
    descriptionAr: "2 كريب سوبر كرانشي محشو بقطع صدور الدجاج المقرمشة ومكس جبن غني وصوصات رانش وباربيكيو + 2 كانز.",
    descriptionEn: "2 Super crispy chicken crepes with mixed cheese & sauces + 2 cans.",
    imageUrl: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800",
    badge: "عرض التوفير",
    originalPrice: 210.0,
    offerPrice: 155.0,
    isActive: true,
    isSample: true,
    expiryDate: "2026-12-31"
  },
  {
    id: "off-3",
    titleAr: "سهرة الفطير (2 فطير شرقي كبير + فطيرة حلو هدية)",
    titleEn: "Feteer Feast (2 Large Savory + 1 Sweet Free)",
    descriptionAr: "فطيرتين شرقي حجم عائلي بالسمن البلدي (سجق بلدي أو مكس أجبان) واحصل على فطيرة كاسترد وسكر ومكسرات مجاناً.",
    descriptionEn: "2 Family savory eastern feteers with local ghee + free sweet custard feteer.",
    imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800",
    badge: "الحلو هدية",
    originalPrice: 390.0,
    offerPrice: 299.0,
    isActive: true,
    isSample: true,
    expiryDate: "2026-12-31"
  },
  {
    id: "off-4",
    titleAr: "وليمة الحواوشي على الفحم (4 حواوشي بلدي مخصوص)",
    titleEn: "Grilled Hawawshi Feast (4 Special Hawawshi)",
    descriptionAr: "4 أرغفة حواوشي لحمة بلدي متبلة مع مكس جبن موتزاريلا مشوية على الفحم + سلطة طحينة ومخلل بلدي.",
    descriptionEn: "4 Charcoal grilled baladi hawawshi with cheese + tahini and pickles.",
    imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800",
    badge: "خصم 20%",
    originalPrice: 220.0,
    offerPrice: 175.0,
    isActive: true,
    isSample: true,
    expiryDate: "2026-12-31"
  }
];

// أكواد الخصم الترويجية (Discount Coupons)
const DEFAULT_COUPONS = [
  { code: "SHEIKH10", discountType: "percent", value: 10, minOrder: 100, isActive: true },
  { code: "IMBABA20", discountType: "fixed", value: 20, minOrder: 150, isActive: true }
];

const DEFAULT_PRODUCTS = [
  // 1. PIZZAS
  {
    id: "p-1",
    categoryId: "cat-1",
    nameAr: "بيتزا سوبر سوبريم أولاد الشيخ",
    nameEn: "Awlad Alsheikh Super Supreme Pizza",
    descriptionAr: "خلطة أولاد الشيخ المميزة: لحم مفروم بلدي، سوسيس، سلامي، مشروم طازج، فلفل ألوان، زيتون، وجبنة موتزاريلا غنية.",
    descriptionEn: "Special blend: Minced beef, sausage, salami, fresh mushrooms, bell peppers, olives, and rich mozzarella.",
    imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80",
    basePrice: 130.0,
    isAvailable: true,
    isSample: true, // علامة عينة تجريبية تتطلب تأكيد الإدارة
    isFeatured: true,
    isBestSeller: true,
    sizes: [
      { id: "s-1", nameAr: "صغير (22 سم)", nameEn: "Small (22cm)", price: 95.0, isDefault: false },
      { id: "s-2", nameAr: "وسط (28 سم)", nameEn: "Medium (28cm)", price: 130.0, isDefault: true },
      { id: "s-3", nameAr: "كبير (34 سم)", nameEn: "Large (34cm)", price: 175.0, isDefault: false },
      { id: "s-4", nameAr: "عائلي (40 سم)", nameEn: "Family (40cm)", price: 220.0, isDefault: false }
    ],
    extras: [
      { id: "e-1", nameAr: "جبنة موتزاريلا إضافية", nameEn: "Extra Mozzarella", price: 25.0 },
      { id: "e-2", nameAr: "أطراف محشوة جبنة (ستافد كرست)", nameEn: "Stuffed Crust", price: 30.0 },
      { id: "e-3", nameAr: "مشروم طازج إضافي", nameEn: "Extra Mushrooms", price: 20.0 },
      { id: "e-4", nameAr: "صوص رانش جانبي", nameEn: "Ranch Dip", price: 15.0 }
    ]
  },
  {
    id: "p-2",
    categoryId: "cat-1",
    nameAr: "بيتزا مشكل جبن شرقي",
    nameEn: "Eastern Mixed Cheese Pizza",
    descriptionAr: "مكس أجبان فاخر (موتزاريلا، كيري، رومي، شيدر) مع طماطم وفلفل وزيتون، على العجينة الشرقية المورقة المقرمشة بالسمن البلدي.",
    descriptionEn: "Four cheese blend (mozzarella, kiri, roumi, cheddar) with tomatoes, peppers, and olives on flaky eastern crust.",
    imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&q=80",
    basePrice: 110.0,
    isAvailable: true,
    isSample: true,
    isFeatured: true,
    isBestSeller: true,
    sizes: [
      { id: "s-5", nameAr: "وسط (28 سم)", nameEn: "Medium (28cm)", price: 110.0, isDefault: true },
      { id: "s-6", nameAr: "كبير (34 سم)", nameEn: "Large (34cm)", price: 150.0, isDefault: false },
      { id: "s-7", nameAr: "عائلي (40 سم)", nameEn: "Family (40cm)", price: 195.0, isDefault: false }
    ],
    extras: [
      { id: "e-5", nameAr: "إضافة بسطرمة بلدي", nameEn: "Add Pastrami", price: 30.0 },
      { id: "e-6", nameAr: "جبنة كيري زيادة", nameEn: "Extra Kiri", price: 20.0 }
    ]
  },
  {
    id: "p-3",
    categoryId: "cat-1",
    nameAr: "بيتزا سجق إسكندراني شرقي",
    nameEn: "Alexandrian Sausage Eastern Pizza",
    descriptionAr: "سجق بلدي متبل بالخلطة الإسكندرانية الأصلية، فلفل حار، طماطم، بصل، وجبنة موتزاريلا ورومي ذائبة.",
    descriptionEn: "Spicy Alexandrian sausage, hot green chili, tomatoes, onions, melted mozzarella & roumi cheese.",
    imageUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80",
    basePrice: 125.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: true,
    sizes: [
      { id: "s-8", nameAr: "وسط", nameEn: "Medium", price: 125.0, isDefault: true },
      { id: "s-9", nameAr: "كبير", nameEn: "Large", price: 165.0, isDefault: false },
      { id: "s-10", nameAr: "عائلي", nameEn: "Family", price: 210.0, isDefault: false }
    ],
    extras: [
      { id: "e-7", nameAr: "سجق إضافي", nameEn: "Extra Sausage", price: 25.0 },
      { id: "e-8", nameAr: "فلفل هالبينو حار", nameEn: "Jalapenos", price: 10.0 }
    ]
  },
  {
    id: "p-4",
    categoryId: "cat-1",
    nameAr: "بيتزا باربيكيو تشيكن",
    nameEn: "BBQ Chicken Pizza",
    descriptionAr: "قطع دجاج متبلة مشوية، بصل أحمر مكرمل، صوص باربيكيو مدخن، جبنة موتزاريلا وبقدونس طازج.",
    descriptionEn: "Grilled marinated chicken, red onion, smoked BBQ sauce, mozzarella, and fresh parsley.",
    imageUrl: "https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=800&q=80",
    basePrice: 135.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: false,
    sizes: [
      { id: "s-11", nameAr: "وسط", nameEn: "Medium", price: 135.0, isDefault: true },
      { id: "s-12", nameAr: "كبير", nameEn: "Large", price: 180.0, isDefault: false }
    ],
    extras: [
      { id: "e-9", nameAr: "صوص باربيكيو زيادة", nameEn: "Extra BBQ Sauce", price: 10.0 }
    ]
  },

  // 2. CREPES
  {
    id: "p-5",
    categoryId: "cat-2",
    nameAr: "كريب كرانشي سوبر زنجر",
    nameEn: "Crunchy Super Zinger Crepe",
    descriptionAr: "قطع دجاج كرسبي مقرمش، بطاطس فارم فريتس، صوص جبنة شيدر سائل، موتزاريلا سايحة، مايونيز، وكاتشب.",
    descriptionEn: "Crispy spicy chicken strips, french fries, melted cheddar cheese sauce, mozzarella, mayo & ketchup.",
    imageUrl: "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=800&q=80",
    basePrice: 85.0,
    isAvailable: true,
    isSample: true,
    isFeatured: true,
    isBestSeller: true,
    sizes: [
      { id: "s-13", nameAr: "حجم عادي", nameEn: "Regular", price: 85.0, isDefault: true },
      { id: "s-14", nameAr: "حجم جامبو (صاروخ)", nameEn: "Jumbo", price: 115.0, isDefault: false }
    ],
    extras: [
      { id: "e-10", nameAr: "إضافة استربس كرانشي", nameEn: "Extra Strips", price: 20.0 },
      { id: "e-11", nameAr: "صوص جبنة شيدر سائل", nameEn: "Cheddar Sauce", price: 15.0 },
      { id: "e-12", nameAr: "موتزاريلا زيادة", nameEn: "Extra Mozzarella", price: 15.0 }
    ]
  },
  {
    id: "p-6",
    categoryId: "cat-2",
    nameAr: "كريب شاورما فراخ وموتزاريلا",
    nameEn: "Chicken Shawarma & Mozzarella Crepe",
    descriptionAr: "شاورما دجاج متبلة بالبهارات الخاصة مع فلفل ألوان، طماطم، خيار مخلل، تومية وموتزاريلا غنية.",
    descriptionEn: "Seasoned chicken shawarma with bell peppers, tomatoes, pickles, garlic sauce, and melted mozzarella.",
    imageUrl: "https://images.unsplash.com/photo-1529042410759-befb1204b468?w=800&q=80",
    basePrice: 80.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: false,
    sizes: [
      { id: "s-15", nameAr: "حجم عادي", nameEn: "Regular", price: 80.0, isDefault: true },
      { id: "s-16", nameAr: "حجم جامبو", nameEn: "Jumbo", price: 110.0, isDefault: false }
    ],
    extras: [
      { id: "e-13", nameAr: "صوص ثومية إضافي", nameEn: "Extra Garlic Dip", price: 10.0 }
    ]
  },
  {
    id: "p-7",
    categoryId: "cat-2",
    nameAr: "كريب شوكولاتة نوتيلا وموز ومكسرات",
    nameEn: "Nutella Banana & Nuts Crepe",
    descriptionAr: "كريب حلو غني بشوكولاتة النوتيلا الأصلية، شرائح موز طازجة، ومكسرات كاجو وبندق مجروش مع صوص كراميل.",
    descriptionEn: "Sweet crepe with authentic Nutella, fresh banana, chopped nuts and caramel drizzle.",
    imageUrl: "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=800&q=80",
    basePrice: 65.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: true,
    sizes: [
      { id: "s-17", nameAr: "حجم عادي", nameEn: "Regular", price: 65.0, isDefault: true },
      { id: "s-18", nameAr: "حجم دبل", nameEn: "Double", price: 90.0, isDefault: false }
    ],
    extras: [
      { id: "e-14", nameAr: "نوتيلا زيادة", nameEn: "Extra Nutella", price: 20.0 }
    ]
  },

  // 3. BURGERS
  {
    id: "p-8",
    categoryId: "cat-3",
    nameAr: "برجر أولاد الشيخ دبل تشيز بيف",
    nameEn: "Awlad Alsheikh Double Cheese Beef Burger",
    descriptionAr: "قطعتين لحم بقرى مشوي على اللهب (200 جرام)، جبنة شيدر أمريكية ذائبة، خس، طماطم، خيار مخلل، وصوص خاص.",
    descriptionEn: "Two flame-grilled beef patties (200g), double cheddar, lettuce, tomatoes, pickles, and house sauce.",
    imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80",
    basePrice: 90.0,
    isAvailable: true,
    isSample: true,
    isFeatured: true,
    isBestSeller: true,
    sizes: [
      { id: "s-19", nameAr: "سنجل (100 جرام)", nameEn: "Single", price: 65.0, isDefault: false },
      { id: "s-20", nameAr: "دبل (200 جرام)", nameEn: "Double", price: 90.0, isDefault: true },
      { id: "s-21", nameAr: "تربل عملاق (300 جرام)", nameEn: "Triple", price: 120.0, isDefault: false }
    ],
    extras: [
      { id: "e-15", nameAr: "شريحة بيكون بقري مدخن", nameEn: "Beef Bacon", price: 20.0 },
      { id: "e-16", nameAr: "كومبو (بطاطس مقلية + كانز)", nameEn: "Fries & Drink Combo", price: 30.0 }
    ]
  },

  // 4. SANDWICHES
  {
    id: "p-9",
    categoryId: "cat-4",
    nameAr: "ساندوتش فاهيتا دجاج مكسيكي",
    nameEn: "Mexican Chicken Fajita Sandwich",
    descriptionAr: "شرائح صدور دجاج مشوية مع فلفل ألوان وبصل وتوابل الفاهيتا المكسيكية الحارة، في خبز سوري أو فينو طازج مع المايونيز والجبنة.",
    descriptionEn: "Grilled chicken breast with bell peppers, onions, Mexican fajita spices, mayo and cheese.",
    imageUrl: "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800&q=80",
    basePrice: 60.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: false,
    sizes: [
      { id: "s-22", nameAr: "خبز فينو كبير", nameEn: "Large Baguette", price: 60.0, isDefault: true },
      { id: "s-23", nameAr: "خبز سوري سوبر", nameEn: "Syrian Roll Super", price: 75.0, isDefault: false }
    ],
    extras: [
      { id: "e-17", nameAr: "جبنة موتزاريلا سايحة", nameEn: "Melted Mozzarella", price: 15.0 }
    ]
  },

  // 5. FETEER
  {
    id: "p-10",
    categoryId: "cat-5",
    nameAr: "فطير مشلتت فلاحي بالسمن البلدي",
    nameEn: "Traditional Egyptian Meshaltet Feteer",
    descriptionAr: "فطير مشلتت مورق وخفيف مخبوز على أصوله بالسمن البلدي الطبيعي، يقدم ساخناً مع العسل الأسود والطحينة أو الجبنة القديمة.",
    descriptionEn: "Flaky layered authentic Egyptian meshaltet baked with pure ghee, served hot with molasses or cheese.",
    imageUrl: "https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=800&q=80",
    basePrice: 90.0,
    isAvailable: true,
    isSample: true,
    isFeatured: true,
    isBestSeller: true,
    sizes: [
      { id: "s-24", nameAr: "وسط (تكفي 2-3 أفراد)", nameEn: "Medium (Serves 2-3)", price: 90.0, isDefault: true },
      { id: "s-25", nameAr: "كبير عائلي (تكفي 4-6 أفراد)", nameEn: "Large Family (Serves 4-6)", price: 140.0, isDefault: false }
    ],
    extras: [
      { id: "e-18", nameAr: "طبق عسل أسود وطحينة", nameEn: "Molasses & Tahini", price: 15.0 },
      { id: "e-19", nameAr: "طبق جبنة قديمة بالطماطم", nameEn: "Aged Cheese", price: 15.0 },
      { id: "e-20", nameAr: "طبق عسل أبيض وقشطة بلدي", nameEn: "Honey & Cream", price: 25.0 }
    ]
  },
  {
    id: "p-11",
    categoryId: "cat-5",
    nameAr: "فطير حلو كاسترد وبودرة وسكر وقشطة",
    nameEn: "Sweet Custard & Powder Sugar Feteer",
    descriptionAr: "فطير حلو مورق محشو بالكاسترد اللذيذ ومغطى بالسكر البودرة واللبن الساخن والمكسرات والقشطة.",
    descriptionEn: "Sweet feteer filled with custard, dusted with powdered sugar, warm milk, nuts and cream.",
    imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80",
    basePrice: 75.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: false,
    sizes: [
      { id: "s-26", nameAr: "وسط", nameEn: "Medium", price: 75.0, isDefault: true },
      { id: "s-27", nameAr: "كبير", nameEn: "Large", price: 110.0, isDefault: false }
    ],
    extras: [
      { id: "e-21", nameAr: "قشطة بلدي إضافية", nameEn: "Extra Cream", price: 20.0 }
    ]
  },

  // 6. HAWAWSHI
  {
    id: "p-12",
    categoryId: "cat-6",
    nameAr: "حواوشي إسكندراني مخصوص بالجبنة",
    nameEn: "Special Alexandrian Cheesy Hawawshi",
    descriptionAr: "عجين طازج محشو باللحم البلدي المفروم المتبل بخلطة أولاد الشيخ السرية، مكس جبنة موتزاريلا ورومي، وفلفل حار مخبوز حتى القرمشة الذهبية.",
    descriptionEn: "Freshly baked dough stuffed with spiced minced beef, mozzarella & roumi cheese, baked golden crisp.",
    imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80",
    basePrice: 55.0,
    isAvailable: true,
    isSample: true,
    isFeatured: true,
    isBestSeller: true,
    sizes: [
      { id: "s-28", nameAr: "رغيف واحد عادي", nameEn: "Single Loaf", price: 55.0, isDefault: true },
      { id: "s-29", nameAr: "رغيف دبل لحمة وجبنة", nameEn: "Double Meat & Cheese", price: 80.0, isDefault: false }
    ],
    extras: [
      { id: "e-22", nameAr: "جبنة موتزاريلا على الوش (وش بيتزا)", nameEn: "Pizza Style Topping", price: 20.0 },
      { id: "e-23", nameAr: "سلطة طحينة ومخلل بلدي", nameEn: "Tahini & Pickles", price: 10.0 }
    ]
  },
  {
    id: "p-13",
    categoryId: "cat-6",
    nameAr: "حواوشي سجق بلدي وموتزاريلا",
    nameEn: "Baladi Sausage & Mozzarella Hawawshi",
    descriptionAr: "رغيف عجين حواوشي محشو بالسجق البلدي المتبل والجبنة الموتزاريلا السايحة والفلفل الرومي والحار.",
    descriptionEn: "Crispy dough stuffed with spiced oriental sausage, melted mozzarella, and green peppers.",
    imageUrl: "https://images.unsplash.com/photo-1603064752734-4c48eff53d05?w=800&q=80",
    basePrice: 60.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: false,
    sizes: [
      { id: "s-30", nameAr: "رغيف عادي", nameEn: "Single", price: 60.0, isDefault: true },
      { id: "s-31", nameAr: "رغيف سوبر بالجبن", nameEn: "Super Cheesy", price: 85.0, isDefault: false }
    ],
    extras: [
      { id: "e-24", nameAr: "صوص حار سبايسي", nameEn: "Spicy Dip", price: 10.0 }
    ]
  },

  // 7. EXTRAS & DRINKS
  {
    id: "p-14",
    categoryId: "cat-7",
    nameAr: "بطاطس محمرة مع صوص الشيدر",
    nameEn: "French Fries with Cheddar Sauce",
    descriptionAr: "أصابع بطاطس ذهبية مقرمشة مبهرة ومغمورة بصوص الجبنة الشيدر الأمريكي الساخن.",
    descriptionEn: "Golden french fries with warm melted cheddar sauce.",
    imageUrl: "https://images.unsplash.com/photo-1576107232684-1279f3908594?w=800&q=80",
    basePrice: 35.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: false,
    sizes: [
      { id: "s-32", nameAr: "طبق عادي", nameEn: "Regular Plate", price: 35.0, isDefault: true },
      { id: "s-33", nameAr: "طبق كبير لارج", nameEn: "Large Plate", price: 50.0, isDefault: false }
    ],
    extras: [
      { id: "e-25", nameAr: "صوص رانش إضافي", nameEn: "Extra Ranch", price: 10.0 }
    ]
  },
  {
    id: "p-15",
    categoryId: "cat-7",
    nameAr: "مشروبات غازية كانز 330 مل",
    nameEn: "Soft Drinks Can 330ml",
    descriptionAr: "كانز بارد مثلج (بيبسي، سفن آب، ميرندا، كوكاكولا، سبرايت).",
    descriptionEn: "Ice cold soda can (Pepsi, 7Up, Mirinda, Coca Cola, Sprite).",
    imageUrl: "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80",
    basePrice: 18.0,
    isAvailable: true,
    isSample: true,
    isFeatured: false,
    isBestSeller: false,
    sizes: [
      { id: "s-34", nameAr: "كانز 330 مل", nameEn: "Can 330ml", price: 18.0, isDefault: true },
      { id: "s-35", nameAr: "لتر عائلي", nameEn: "Family 1L", price: 30.0, isDefault: false }
    ],
    extras: []
  }
];
