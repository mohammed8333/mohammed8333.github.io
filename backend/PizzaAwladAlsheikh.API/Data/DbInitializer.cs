using Microsoft.EntityFrameworkCore;
using PizzaAwladAlsheikh.API.Models;

namespace PizzaAwladAlsheikh.API.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(AppDbContext context)
    {
        // Apply pending migrations or ensure database is created
        await context.Database.EnsureCreatedAsync();

        // 1. Seed Admin User
        if (!await context.AdminUsers.AnyAsync())
        {
            var admin = new AdminUser
            {
                Id = Guid.NewGuid(),
                Username = "admin",
                Email = "admin@pizzaawladalsheikh.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("AdminPassword123!"),
                Role = "Administrator",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };
            context.AdminUsers.Add(admin);
        }

        // 2. Seed Restaurant Settings
        if (!await context.RestaurantSettings.AnyAsync())
        {
            var settings = new List<RestaurantSetting>
            {
                new() { Key = "RestaurantNameAr", Value = "بيتزا أولاد الشيخ", Description = "اسم المطعم بالعربية" },
                new() { Key = "RestaurantNameEn", Value = "Pizza Awlad Alsheikh", Description = "Restaurant Name in English" },
                new() { Key = "Phone", Value = "01112962692", Description = "رقم الهاتف للاتصال المباشر" },
                new() { Key = "WhatsApp", Value = "201112962692", Description = "رقم الواتساب لاستقبال الطلبات (+201112962692)" },
                new() { Key = "AddressAr", Value = "امتداد شارع الوحدة، المنيرة، إمبابة، الجيزة، مصر", Description = "العنوان التفصيلي بالعربية" },
                new() { Key = "AddressEn", Value = "El-Wehda St Ext, El-Monira, Imbaba, Giza, Egypt", Description = "Address in English" },
                new() { Key = "GoogleMapsUrl", Value = "https://maps.app.goo.gl/Hi55NFkp5H8ZNDqV6", Description = "رابط خرائط جوجل الرسمي" },
                new() { Key = "Latitude", Value = "30.0880921", Description = "خط العرض الجغرافي" },
                new() { Key = "Longitude", Value = "31.2103625", Description = "خط الطول الجغرافي" },
                new() { Key = "OpeningHoursAr", Value = "24 ساعة يومياً (طوال أيام الأسبوع)", Description = "مواعيد العمل" },
                new() { Key = "OpeningHoursEn", Value = "24 Hours Daily (7 days a week)", Description = "Opening Hours" },
                new() { Key = "GoogleRating", Value = "3.9", Description = "تقييم جوجل (حوالي 235 مراجعة)" },
                new() { Key = "DeliveryFeeDefault", Value = "20.00", Description = "سعر التوصيل الافتراضي بالجنيه المصري (قابل للإدارة)" },
                new() { Key = "MinimumOrderValue", Value = "60.00", Description = "الحد الأدنى للطلب بالجنيه المصري" },
                new() { Key = "AnnouncementAr", Value = "أهلاً بكم في بيتزا أولاد الشيخ بإمبابة! خدمة التوصيل والتيك أواي متوفرة 24 ساعة يومياً. (الأسعار في التطبيق عينات تتطلب اعتماد الإدارة)", Description = "الإعلان الترويجي في أعلى التطبيق" },
                new() { Key = "AnnouncementEn", Value = "Welcome to Pizza Awlad Alsheikh! 24/7 Delivery & Takeaway in Imbaba. Sample menu items require admin verification.", Description = "Promo Announcement" },
                new() { Key = "DeliveryAreas", Value = "إمبابة, المنيرة, الوراق, بشتيل, المهندسين, العجوزة, أرض اللواء, الكيت كات", Description = "مناطق التوصيل المدعومة" }
            };
            context.RestaurantSettings.AddRange(settings);
        }

        // 3. Seed Categories & Products
        if (!await context.Categories.AnyAsync())
        {
            var catPizza = new Category
            {
                Id = Guid.NewGuid(),
                NameAr = "بيتزا (إيطالي وشرقي)",
                NameEn = "Pizza (Italian & Eastern)",
                Icon = "local_pizza",
                DisplayOrder = 1,
                IsActive = true
            };

            var catCrepe = new Category
            {
                Id = Guid.NewGuid(),
                NameAr = "كريب",
                NameEn = "Crepes",
                Icon = "lunch_dining",
                DisplayOrder = 2,
                IsActive = true
            };

            var catBurger = new Category
            {
                Id = Guid.NewGuid(),
                NameAr = "برجر",
                NameEn = "Burgers",
                Icon = "fastfood",
                DisplayOrder = 3,
                IsActive = true
            };

            var catSandwich = new Category
            {
                Id = Guid.NewGuid(),
                NameAr = "سندوتشات",
                NameEn = "Sandwiches",
                Icon = "dinner_dining",
                DisplayOrder = 4,
                IsActive = true
            };

            var catFeteer = new Category
            {
                Id = Guid.NewGuid(),
                NameAr = "فطير مشلتت وحلو وحادق",
                NameEn = "Feteer (Sweet & Savory)",
                Icon = "pie_menu",
                DisplayOrder = 5,
                IsActive = true
            };

            var catHawawshi = new Category
            {
                Id = Guid.NewGuid(),
                NameAr = "حواوشي",
                NameEn = "Hawawshi",
                Icon = "bakery_dining",
                DisplayOrder = 6,
                IsActive = true
            };

            var catExtras = new Category
            {
                Id = Guid.NewGuid(),
                NameAr = "إضافات ومشروبات",
                NameEn = "Extras & Drinks",
                Icon = "local_drink",
                DisplayOrder = 7,
                IsActive = true
            };

            context.Categories.AddRange(catPizza, catCrepe, catBurger, catSandwich, catFeteer, catHawawshi, catExtras);

            // Seed Products with sizes, extras, and marked as sample requiring admin confirmation
            var products = new List<Product>
            {
                // PIZZAS
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catPizza.Id,
                    NameAr = "بيتزا سوبر سوبريم أولاد الشيخ",
                    NameEn = "Awlad Alsheikh Super Supreme Pizza",
                    DescriptionAr = "خلطة أولاد الشيخ المميزة: لحم مفروم، سوسيس، سلامي، مشروم طازج، فلفل ألوان، زيتون، وجبنة موتزاريلا غنية.",
                    DescriptionEn = "Special blend: Minced beef, sausage, salami, fresh mushrooms, bell peppers, olives, and rich mozzarella cheese.",
                    ImageUrl = "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80",
                    BasePrice = 130.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    PreparationNotes = "تخبز طازجة في الفرن الحجري لمدة 15 دقيقة",
                    IsFeatured = true,
                    IsBestSeller = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "صغير (22 سم)", NameEn = "Small (22cm)", Price = 95.00m, IsDefault = false },
                        new() { NameAr = "وسط (28 سم)", NameEn = "Medium (28cm)", Price = 130.00m, IsDefault = true },
                        new() { NameAr = "كبير (34 سم)", NameEn = "Large (34cm)", Price = 175.00m, IsDefault = false },
                        new() { NameAr = "عائلي (40 سم)", NameEn = "Family (40cm)", Price = 220.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "جبنة موتزاريلا إضافية", NameEn = "Extra Mozzarella", Price = 25.00m },
                        new() { NameAr = "أطراف محشوة جبنة (ستافد كرست)", NameEn = "Stuffed Crust", Price = 30.00m },
                        new() { NameAr = "مشروم طازج إضافي", NameEn = "Extra Mushrooms", Price = 20.00m },
                        new() { NameAr = "صوص رانش جانبي", NameEn = "Ranch Sauce Dip", Price = 15.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catPizza.Id,
                    NameAr = "بيتزا مشكل جبن شرقي",
                    NameEn = "Eastern Mixed Cheese Pizza",
                    DescriptionAr = "مكس أجبان فاخر (موتزاريلا، كيري، رومي، شيدر) مع طماطم وفلفل وزيتون، على العجينة الشرقية المورقة المقرمشة.",
                    DescriptionEn = "Four cheese blend (mozzarella, kiri, roumi, cheddar) with tomatoes, peppers, and olives on flaky eastern crust.",
                    ImageUrl = "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&q=80",
                    BasePrice = 110.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    PreparationNotes = "عجينة شرقية مورقة بالسمن البلدي",
                    IsFeatured = true,
                    IsBestSeller = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "وسط (28 سم)", NameEn = "Medium (28cm)", Price = 110.00m, IsDefault = true },
                        new() { NameAr = "كبير (34 سم)", NameEn = "Large (34cm)", Price = 150.00m, IsDefault = false },
                        new() { NameAr = "عائلي (40 سم)", NameEn = "Family (40cm)", Price = 195.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "إضافة بسطرمة", NameEn = "Add Pastrami", Price = 30.00m },
                        new() { NameAr = "جبنة كيري زيادة", NameEn = "Extra Kiri", Price = 20.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catPizza.Id,
                    NameAr = "بيتزا سجق إسكندراني شرقي",
                    NameEn = "Alexandrian Sausage Eastern Pizza",
                    DescriptionAr = "سجق بلدي متبل بالخلطة الإسكندرانية الأصلية، فلفل حار، طماطم، بصل، وجبنة موتزاريلا ورومي ذائبة.",
                    DescriptionEn = "Spicy Alexandrian sausage, hot green chili, tomatoes, onions, melted mozzarella & roumi cheese.",
                    ImageUrl = "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80",
                    BasePrice = 125.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "وسط", NameEn = "Medium", Price = 125.00m, IsDefault = true },
                        new() { NameAr = "كبير", NameEn = "Large", Price = 165.00m, IsDefault = false },
                        new() { NameAr = "عائلي", NameEn = "Family", Price = 210.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "سجق إضافي", NameEn = "Extra Sausage", Price = 25.00m },
                        new() { NameAr = "فلفل هالبينو حار", NameEn = "Jalapenos", Price = 10.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catPizza.Id,
                    NameAr = "بيتزا باربيكيو تشيكن",
                    NameEn = "BBQ Chicken Pizza",
                    DescriptionAr = "قطع دجاج متبلة مشوية، بصل أحمر مكرمل، صوص باربيكيو مدخن، جبنة موتزاريلا وبقدونس طازج.",
                    DescriptionEn = "Grilled marinated chicken, red onion, smoked BBQ sauce, mozzarella, and fresh parsley.",
                    ImageUrl = "https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=800&q=80",
                    BasePrice = 135.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "وسط", NameEn = "Medium", Price = 135.00m, IsDefault = true },
                        new() { NameAr = "كبير", NameEn = "Large", Price = 180.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "صوص باربيكيو زيادة", NameEn = "Extra BBQ Sauce", Price = 10.00m },
                        new() { NameAr = "قطع دجاج إضافية", NameEn = "Extra Chicken", Price = 25.00m }
                    }
                },

                // CREPES
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catCrepe.Id,
                    NameAr = "كريب كرانشي سوبر زنجر",
                    NameEn = "Crunchy Super Zinger Crepe",
                    DescriptionAr = "قطع دجاج كرسبي مقرمش، بطاطس مقلية، صوص جبنة شيدر، موتزاريلا سايحة، مايونيز، وكاتشب.",
                    DescriptionEn = "Crispy spicy chicken strips, french fries, melted cheddar cheese sauce, mozzarella, mayo & ketchup.",
                    ImageUrl = "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=800&q=80",
                    BasePrice = 85.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    IsFeatured = true,
                    IsBestSeller = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "حجم عادي", NameEn = "Regular", Price = 85.00m, IsDefault = true },
                        new() { NameAr = "حجم جامبو (صاروخ)", NameEn = "Jumbo", Price = 115.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "إضافة استربس كرانشي", NameEn = "Extra Strips", Price = 20.00m },
                        new() { NameAr = "صوص جبنة شيدر سائل", NameEn = "Melted Cheddar Sauce", Price = 15.00m },
                        new() { NameAr = "موتزاريلا زيادة", NameEn = "Extra Mozzarella", Price = 15.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catCrepe.Id,
                    NameAr = "كريب شاورما فراخ وموتزاريلا",
                    NameEn = "Chicken Shawarma & Mozzarella Crepe",
                    DescriptionAr = "شاورما دجاج متبلة بالبهارات الخاصة مع فلفل ألوان، طماطم، مخلل، تومية وموتزاريلا غنية.",
                    DescriptionEn = "Seasoned chicken shawarma with bell peppers, tomatoes, pickles, garlic sauce, and melted mozzarella.",
                    ImageUrl = "https://images.unsplash.com/photo-1529042410759-befb1204b468?w=800&q=80",
                    BasePrice = 80.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "حجم عادي", NameEn = "Regular", Price = 80.00m, IsDefault = true },
                        new() { NameAr = "حجم جامبو", NameEn = "Jumbo", Price = 110.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "صوص ثومية إضافي", NameEn = "Extra Garlic Sauce", Price = 10.00m },
                        new() { NameAr = "بطاطس فارم فريتس داخل الكريب", NameEn = "Add Fries Inside", Price = 12.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catCrepe.Id,
                    NameAr = "كريب شوكولاتة نوتيلا وموز ومكسرات",
                    NameEn = "Nutella Banana & Nuts Crepe",
                    DescriptionAr = "كريب حلو غني بشوكولاتة النوتيلا الأصلية، شرائح موز طازجة، ومكسرات كاجو وبندق مجروش مع صوص كراميل.",
                    DescriptionEn = "Sweet crepe smothered in authentic Nutella, fresh sliced banana, chopped hazelnuts & cashews with caramel drizzle.",
                    ImageUrl = "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=800&q=80",
                    BasePrice = 65.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "حجم عادي", NameEn = "Regular", Price = 65.00m, IsDefault = true },
                        new() { NameAr = "حجم دبل", NameEn = "Double", Price = 90.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "نوتيلا زيادة", NameEn = "Extra Nutella", Price = 20.00m },
                        new() { NameAr = "أوريو مجروش", NameEn = "Crushed Oreo", Price = 15.00m }
                    }
                },

                // BURGERS
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catBurger.Id,
                    NameAr = "برجر أولاد الشيخ دبل تشيز بيف",
                    NameEn = "Awlad Alsheikh Double Cheese Beef Burger",
                    DescriptionAr = "قطعتين لحم بقرى مشوي على اللهب (200 جرام)، جبنة شيدر أمريكية ذائبة، خس، طماطم، خيار مخلل، وصوص خاص.",
                    DescriptionEn = "Two flame-grilled beef patties (200g), double American melted cheddar, lettuce, tomatoes, pickles, and signature house sauce.",
                    ImageUrl = "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80",
                    BasePrice = 90.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    IsFeatured = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "سنجل (100 جرام)", NameEn = "Single", Price = 65.00m, IsDefault = false },
                        new() { NameAr = "دبل (200 جرام)", NameEn = "Double", Price = 90.00m, IsDefault = true },
                        new() { NameAr = "تربل عملاق (300 جرام)", NameEn = "Triple", Price = 120.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "إضافة شريحة بيكون لحم مدخن", NameEn = "Beef Bacon", Price = 20.00m },
                        new() { NameAr = "صوص مشروم بني", NameEn = "Mushroom Gravy", Price = 18.00m },
                        new() { NameAr = "أصابع بطاطس مقلية مع كومبو كانز", NameEn = "Make it Combo (Fries + Drink)", Price = 30.00m }
                    }
                },

                // SANDWICHES
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catSandwich.Id,
                    NameAr = "ساندوتش فاهيتا دجاج ميكسيكي",
                    NameEn = "Mexican Chicken Fajita Sandwich",
                    DescriptionAr = "شرائح صدور دجاج مشوية مع فلفل ألوان وبصل وتوابل الفاهيتا المكسيكية الحارة، في خبز سوري أو فينو طازج مع المايونيز والجبنة.",
                    DescriptionEn = "Grilled chicken breast strips with bell peppers, onions, Mexican fajita spices, mayo and melted cheese.",
                    ImageUrl = "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800&q=80",
                    BasePrice = 60.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "خبز فينو كبير", NameEn = "Large Baguette", Price = 60.00m, IsDefault = true },
                        new() { NameAr = "خبز سوري سوبر", NameEn = "Syrian Roll Super", Price = 75.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "جبنة موتزاريلا سايحة", NameEn = "Melted Mozzarella", Price = 15.00m }
                    }
                },

                // FETEER
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catFeteer.Id,
                    NameAr = "فطير مشلتت فلاحي بالسمن البلدي",
                    NameEn = "Traditional Egyptian Meshaltet Feteer",
                    DescriptionAr = "فطير مشلتت مورق وخفيف مخبوز على أصوله بالسمن البلدي الطبيعي، يقدم ساخناً مع العسل الأسود والطحينة أو الجبنة القديمة.",
                    DescriptionEn = "Flaky layered authentic Egyptian meshaltet pastry baked with pure ghee, served hot with molasses & tahini or old cheese.",
                    ImageUrl = "https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=800&q=80",
                    BasePrice = 90.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    IsFeatured = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "وسط (تكفي 2-3 أفراد)", NameEn = "Medium (Serves 2-3)", Price = 90.00m, IsDefault = true },
                        new() { NameAr = "كبير عائلي (تكفي 4-6 أفراد)", NameEn = "Large Family (Serves 4-6)", Price = 140.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "طبق عسل أسود وطحينة", NameEn = "Molasses & Tahini", Price = 15.00m },
                        new() { NameAr = "طبق جبنة قديمة بالطماطم", NameEn = "Aged Egyptian Cheese", Price = 15.00m },
                        new() { NameAr = "طبق عسل أبيض وقشطة بلدي", NameEn = "White Honey & Clotted Cream", Price = 25.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catFeteer.Id,
                    NameAr = "فطير حلو كاسترد وبودرة وسكر وقشطة",
                    NameEn = "Sweet Custard & Powder Sugar Feteer",
                    DescriptionAr = "فطير حلو مورق محشو بالكاسترد اللذيذ ومغطى بالسكر البودرة واللبن الساخن والمكسرات والقشطة.",
                    DescriptionEn = "Flaky sweet feteer filled with creamy custard, dusted with powdered sugar, warm milk, nuts and cream.",
                    ImageUrl = "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80",
                    BasePrice = 75.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "وسط", NameEn = "Medium", Price = 75.00m, IsDefault = true },
                        new() { NameAr = "كبير", NameEn = "Large", Price = 110.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "قشطة بلدي إضافية", NameEn = "Extra Cream", Price = 20.00m },
                        new() { NameAr = "مكسرات مشكلة محمصة", NameEn = "Roasted Mixed Nuts", Price = 20.00m }
                    }
                },

                // HAWAWSHI
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catHawawshi.Id,
                    NameAr = "حواوشي إسكندراني مخصوص بالجبنة",
                    NameEn = "Special Alexandrian Cheesy Hawawshi",
                    DescriptionAr = "عجين طازج محشو باللحم البلدي المفروم المتبل بخلطة أولاد الشيخ السرية، مكس جبنة موتزاريلا ورومي، وفلفل حار مخبوز حتى القرمشة الذهبية.",
                    DescriptionEn = "Freshly kneaded dough stuffed with seasoned minced beef, secret spices, melted mozzarella & roumi cheese, baked golden crisp.",
                    ImageUrl = "https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80",
                    BasePrice = 55.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    IsFeatured = true,
                    IsBestSeller = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "رغيف واحد عادي", NameEn = "Single Loaf", Price = 55.00m, IsDefault = true },
                        new() { NameAr = "رغيف دبل لحمة وجبنة", NameEn = "Double Meat & Cheese", Price = 80.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "جبنة موتزاريلا زيادة على الوش (وش بيتزا)", NameEn = "Pizza Style Topping", Price = 20.00m },
                        new() { NameAr = "سلطة طحينة ومخلل بلدي", NameEn = "Tahini & Egyptian Pickles", Price = 10.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catHawawshi.Id,
                    NameAr = "حواوشي سجق بلدي وموتزاريلا",
                    NameEn = "Baladi Sausage & Mozzarella Hawawshi",
                    DescriptionAr = "رغيف عجين حواوشي محشو بالسجق البلدي المتبل والجبنة الموتزاريلا السايحة والفلفل الرومي والحار.",
                    DescriptionEn = "Crispy dough stuffed with spiced oriental sausage, melted mozzarella, and green peppers.",
                    ImageUrl = "https://images.unsplash.com/photo-1603064752734-4c48eff53d05?w=800&q=80",
                    BasePrice = 60.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "رغيف عادي", NameEn = "Single", Price = 60.00m, IsDefault = true },
                        new() { NameAr = "رغيف سوبر بالجبن", NameEn = "Super Cheesy", Price = 85.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "صوص حار سبايسي", NameEn = "Spicy Sauce Dip", Price = 10.00m }
                    }
                },

                // EXTRAS & DRINKS
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catExtras.Id,
                    NameAr = "بطاطس محمرة مع صوص الشيدر",
                    NameEn = "French Fries with Cheddar Sauce",
                    DescriptionAr = "أصابع بطاطس ذهبية مقرمشة مبهرة ومغمورة بصوص الجبنة الشيدر الأمريكي الساخن.",
                    DescriptionEn = "Golden crispy french fries seasoned and smothered in hot American cheddar cheese sauce.",
                    ImageUrl = "https://images.unsplash.com/photo-1576107232684-1279f3908594?w=800&q=80",
                    BasePrice = 35.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "طبق عادي", NameEn = "Regular Plate", Price = 35.00m, IsDefault = true },
                        new() { NameAr = "طبق كبير لارج", NameEn = "Large Plate", Price = 50.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>
                    {
                        new() { NameAr = "صوص رانش إضافي", NameEn = "Extra Ranch", Price = 10.00m },
                        new() { NameAr = "هالبينو مقطع", NameEn = "Sliced Jalapeno", Price = 10.00m }
                    }
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    CategoryId = catExtras.Id,
                    NameAr = "مشروبات غازية كانز 330 مل",
                    NameEn = "Soft Drinks Can 330ml",
                    DescriptionAr = "كانز بارد مثلج (بيبسي، سفن آب، ميرندا برتقال، ميرندا تفاح، كوكاكولا، سبرايت).",
                    DescriptionEn = "Ice cold soda can (Pepsi, 7Up, Mirinda Orange, Mirinda Apple, Coca Cola, Sprite).",
                    ImageUrl = "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80",
                    BasePrice = 18.00m,
                    IsAvailable = true,
                    IsSampleRequiringAdminConfirmation = true,
                    Sizes = new List<ProductSize>
                    {
                        new() { NameAr = "كانز 330 مل", NameEn = "Can 330ml", Price = 18.00m, IsDefault = true },
                        new() { NameAr = "لتر عائلي", NameEn = "Family 1 Liter", Price = 30.00m, IsDefault = false }
                    },
                    Extras = new List<ProductExtra>()
                }
            };

            context.Products.AddRange(products);
        }

        await context.SaveChangesAsync();
    }
}
