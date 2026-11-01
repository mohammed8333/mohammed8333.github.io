-- ============================================================
-- قاعدة بيانات مطعم بيتزا أولاد الشيخ (Pizza Awlad Alsheikh)
-- نظام إدارة الطلبات والمنيو وقاعدة بيانات PostgreSQL
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. جدول المستخدمين الإداريين (Admin Users)
CREATE TABLE "AdminUsers" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "Username" VARCHAR(50) NOT NULL UNIQUE,
    "Email" VARCHAR(100) NOT NULL,
    "PasswordHash" VARCHAR(255) NOT NULL,
    "Role" VARCHAR(50) NOT NULL DEFAULT 'Administrator',
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 2. جدول إعدادات المطعم (Restaurant Settings)
CREATE TABLE "RestaurantSettings" (
    "Key" VARCHAR(100) PRIMARY KEY,
    "Value" TEXT NOT NULL,
    "Description" VARCHAR(250) NULL,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 3. جدول أقسام قائمة الطعام (Categories)
CREATE TABLE "Categories" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "NameAr" VARCHAR(100) NOT NULL,
    "NameEn" VARCHAR(100) NOT NULL,
    "Icon" VARCHAR(100) NOT NULL DEFAULT 'local_pizza',
    "DisplayOrder" INT NOT NULL DEFAULT 0,
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 4. جدول المنتجات والوجبات (Products)
CREATE TABLE "Products" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "CategoryId" UUID NOT NULL REFERENCES "Categories"("Id") ON DELETE RESTRICT,
    "NameAr" VARCHAR(150) NOT NULL,
    "NameEn" VARCHAR(150) NOT NULL,
    "DescriptionAr" VARCHAR(1000) NULL,
    "DescriptionEn" VARCHAR(1000) NULL,
    "ImageUrl" VARCHAR(500) NULL,
    "BasePrice" NUMERIC(18, 2) NOT NULL,
    "IsAvailable" BOOLEAN NOT NULL DEFAULT TRUE,
    "IsSampleRequiringAdminConfirmation" BOOLEAN NOT NULL DEFAULT TRUE,
    "PreparationNotes" VARCHAR(500) NULL,
    "IsFeatured" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsBestSeller" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX "IX_Products_CategoryId" ON "Products"("CategoryId");
CREATE INDEX "IX_Products_IsAvailable" ON "Products"("IsAvailable");

-- 5. جدول أحجام المنتجات (Product Sizes)
CREATE TABLE "ProductSizes" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "ProductId" UUID NOT NULL REFERENCES "Products"("Id") ON DELETE CASCADE,
    "NameAr" VARCHAR(50) NOT NULL,
    "NameEn" VARCHAR(50) NOT NULL,
    "Price" NUMERIC(18, 2) NOT NULL,
    "IsDefault" BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX "IX_ProductSizes_ProductId" ON "ProductSizes"("ProductId");

-- 6. جدول إضافات ومقبلات المنتجات (Product Extras)
CREATE TABLE "ProductExtras" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "ProductId" UUID NOT NULL REFERENCES "Products"("Id") ON DELETE CASCADE,
    "NameAr" VARCHAR(100) NOT NULL,
    "NameEn" VARCHAR(100) NOT NULL,
    "Price" NUMERIC(18, 2) NOT NULL,
    "IsAvailable" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX "IX_ProductExtras_ProductId" ON "ProductExtras"("ProductId");

-- 7. جدول طلبات العملاء (Orders)
CREATE TABLE "Orders" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "OrderReference" VARCHAR(50) NOT NULL UNIQUE,
    "CustomerName" VARCHAR(100) NOT NULL,
    "CustomerPhone" VARCHAR(20) NOT NULL,
    "DeliveryAddress" VARCHAR(300) NULL,
    "Area" VARCHAR(100) NULL,
    "OrderType" INT NOT NULL DEFAULT 1, -- 1: Delivery, 2: Takeaway
    "PaymentMethod" VARCHAR(50) NOT NULL DEFAULT 'الدفع عند الاستلام',
    "Notes" VARCHAR(500) NULL,
    "Latitude" DOUBLE PRECISION NULL,
    "Longitude" DOUBLE PRECISION NULL,
    "Subtotal" NUMERIC(18, 2) NOT NULL,
    "DeliveryFee" NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    "Discount" NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    "TotalAmount" NUMERIC(18, 2) NOT NULL,
    "Status" INT NOT NULL DEFAULT 1, -- 1: Pending, 2: Confirmed, 3: Preparing, 4: OutForDelivery, 5: Delivered, 6: Cancelled
    "WhatsAppMessageSent" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP WITH TIME ZONE NULL
);

CREATE INDEX "IX_Orders_OrderReference" ON "Orders"("OrderReference");
CREATE INDEX "IX_Orders_Status" ON "Orders"("Status");
CREATE INDEX "IX_Orders_CreatedAt" ON "Orders"("CreatedAt");

-- 8. جدول تفاصيل بنود الطلب (Order Items)
CREATE TABLE "OrderItems" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "OrderId" UUID NOT NULL REFERENCES "Orders"("Id") ON DELETE CASCADE,
    "ProductId" UUID NULL,
    "ProductNameAr" VARCHAR(150) NOT NULL,
    "ProductNameEn" VARCHAR(150) NULL,
    "SelectedSizeNameAr" VARCHAR(50) NULL,
    "SelectedSizePrice" NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    "Quantity" INT NOT NULL DEFAULT 1,
    "UnitPrice" NUMERIC(18, 2) NOT NULL,
    "TotalPrice" NUMERIC(18, 2) NOT NULL,
    "Notes" VARCHAR(500) NULL
);

CREATE INDEX "IX_OrderItems_OrderId" ON "OrderItems"("OrderId");

-- 9. جدول إضافات بنود الطلب (Order Item Extras)
CREATE TABLE "OrderItemExtras" (
    "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "OrderItemId" UUID NOT NULL REFERENCES "OrderItems"("Id") ON DELETE CASCADE,
    "ExtraNameAr" VARCHAR(100) NOT NULL,
    "ExtraPrice" NUMERIC(18, 2) NOT NULL
);

CREATE INDEX "IX_OrderItemExtras_OrderItemId" ON "OrderItemExtras"("OrderItemId");
