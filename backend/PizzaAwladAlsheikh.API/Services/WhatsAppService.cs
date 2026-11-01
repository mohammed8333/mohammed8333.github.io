using System.Text;
using System.Web;
using PizzaAwladAlsheikh.API.Models;

namespace PizzaAwladAlsheikh.API.Services;

public interface IWhatsAppService
{
    string GenerateWhatsAppOrderMessage(Order order, string restaurantNameAr, string phone);
    string GenerateWhatsAppClickToChatUrl(string phone, string message);
}

public class WhatsAppService : IWhatsAppService
{
    public string GenerateWhatsAppOrderMessage(Order order, string restaurantNameAr, string phone)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"مرحباً مطعم {restaurantNameAr} 🍕");
        sb.AppendLine();
        sb.AppendLine("أريد تأكيد الطلب التالي:");
        sb.AppendLine();
        sb.AppendLine($"رقم الطلب: {order.OrderReference}");
        sb.AppendLine();
        sb.AppendLine("📋 بيانات العميل:");
        sb.AppendLine($"• الاسم: {order.CustomerName}");
        sb.AppendLine($"• الهاتف: {order.CustomerPhone}");
        
        var orderTypeAr = order.OrderType == OrderType.Delivery ? "توصيل للمنزل 🛵" : "استلام من المطعم (تيك أواي) 🛍️";
        sb.AppendLine($"• نوع الطلب: {orderTypeAr}");

        if (order.OrderType == OrderType.Delivery)
        {
            sb.AppendLine($"• العنوان: {order.DeliveryAddress}");
            if (!string.IsNullOrWhiteSpace(order.Area))
            {
                sb.AppendLine($"• المنطقة: {order.Area}");
            }
            if (order.Latitude.HasValue && order.Longitude.HasValue)
            {
                sb.AppendLine($"• الموقع على خرائط جوجل: https://maps.google.com/?q={order.Latitude.Value},{order.Longitude.Value}");
            }
        }

        if (!string.IsNullOrWhiteSpace(order.PaymentMethod))
        {
            sb.AppendLine($"• طريقة الدفع: {order.PaymentMethod}");
        }

        if (!string.IsNullOrWhiteSpace(order.Notes))
        {
            sb.AppendLine($"• ملاحظات خاصة بالطلب: {order.Notes}");
        }

        sb.AppendLine();
        sb.AppendLine("🍽️ الطلبات:");
        
        int index = 1;
        foreach (var item in order.Items)
        {
            sb.AppendLine($"{index}. {item.ProductNameAr}");
            if (!string.IsNullOrWhiteSpace(item.SelectedSizeNameAr))
            {
                sb.AppendLine($"   الحجم: {item.SelectedSizeNameAr}");
            }
            if (item.Extras.Any())
            {
                var extras = string.Join("، ", item.Extras.Select(e => $"{e.ExtraNameAr} (+{e.ExtraPrice:N0} ج)"));
                sb.AppendLine($"   الإضافات: {extras}");
            }
            if (!string.IsNullOrWhiteSpace(item.Notes))
            {
                sb.AppendLine($"   ملاحظات الصنف: {item.Notes}");
            }
            sb.AppendLine($"   الكمية: {item.Quantity}");
            sb.AppendLine($"   السعر: {item.TotalPrice:N2} جنيه");
            sb.AppendLine();
            index++;
        }

        sb.AppendLine("💰 الحساب الإجمالي:");
        sb.AppendLine($"• المجموع الفرعي: {order.Subtotal:N2} جنيه");
        if (order.OrderType == OrderType.Delivery)
        {
            sb.AppendLine($"• رسوم التوصيل: {order.DeliveryFee:N2} جنيه");
        }
        if (order.Discount > 0)
        {
            sb.AppendLine($"• الخصم: {order.Discount:N2}- جنيه");
        }
        sb.AppendLine($"• الإجمالي النهائي: {order.TotalAmount:N2} جنيه مصري");
        sb.AppendLine();
        sb.AppendLine("يرجى تأكيد الطلب ووقت التجهيز والتوصيل. شكراً لكم!");

        return sb.ToString();
    }

    public string GenerateWhatsAppClickToChatUrl(string phone, string message)
    {
        // Normalize phone number (Egyptian numbers: replace leading 0 with 20 or remove +)
        string normalizedPhone = phone.Replace("+", "").Replace(" ", "").Replace("-", "").Trim();
        if (normalizedPhone.StartsWith("01"))
        {
            normalizedPhone = "2" + normalizedPhone;
        }

        string encodedMessage = Uri.EscapeDataString(message);
        return $"https://wa.me/{normalizedPhone}?text={encodedMessage}";
    }
}
