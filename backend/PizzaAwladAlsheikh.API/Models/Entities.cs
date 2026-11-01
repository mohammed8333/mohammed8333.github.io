using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace PizzaAwladAlsheikh.API.Models;

public class Category
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(100)]
    public string NameAr { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string NameEn { get; set; } = string.Empty;

    [MaxLength(100)]
    public string Icon { get; set; } = "local_pizza";

    public int DisplayOrder { get; set; } = 0;

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [JsonIgnore]
    public List<Product> Products { get; set; } = new();
}

public class Product
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid CategoryId { get; set; }

    public Category? Category { get; set; }

    [Required]
    [MaxLength(150)]
    public string NameAr { get; set; } = string.Empty;

    [Required]
    [MaxLength(150)]
    public string NameEn { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string DescriptionAr { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string DescriptionEn { get; set; } = string.Empty;

    [MaxLength(500)]
    public string ImageUrl { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal BasePrice { get; set; }

    public bool IsAvailable { get; set; } = true;

    /// <summary>
    /// Requirement: Editable sample records marked as requiring administrator confirmation.
    /// Never present unverified prices as official restaurant prices.
    /// </summary>
    public bool IsSampleRequiringAdminConfirmation { get; set; } = true;

    [MaxLength(500)]
    public string PreparationNotes { get; set; } = string.Empty;

    public bool IsFeatured { get; set; } = false;

    public bool IsBestSeller { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public List<ProductSize> Sizes { get; set; } = new();

    public List<ProductExtra> Extras { get; set; } = new();
}

public class ProductSize
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid ProductId { get; set; }

    [JsonIgnore]
    public Product? Product { get; set; }

    [Required]
    [MaxLength(50)]
    public string NameAr { get; set; } = string.Empty; // صغير، وسط، كبير، عائلي

    [Required]
    [MaxLength(50)]
    public string NameEn { get; set; } = string.Empty; // Small, Medium, Large, Family

    [Column(TypeName = "decimal(18,2)")]
    public decimal Price { get; set; }

    public bool IsDefault { get; set; } = false;
}

public class ProductExtra
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid ProductId { get; set; }

    [JsonIgnore]
    public Product? Product { get; set; }

    [Required]
    [MaxLength(100)]
    public string NameAr { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string NameEn { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal Price { get; set; }

    public bool IsAvailable { get; set; } = true;
}

public enum OrderType
{
    Delivery = 1,
    Takeaway = 2
}

public enum OrderStatus
{
    Pending = 1,        // قيد الانتظار (في انتظار تأكيد واتساب / المطعم)
    Confirmed = 2,      // مؤكد
    Preparing = 3,      // جاري التجهيز
    OutForDelivery = 4, // في الطريق
    Delivered = 5,      // تم التسليم
    Cancelled = 6       // ملغي
}

public class Order
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(50)]
    public string OrderReference { get; set; } = string.Empty; // #ORD-1001

    [Required]
    [MaxLength(100)]
    public string CustomerName { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string CustomerPhone { get; set; } = string.Empty;

    [MaxLength(300)]
    public string DeliveryAddress { get; set; } = string.Empty;

    [MaxLength(100)]
    public string Area { get; set; } = string.Empty;

    public OrderType OrderType { get; set; } = OrderType.Delivery;

    [MaxLength(50)]
    public string PaymentMethod { get; set; } = "الدفع عند الاستلام"; // Cash on Delivery, Vodafone Cash, etc.

    [MaxLength(500)]
    public string Notes { get; set; } = string.Empty;

    public double? Latitude { get; set; }
    public double? Longitude { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Subtotal { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal DeliveryFee { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Discount { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalAmount { get; set; }

    public OrderStatus Status { get; set; } = OrderStatus.Pending;

    public bool WhatsAppMessageSent { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public List<OrderItem> Items { get; set; } = new();
}

public class OrderItem
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid OrderId { get; set; }

    [JsonIgnore]
    public Order? Order { get; set; }

    public Guid? ProductId { get; set; }

    [Required]
    [MaxLength(150)]
    public string ProductNameAr { get; set; } = string.Empty;

    [MaxLength(150)]
    public string ProductNameEn { get; set; } = string.Empty;

    [MaxLength(50)]
    public string SelectedSizeNameAr { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal SelectedSizePrice { get; set; }

    public int Quantity { get; set; } = 1;

    [Column(TypeName = "decimal(18,2)")]
    public decimal UnitPrice { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalPrice { get; set; }

    [MaxLength(500)]
    public string Notes { get; set; } = string.Empty;

    public List<OrderItemExtra> Extras { get; set; } = new();
}

public class OrderItemExtra
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid OrderItemId { get; set; }

    [JsonIgnore]
    public OrderItem? OrderItem { get; set; }

    [Required]
    [MaxLength(100)]
    public string ExtraNameAr { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal ExtraPrice { get; set; }
}

public class RestaurantSetting
{
    [Key]
    [MaxLength(100)]
    public string Key { get; set; } = string.Empty;

    [Required]
    public string Value { get; set; } = string.Empty;

    [MaxLength(250)]
    public string Description { get; set; } = string.Empty;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class AdminUser
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(50)]
    public string Username { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    [MaxLength(50)]
    public string Role { get; set; } = "Administrator";

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
