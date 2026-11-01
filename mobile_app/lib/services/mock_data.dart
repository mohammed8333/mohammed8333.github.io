import '../models/category.dart';
import '../models/product.dart';
import '../models/product_size.dart';

class MockData {
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        id: 'cat-1',
        nameAr: 'بيتزا (إيطالي وشرقي)',
        nameEn: 'Pizza (Italian & Eastern)',
        icon: 'local_pizza',
        displayOrder: 1,
      ),
      CategoryModel(
        id: 'cat-2',
        nameAr: 'كريب',
        nameEn: 'Crepes',
        icon: 'lunch_dining',
        displayOrder: 2,
      ),
      CategoryModel(
        id: 'cat-3',
        nameAr: 'برجر',
        nameEn: 'Burgers',
        icon: 'fastfood',
        displayOrder: 3,
      ),
      CategoryModel(
        id: 'cat-4',
        nameAr: 'سندوتشات',
        nameEn: 'Sandwiches',
        icon: 'dinner_dining',
        displayOrder: 4,
      ),
      CategoryModel(
        id: 'cat-5',
        nameAr: 'فطير مشلتت وحلو وحادق',
        nameEn: 'Feteer (Sweet & Savory)',
        icon: 'pie_menu',
        displayOrder: 5,
      ),
      CategoryModel(
        id: 'cat-6',
        nameAr: 'حواوشي',
        nameEn: 'Hawawshi',
        icon: 'bakery_dining',
        displayOrder: 6,
      ),
      CategoryModel(
        id: 'cat-7',
        nameAr: 'إضافات ومشروبات',
        nameEn: 'Extras & Drinks',
        icon: 'local_drink',
        displayOrder: 7,
      ),
    ];
  }

  static List<ProductModel> getProducts() {
    return [
      // PIZZAS
      ProductModel(
        id: 'p-1',
        categoryId: 'cat-1',
        nameAr: 'بيتزا سوبر سوبريم أولاد الشيخ',
        nameEn: 'Awlad Alsheikh Super Supreme Pizza',
        descriptionAr: 'خلطة أولاد الشيخ المميزة: لحم مفروم، سوسيس، سلامي، مشروم طازج، فلفل ألوان، زيتون، وجبنة موتزاريلا غنية.',
        descriptionEn: 'Special blend: Minced beef, sausage, salami, fresh mushrooms, bell peppers, olives, and rich mozzarella.',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
        basePrice: 130.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        preparationNotes: 'تخبز طازجة في الفرن الحجري لمدة 15 دقيقة',
        isFeatured: true,
        isBestSeller: true,
        sizes: [
          ProductSizeModel(id: 's-1-1', productId: 'p-1', nameAr: 'صغير (22 سم)', nameEn: 'Small (22cm)', price: 95.0),
          ProductSizeModel(id: 's-1-2', productId: 'p-1', nameAr: 'وسط (28 سم)', nameEn: 'Medium (28cm)', price: 130.0, isDefault: true),
          ProductSizeModel(id: 's-1-3', productId: 'p-1', nameAr: 'كبير (34 سم)', nameEn: 'Large (34cm)', price: 175.0),
          ProductSizeModel(id: 's-1-4', productId: 'p-1', nameAr: 'عائلي (40 سم)', nameEn: 'Family (40cm)', price: 220.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-1-1', productId: 'p-1', nameAr: 'جبنة موتزاريلا إضافية', nameEn: 'Extra Mozzarella', price: 25.0),
          ProductExtraModel(id: 'e-1-2', productId: 'p-1', nameAr: 'أطراف محشوة جبنة (ستافد كرست)', nameEn: 'Stuffed Crust', price: 30.0),
          ProductExtraModel(id: 'e-1-3', productId: 'p-1', nameAr: 'مشروم طازج إضافي', nameEn: 'Extra Mushrooms', price: 20.0),
          ProductExtraModel(id: 'e-1-4', productId: 'p-1', nameAr: 'صوص رانش جانبي', nameEn: 'Ranch Sauce Dip', price: 15.0),
        ],
      ),
      ProductModel(
        id: 'p-2',
        categoryId: 'cat-1',
        nameAr: 'بيتزا مشكل جبن شرقي',
        nameEn: 'Eastern Mixed Cheese Pizza',
        descriptionAr: 'مكس أجبان فاخر (موتزاريلا، كيري، رومي، شيدر) مع طماطم وفلفل وزيتون، على العجينة الشرقية المورقة المقرمشة.',
        descriptionEn: 'Four cheese blend (mozzarella, kiri, roumi, cheddar) with tomatoes, peppers, and olives on flaky eastern crust.',
        imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&q=80',
        basePrice: 110.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        preparationNotes: 'عجينة شرقية مورقة بالسمن البلدي',
        isFeatured: true,
        isBestSeller: true,
        sizes: [
          ProductSizeModel(id: 's-2-1', productId: 'p-2', nameAr: 'وسط (28 سم)', nameEn: 'Medium (28cm)', price: 110.0, isDefault: true),
          ProductSizeModel(id: 's-2-2', productId: 'p-2', nameAr: 'كبير (34 سم)', nameEn: 'Large (34cm)', price: 150.0),
          ProductSizeModel(id: 's-2-3', productId: 'p-2', nameAr: 'عائلي (40 سم)', nameEn: 'Family (40cm)', price: 195.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-2-1', productId: 'p-2', nameAr: 'إضافة بسطرمة', nameEn: 'Add Pastrami', price: 30.0),
          ProductExtraModel(id: 'e-2-2', productId: 'p-2', nameAr: 'جبنة كيري زيادة', nameEn: 'Extra Kiri', price: 20.0),
        ],
      ),
      ProductModel(
        id: 'p-3',
        categoryId: 'cat-1',
        nameAr: 'بيتزا سجق إسكندراني شرقي',
        nameEn: 'Alexandrian Sausage Eastern Pizza',
        descriptionAr: 'سجق بلدي متبل بالخلطة الإسكندرانية الأصلية، فلفل حار، طماطم، بصل، وجبنة موتزاريلا ورومي ذائبة.',
        descriptionEn: 'Spicy Alexandrian sausage, hot green chili, tomatoes, onions, melted mozzarella & roumi cheese.',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
        basePrice: 125.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-3-1', productId: 'p-3', nameAr: 'وسط', nameEn: 'Medium', price: 125.0, isDefault: true),
          ProductSizeModel(id: 's-3-2', productId: 'p-3', nameAr: 'كبير', nameEn: 'Large', price: 165.0),
          ProductSizeModel(id: 's-3-3', productId: 'p-3', nameAr: 'عائلي', nameEn: 'Family', price: 210.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-3-1', productId: 'p-3', nameAr: 'سجق إضافي', nameEn: 'Extra Sausage', price: 25.0),
          ProductExtraModel(id: 'e-3-2', productId: 'p-3', nameAr: 'فلفل هالبينو حار', nameEn: 'Jalapenos', price: 10.0),
        ],
      ),
      ProductModel(
        id: 'p-4',
        categoryId: 'cat-1',
        nameAr: 'بيتزا باربيكيو تشيكن',
        nameEn: 'BBQ Chicken Pizza',
        descriptionAr: 'قطع دجاج متبلة مشوية، بصل أحمر مكرمل، صوص باربيكيو مدخن، جبنة موتزاريلا وبقدونس طازج.',
        descriptionEn: 'Grilled chicken strips, red onion, smoked BBQ sauce, mozzarella, and parsley.',
        imageUrl: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=800&q=80',
        basePrice: 135.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-4-1', productId: 'p-4', nameAr: 'وسط', nameEn: 'Medium', price: 135.0, isDefault: true),
          ProductSizeModel(id: 's-4-2', productId: 'p-4', nameAr: 'كبير', nameEn: 'Large', price: 180.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-4-1', productId: 'p-4', nameAr: 'صوص باربيكيو زيادة', nameEn: 'Extra BBQ Sauce', price: 10.0),
        ],
      ),

      // CREPES
      ProductModel(
        id: 'p-5',
        categoryId: 'cat-2',
        nameAr: 'كريب كرانشي سوبر زنجر',
        nameEn: 'Crunchy Super Zinger Crepe',
        descriptionAr: 'قطع دجاج كرسبي مقرمش، بطاطس مقلية، صوص جبنة شيدر، موتزاريلا سايحة، مايونيز، وكاتشب.',
        descriptionEn: 'Crispy spicy chicken strips, french fries, cheddar cheese sauce, mozzarella, mayo & ketchup.',
        imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=800&q=80',
        basePrice: 85.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        isFeatured: true,
        isBestSeller: true,
        sizes: [
          ProductSizeModel(id: 's-5-1', productId: 'p-5', nameAr: 'حجم عادي', nameEn: 'Regular', price: 85.0, isDefault: true),
          ProductSizeModel(id: 's-5-2', productId: 'p-5', nameAr: 'حجم جامبو (صاروخ)', nameEn: 'Jumbo', price: 115.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-5-1', productId: 'p-5', nameAr: 'إضافة استربس كرانشي', nameEn: 'Extra Strips', price: 20.0),
          ProductExtraModel(id: 'e-5-2', productId: 'p-5', nameAr: 'صوص جبنة شيدر سائل', nameEn: 'Cheddar Sauce', price: 15.0),
          ProductExtraModel(id: 'e-5-3', productId: 'p-5', nameAr: 'موتزاريلا زيادة', nameEn: 'Extra Mozzarella', price: 15.0),
        ],
      ),
      ProductModel(
        id: 'p-6',
        categoryId: 'cat-2',
        nameAr: 'كريب شاورما فراخ وموتزاريلا',
        nameEn: 'Chicken Shawarma & Mozzarella Crepe',
        descriptionAr: 'شاورما دجاج متبلة بالبهارات الخاصة مع فلفل ألوان، طماطم، مخلل، تومية وموتزاريلا غنية.',
        descriptionEn: 'Seasoned chicken shawarma with bell peppers, tomatoes, pickles, garlic sauce, and melted mozzarella.',
        imageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=800&q=80',
        basePrice: 80.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-6-1', productId: 'p-6', nameAr: 'حجم عادي', nameEn: 'Regular', price: 80.0, isDefault: true),
          ProductSizeModel(id: 's-6-2', productId: 'p-6', nameAr: 'حجم جامبو', nameEn: 'Jumbo', price: 110.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-6-1', productId: 'p-6', nameAr: 'صوص ثومية إضافي', nameEn: 'Extra Garlic Sauce', price: 10.0),
        ],
      ),
      ProductModel(
        id: 'p-7',
        categoryId: 'cat-2',
        nameAr: 'كريب شوكولاتة نوتيلا وموز ومكسرات',
        nameEn: 'Nutella Banana & Nuts Crepe',
        descriptionAr: 'كريب حلو غني بشوكولاتة النوتيلا الأصلية، شرائح موز طازجة، ومكسرات كاجو وبندق مجروش مع صوص كراميل.',
        descriptionEn: 'Sweet crepe with authentic Nutella, fresh banana, chopped nuts and caramel drizzle.',
        imageUrl: 'https://images.unsplash.com/photo-1519676867240-f03562e64548?w=800&q=80',
        basePrice: 65.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-7-1', productId: 'p-7', nameAr: 'حجم عادي', nameEn: 'Regular', price: 65.0, isDefault: true),
          ProductSizeModel(id: 's-7-2', productId: 'p-7', nameAr: 'حجم دبل', nameEn: 'Double', price: 90.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-7-1', productId: 'p-7', nameAr: 'نوتيلا زيادة', nameEn: 'Extra Nutella', price: 20.0),
        ],
      ),

      // BURGERS
      ProductModel(
        id: 'p-8',
        categoryId: 'cat-3',
        nameAr: 'برجر أولاد الشيخ دبل تشيز بيف',
        nameEn: 'Awlad Alsheikh Double Cheese Beef Burger',
        descriptionAr: 'قطعتين لحم بقرى مشوي على اللهب (200 جرام)، جبنة شيدر أمريكية ذائبة، خس، طماطم، خيار مخلل، وصوص خاص.',
        descriptionEn: 'Two flame-grilled beef patties (200g), double cheddar, lettuce, tomatoes, pickles, and house sauce.',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
        basePrice: 90.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        isFeatured: true,
        sizes: [
          ProductSizeModel(id: 's-8-1', productId: 'p-8', nameAr: 'سنجل (100 جرام)', nameEn: 'Single', price: 65.0),
          ProductSizeModel(id: 's-8-2', productId: 'p-8', nameAr: 'دبل (200 جرام)', nameEn: 'Double', price: 90.0, isDefault: true),
          ProductSizeModel(id: 's-8-3', productId: 'p-8', nameAr: 'تربل عملاق (300 جرام)', nameEn: 'Triple', price: 120.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-8-1', productId: 'p-8', nameAr: 'إضافة شريحة بيكون لحم مدخن', nameEn: 'Beef Bacon', price: 20.0),
          ProductExtraModel(id: 'e-8-2', productId: 'p-8', nameAr: 'كومبو (بطاطس مقلية + كانز)', nameEn: 'Combo Fries + Drink', price: 30.0),
        ],
      ),

      // SANDWICHES
      ProductModel(
        id: 'p-9',
        categoryId: 'cat-4',
        nameAr: 'ساندوتش فاهيتا دجاج ميكسيكي',
        nameEn: 'Mexican Chicken Fajita Sandwich',
        descriptionAr: 'شرائح صدور دجاج مشوية مع فلفل ألوان وبصل وتوابل الفاهيتا المكسيكية الحارة، في خبز سوري أو فينو طازج مع المايونيز والجبنة.',
        descriptionEn: 'Grilled chicken breast with bell peppers, onions, Mexican fajita spices, mayo and cheese.',
        imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800&q=80',
        basePrice: 60.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-9-1', productId: 'p-9', nameAr: 'خبز فينو كبير', nameEn: 'Large Baguette', price: 60.0, isDefault: true),
          ProductSizeModel(id: 's-9-2', productId: 'p-9', nameAr: 'خبز سوري سوبر', nameEn: 'Syrian Roll Super', price: 75.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-9-1', productId: 'p-9', nameAr: 'جبنة موتزاريلا سايحة', nameEn: 'Melted Mozzarella', price: 15.0),
        ],
      ),

      // FETEER
      ProductModel(
        id: 'p-10',
        categoryId: 'cat-5',
        nameAr: 'فطير مشلتت فلاحي بالسمن البلدي',
        nameEn: 'Traditional Egyptian Meshaltet Feteer',
        descriptionAr: 'فطير مشلتت مورق وخفيف مخبوز على أصوله بالسمن البلدي الطبيعي، يقدم ساخناً مع العسل الأسود والطحينة أو الجبنة القديمة.',
        descriptionEn: 'Flaky layered authentic Egyptian meshaltet baked with pure ghee, served hot with molasses or cheese.',
        imageUrl: 'https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=800&q=80',
        basePrice: 90.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        isFeatured: true,
        sizes: [
          ProductSizeModel(id: 's-10-1', productId: 'p-10', nameAr: 'وسط (تكفي 2-3 أفراد)', nameEn: 'Medium (Serves 2-3)', price: 90.0, isDefault: true),
          ProductSizeModel(id: 's-10-2', productId: 'p-10', nameAr: 'كبير عائلي (تكفي 4-6 أفراد)', nameEn: 'Large (Serves 4-6)', price: 140.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-10-1', productId: 'p-10', nameAr: 'طبق عسل أسود وطحينة', nameEn: 'Molasses & Tahini', price: 15.0),
          ProductExtraModel(id: 'e-10-2', productId: 'p-10', nameAr: 'طبق جبنة قديمة بالطماطم', nameEn: 'Aged Cheese', price: 15.0),
          ProductExtraModel(id: 'e-10-3', productId: 'p-10', nameAr: 'طبق عسل أبيض وقشطة بلدي', nameEn: 'Honey & Cream', price: 25.0),
        ],
      ),
      ProductModel(
        id: 'p-11',
        categoryId: 'cat-5',
        nameAr: 'فطير حلو كاسترد وبودرة وسكر وقشطة',
        nameEn: 'Sweet Custard & Powder Sugar Feteer',
        descriptionAr: 'فطير حلو مورق محشو بالكاسترد اللذيذ ومغطى بالسكر البودرة واللبن الساخن والمكسرات والقشطة.',
        descriptionEn: 'Sweet feteer filled with custard, dusted with powdered sugar, warm milk, nuts and cream.',
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80',
        basePrice: 75.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-11-1', productId: 'p-11', nameAr: 'وسط', nameEn: 'Medium', price: 75.0, isDefault: true),
          ProductSizeModel(id: 's-11-2', productId: 'p-11', nameAr: 'كبير', nameEn: 'Large', price: 110.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-11-1', productId: 'p-11', nameAr: 'قشطة بلدي إضافية', nameEn: 'Extra Cream', price: 20.0),
        ],
      ),

      // HAWAWSHI
      ProductModel(
        id: 'p-12',
        categoryId: 'cat-6',
        nameAr: 'حواوشي إسكندراني مخصوص بالجبنة',
        nameEn: 'Special Alexandrian Cheesy Hawawshi',
        descriptionAr: 'عجين طازج محشو باللحم البلدي المفروم المتبل بخلطة أولاد الشيخ السرية، مكس جبنة موتزاريلا ورومي، وفلفل حار مخبوز حتى القرمشة الذهبية.',
        descriptionEn: 'Freshly baked dough stuffed with spiced minced beef, mozzarella & roumi cheese, baked golden crisp.',
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
        basePrice: 55.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        isFeatured: true,
        isBestSeller: true,
        sizes: [
          ProductSizeModel(id: 's-12-1', productId: 'p-12', nameAr: 'رغيف واحد عادي', nameEn: 'Single Loaf', price: 55.0, isDefault: true),
          ProductSizeModel(id: 's-12-2', productId: 'p-12', nameAr: 'رغيف دبل لحمة وجبنة', nameEn: 'Double Meat & Cheese', price: 80.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-12-1', productId: 'p-12', nameAr: 'جبنة موتزاريلا على الوش (وش بيتزا)', nameEn: 'Pizza Style Topping', price: 20.0),
          ProductExtraModel(id: 'e-12-2', productId: 'p-12', nameAr: 'سلطة طحينة ومخلل بلدي', nameEn: 'Tahini & Pickles', price: 10.0),
        ],
      ),
      ProductModel(
        id: 'p-13',
        categoryId: 'cat-6',
        nameAr: 'حواوشي سجق بلدي وموتزاريلا',
        nameEn: 'Baladi Sausage & Mozzarella Hawawshi',
        descriptionAr: 'رغيف عجين حواوشي محشو بالسجق البلدي المتبل والجبنة الموتزاريلا السايحة والفلفل الرومي والحار.',
        descriptionEn: 'Crispy dough stuffed with spiced oriental sausage, melted mozzarella, and green peppers.',
        imageUrl: 'https://images.unsplash.com/photo-1603064752734-4c48eff53d05?w=800&q=80',
        basePrice: 60.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-13-1', productId: 'p-13', nameAr: 'رغيف عادي', nameEn: 'Single', price: 60.0, isDefault: true),
          ProductSizeModel(id: 's-13-2', productId: 'p-13', nameAr: 'رغيف سوبر بالجبن', nameEn: 'Super Cheesy', price: 85.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-13-1', productId: 'p-13', nameAr: 'صوص حار سبايسي', nameEn: 'Spicy Dip', price: 10.0),
        ],
      ),

      // EXTRAS & DRINKS
      ProductModel(
        id: 'p-14',
        categoryId: 'cat-7',
        nameAr: 'بطاطس محمرة مع صوص الشيدر',
        nameEn: 'French Fries with Cheddar Sauce',
        descriptionAr: 'أصابع بطاطس ذهبية مقرمشة مبهرة ومغمورة بصوص الجبنة الشيدر الأمريكي الساخن.',
        descriptionEn: 'Golden french fries with warm melted cheddar sauce.',
        imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=800&q=80',
        basePrice: 35.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-14-1', productId: 'p-14', nameAr: 'طبق عادي', nameEn: 'Regular Plate', price: 35.0, isDefault: true),
          ProductSizeModel(id: 's-14-2', productId: 'p-14', nameAr: 'طبق كبير لارج', nameEn: 'Large Plate', price: 50.0),
        ],
        extras: [
          ProductExtraModel(id: 'e-14-1', productId: 'p-14', nameAr: 'صوص رانش إضافي', nameEn: 'Extra Ranch', price: 10.0),
        ],
      ),
      ProductModel(
        id: 'p-15',
        categoryId: 'cat-7',
        nameAr: 'مشروبات غازية كانز 330 مل',
        nameEn: 'Soft Drinks Can 330ml',
        descriptionAr: 'كانز بارد مثلج (بيبسي، سفن آب، ميرندا، كوكاكولا، سبرايت).',
        descriptionEn: 'Ice cold soda can (Pepsi, 7Up, Mirinda, Coca Cola, Sprite).',
        imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80',
        basePrice: 18.0,
        isAvailable: true,
        isSampleRequiringAdminConfirmation: true,
        sizes: [
          ProductSizeModel(id: 's-15-1', productId: 'p-15', nameAr: 'كانز 330 مل', nameEn: 'Can 330ml', price: 18.0, isDefault: true),
          ProductSizeModel(id: 's-15-2', productId: 'p-15', nameAr: 'لتر عائلي', nameEn: 'Family 1L', price: 30.0),
        ],
        extras: [],
      ),
    ];
  }
}
