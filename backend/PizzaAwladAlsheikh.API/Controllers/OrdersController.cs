using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PizzaAwladAlsheikh.API.Data;
using PizzaAwladAlsheikh.API.DTOs;
using PizzaAwladAlsheikh.API.Models;
using PizzaAwladAlsheikh.API.Services;

namespace PizzaAwladAlsheikh.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IWhatsAppService _whatsAppService;

    public OrdersController(AppDbContext context, IWhatsAppService whatsAppService)
    {
        _context = context;
        _whatsAppService = whatsAppService;
    }

    [HttpPost]
    public async Task<ActionResult<OrderSummaryResponse>> CreateOrder([FromBody] CreateOrderRequest request)
    {
        if (request.Items == null || !request.Items.Any())
        {
            return BadRequest(new { message = "سلة المشتريات فارغة، يرجى إضافة أصناف أولاً" });
        }

        // Generate Order Reference: #ORD-XXXX
        var todayCount = await _context.Orders
            .CountAsync(o => o.CreatedAt.Date == DateTime.UtcNow.Date);
        var refNumber = 1001 + todayCount;
        var orderReference = $"#ORD-{refNumber}";

        var order = new Order
        {
            Id = Guid.NewGuid(),
            OrderReference = orderReference,
            CustomerName = request.CustomerName.Trim(),
            CustomerPhone = request.CustomerPhone.Trim(),
            DeliveryAddress = request.DeliveryAddress?.Trim() ?? string.Empty,
            Area = request.Area?.Trim() ?? string.Empty,
            OrderType = request.OrderType,
            PaymentMethod = string.IsNullOrWhiteSpace(request.PaymentMethod) ? "الدفع عند الاستلام" : request.PaymentMethod,
            Notes = request.Notes?.Trim() ?? string.Empty,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Subtotal = request.Subtotal,
            DeliveryFee = request.OrderType == OrderType.Takeaway ? 0 : request.DeliveryFee,
            Discount = request.Discount,
            TotalAmount = request.TotalAmount,
            Status = OrderStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        foreach (var itemDto in request.Items)
        {
            var item = new OrderItem
            {
                Id = Guid.NewGuid(),
                OrderId = order.Id,
                ProductId = itemDto.ProductId,
                ProductNameAr = itemDto.ProductNameAr,
                ProductNameEn = itemDto.ProductNameEn ?? string.Empty,
                SelectedSizeNameAr = itemDto.SelectedSizeNameAr ?? string.Empty,
                SelectedSizePrice = itemDto.SelectedSizePrice,
                Quantity = itemDto.Quantity > 0 ? itemDto.Quantity : 1,
                UnitPrice = itemDto.UnitPrice,
                TotalPrice = itemDto.TotalPrice,
                Notes = itemDto.Notes ?? string.Empty
            };

            if (itemDto.Extras != null && itemDto.Extras.Any())
            {
                foreach (var extraDto in itemDto.Extras)
                {
                    item.Extras.Add(new OrderItemExtra
                    {
                        Id = Guid.NewGuid(),
                        OrderItemId = item.Id,
                        ExtraNameAr = extraDto.ExtraNameAr,
                        ExtraPrice = extraDto.ExtraPrice
                    });
                }
            }

            order.Items.Add(item);
        }

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        // Get Restaurant WhatsApp & Name
        var whatsAppSetting = await _context.RestaurantSettings
            .FirstOrDefaultAsync(s => s.Key == "WhatsApp");
        var whatsAppPhone = whatsAppSetting?.Value ?? "201112962692";

        var nameSetting = await _context.RestaurantSettings
            .FirstOrDefaultAsync(s => s.Key == "RestaurantNameAr");
        var restName = nameSetting?.Value ?? "بيتزا أولاد الشيخ";

        // Generate WhatsApp message and direct click-to-chat URL
        var message = _whatsAppService.GenerateWhatsAppOrderMessage(order, restName, whatsAppPhone);
        var whatsAppUrl = _whatsAppService.GenerateWhatsAppClickToChatUrl(whatsAppPhone, message);

        var response = MapToResponse(order, whatsAppUrl);
        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, response);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<OrderSummaryResponse>> GetOrder(Guid id)
    {
        var order = await _context.Orders
            .Include(o => o.Items)
                .ThenInclude(i => i.Extras)
            .FirstOrDefaultAsync(o => o.Id == id);

        if (order == null)
            return NotFound(new { message = "الطلب غير موجود" });

        var whatsAppSetting = await _context.RestaurantSettings
            .FirstOrDefaultAsync(s => s.Key == "WhatsApp");
        var whatsAppPhone = whatsAppSetting?.Value ?? "201112962692";

        var nameSetting = await _context.RestaurantSettings
            .FirstOrDefaultAsync(s => s.Key == "RestaurantNameAr");
        var restName = nameSetting?.Value ?? "بيتزا أولاد الشيخ";

        var message = _whatsAppService.GenerateWhatsAppOrderMessage(order, restName, whatsAppPhone);
        var whatsAppUrl = _whatsAppService.GenerateWhatsAppClickToChatUrl(whatsAppPhone, message);

        return Ok(MapToResponse(order, whatsAppUrl));
    }

    [Authorize]
    [HttpGet]
    public async Task<ActionResult<IEnumerable<OrderSummaryResponse>>> GetOrders(
        [FromQuery] OrderStatus? status = null,
        [FromQuery] string? search = null,
        [FromQuery] DateTime? fromDate = null,
        [FromQuery] DateTime? toDate = null)
    {
        var query = _context.Orders
            .Include(o => o.Items)
                .ThenInclude(i => i.Extras)
            .AsQueryable();

        if (status.HasValue)
        {
            query = query.Where(o => o.Status == status.Value);
        }

        if (fromDate.HasValue)
        {
            query = query.Where(o => o.CreatedAt >= fromDate.Value);
        }

        if (toDate.HasValue)
        {
            query = query.Where(o => o.CreatedAt <= toDate.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.ToLower().Trim();
            query = query.Where(o =>
                o.OrderReference.ToLower().Contains(s) ||
                o.CustomerName.ToLower().Contains(s) ||
                o.CustomerPhone.Contains(s) ||
                o.Area.ToLower().Contains(s));
        }

        var orders = await query
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();

        var list = orders.Select(o => MapToResponse(o, string.Empty)).ToList();
        return Ok(list);
    }

    [Authorize]
    [HttpPatch("{id}/status")]
    public async Task<IActionResult> UpdateOrderStatus(Guid id, [FromBody] UpdateOrderStatusRequest request)
    {
        var order = await _context.Orders.FindAsync(id);
        if (order == null)
            return NotFound(new { message = "الطلب غير موجود" });

        order.Status = request.Status;
        order.UpdatedAt = DateTime.UtcNow;

        if (!string.IsNullOrWhiteSpace(request.Notes))
        {
            order.Notes = $"{order.Notes} | [ملاحظة الإدارة]: {request.Notes}".Trim(' ', '|');
        }

        await _context.SaveChangesAsync();

        return Ok(new
        {
            order.Id,
            order.OrderReference,
            order.Status,
            StatusAr = GetStatusArabic(order.Status),
            order.UpdatedAt
        });
    }

    private static OrderSummaryResponse MapToResponse(Order order, string whatsAppUrl)
    {
        return new OrderSummaryResponse(
            Id: order.Id,
            OrderReference: order.OrderReference,
            CustomerName: order.CustomerName,
            CustomerPhone: order.CustomerPhone,
            DeliveryAddress: order.DeliveryAddress,
            Area: order.Area,
            OrderType: order.OrderType,
            PaymentMethod: order.PaymentMethod,
            Notes: order.Notes,
            Latitude: order.Latitude,
            Longitude: order.Longitude,
            Subtotal: order.Subtotal,
            DeliveryFee: order.DeliveryFee,
            Discount: order.Discount,
            TotalAmount: order.TotalAmount,
            Status: order.Status,
            FormattedStatusAr: GetStatusArabic(order.Status),
            WhatsAppUrl: whatsAppUrl,
            CreatedAt: order.CreatedAt,
            Items: order.Items.Select(i => new OrderItemResponse(
                Id: i.Id,
                ProductNameAr: i.ProductNameAr,
                ProductNameEn: i.ProductNameEn,
                SelectedSizeNameAr: i.SelectedSizeNameAr,
                SelectedSizePrice: i.SelectedSizePrice,
                Quantity: i.Quantity,
                UnitPrice: i.UnitPrice,
                TotalPrice: i.TotalPrice,
                Notes: i.Notes,
                Extras: i.Extras.Select(e => new OrderItemExtraResponse(e.Id, e.ExtraNameAr, e.ExtraPrice)).ToList()
            )).ToList()
        );
    }

    private static string GetStatusArabic(OrderStatus status) => status switch
    {
        OrderStatus.Pending => "قيد الانتظار (في انتظار تأكيد واتساب)",
        OrderStatus.Confirmed => "تم تأكيد الطلب",
        OrderStatus.Preparing => "جاري تجهيز الطلب في المطبخ",
        OrderStatus.OutForDelivery => "في الطريق مع مندوب التوصيل",
        OrderStatus.Delivered => "تم التوصيل بنجاح",
        OrderStatus.Cancelled => "طلب ملغي",
        _ => "غير محدد"
    };
}
