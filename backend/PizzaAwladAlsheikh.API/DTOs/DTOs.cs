using System.ComponentModel.DataAnnotations;
using PizzaAwladAlsheikh.API.Models;

namespace PizzaAwladAlsheikh.API.DTOs;

// --- Auth DTOs ---
public record LoginRequest(
    [Required] string Username,
    [Required] string Password
);

public record LoginResponse(
    string Token,
    string Username,
    string Email,
    string Role,
    DateTime ExpiresAt
);

// --- Product & Category DTOs ---
public record ProductSizeDto(
    Guid? Id,
    [Required] string NameAr,
    [Required] string NameEn,
    decimal Price,
    bool IsDefault
);

public record ProductExtraDto(
    Guid? Id,
    [Required] string NameAr,
    [Required] string NameEn,
    decimal Price,
    bool IsAvailable
);

public record CreateProductRequest(
    [Required] Guid CategoryId,
    [Required] string NameAr,
    [Required] string NameEn,
    string DescriptionAr,
    string DescriptionEn,
    string ImageUrl,
    decimal BasePrice,
    bool IsAvailable,
    bool IsSampleRequiringAdminConfirmation,
    string PreparationNotes,
    bool IsFeatured,
    bool IsBestSeller,
    List<ProductSizeDto>? Sizes,
    List<ProductExtraDto>? Extras
);

public record UpdateProductRequest(
    Guid CategoryId,
    string NameAr,
    string NameEn,
    string DescriptionAr,
    string DescriptionEn,
    string ImageUrl,
    decimal BasePrice,
    bool IsAvailable,
    bool IsSampleRequiringAdminConfirmation,
    string PreparationNotes,
    bool IsFeatured,
    bool IsBestSeller,
    List<ProductSizeDto>? Sizes,
    List<ProductExtraDto>? Extras
);

public record CategoryDto(
    Guid? Id,
    string NameAr,
    string NameEn,
    string Icon,
    int DisplayOrder,
    bool IsActive
);

// --- Order DTOs ---
public record OrderItemExtraRequest(
    string ExtraNameAr,
    decimal ExtraPrice
);

public record OrderItemRequest(
    Guid? ProductId,
    [Required] string ProductNameAr,
    string ProductNameEn,
    string SelectedSizeNameAr,
    decimal SelectedSizePrice,
    int Quantity,
    decimal UnitPrice,
    decimal TotalPrice,
    string Notes,
    List<OrderItemExtraRequest>? Extras
);

public record CreateOrderRequest(
    [Required] string CustomerName,
    [Required] string CustomerPhone,
    string DeliveryAddress,
    string Area,
    OrderType OrderType,
    string PaymentMethod,
    string Notes,
    double? Latitude,
    double? Longitude,
    decimal Subtotal,
    decimal DeliveryFee,
    decimal Discount,
    decimal TotalAmount,
    [Required] List<OrderItemRequest> Items
);

public record UpdateOrderStatusRequest(
    OrderStatus Status,
    string? Notes
);

public record OrderSummaryResponse(
    Guid Id,
    string OrderReference,
    string CustomerName,
    string CustomerPhone,
    string DeliveryAddress,
    string Area,
    OrderType OrderType,
    string PaymentMethod,
    string Notes,
    double? Latitude,
    double? Longitude,
    decimal Subtotal,
    decimal DeliveryFee,
    decimal Discount,
    decimal TotalAmount,
    OrderStatus Status,
    string FormattedStatusAr,
    string WhatsAppUrl,
    DateTime CreatedAt,
    List<OrderItemResponse> Items
);

public record OrderItemResponse(
    Guid Id,
    string ProductNameAr,
    string ProductNameEn,
    string SelectedSizeNameAr,
    decimal SelectedSizePrice,
    int Quantity,
    decimal UnitPrice,
    decimal TotalPrice,
    string Notes,
    List<OrderItemExtraResponse> Extras
);

public record OrderItemExtraResponse(
    Guid Id,
    string ExtraNameAr,
    decimal ExtraPrice
);

// --- Settings DTOs ---
public record SettingDto(string Key, string Value, string Description);

public record UpdateSettingRequest(string Value);
