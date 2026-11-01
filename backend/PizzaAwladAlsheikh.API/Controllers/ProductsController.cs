using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PizzaAwladAlsheikh.API.Data;
using PizzaAwladAlsheikh.API.DTOs;
using PizzaAwladAlsheikh.API.Models;

namespace PizzaAwladAlsheikh.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly AppDbContext _context;

    public ProductsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts(
        [FromQuery] Guid? categoryId = null,
        [FromQuery] string? search = null,
        [FromQuery] bool? featuredOnly = null,
        [FromQuery] bool? bestSellersOnly = null,
        [FromQuery] bool includeUnavailable = false)
    {
        var query = _context.Products
            .Include(p => p.Category)
            .Include(p => p.Sizes)
            .Include(p => p.Extras)
            .AsQueryable();

        if (!includeUnavailable)
        {
            query = query.Where(p => p.IsAvailable);
        }

        if (categoryId.HasValue)
        {
            query = query.Where(p => p.CategoryId == categoryId.Value);
        }

        if (featuredOnly == true)
        {
            query = query.Where(p => p.IsFeatured);
        }

        if (bestSellersOnly == true)
        {
            query = query.Where(p => p.IsBestSeller);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.ToLower().Trim();
            query = query.Where(p =>
                p.NameAr.ToLower().Contains(s) ||
                p.NameEn.ToLower().Contains(s) ||
                p.DescriptionAr.ToLower().Contains(s) ||
                p.DescriptionEn.ToLower().Contains(s));
        }

        var products = await query.OrderByDescending(p => p.IsFeatured)
            .ThenBy(p => p.NameAr)
            .ToListAsync();

        return Ok(products);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(Guid id)
    {
        var product = await _context.Products
            .Include(p => p.Category)
            .Include(p => p.Sizes)
            .Include(p => p.Extras)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (product == null)
            return NotFound(new { message = "الصنف غير موجود" });

        return Ok(product);
    }

    [Authorize]
    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct([FromBody] CreateProductRequest request)
    {
        var category = await _context.Categories.FindAsync(request.CategoryId);
        if (category == null)
            return BadRequest(new { message = "القسم المحدد غير موجود" });

        var product = new Product
        {
            Id = Guid.NewGuid(),
            CategoryId = request.CategoryId,
            NameAr = request.NameAr,
            NameEn = request.NameEn,
            DescriptionAr = request.DescriptionAr ?? string.Empty,
            DescriptionEn = request.DescriptionEn ?? string.Empty,
            ImageUrl = request.ImageUrl ?? string.Empty,
            BasePrice = request.BasePrice,
            IsAvailable = request.IsAvailable,
            IsSampleRequiringAdminConfirmation = request.IsSampleRequiringAdminConfirmation,
            PreparationNotes = request.PreparationNotes ?? string.Empty,
            IsFeatured = request.IsFeatured,
            IsBestSeller = request.IsBestSeller,
            CreatedAt = DateTime.UtcNow
        };

        if (request.Sizes != null && request.Sizes.Any())
        {
            foreach (var s in request.Sizes)
            {
                product.Sizes.Add(new ProductSize
                {
                    Id = Guid.NewGuid(),
                    ProductId = product.Id,
                    NameAr = s.NameAr,
                    NameEn = s.NameEn,
                    Price = s.Price,
                    IsDefault = s.IsDefault
                });
            }
        }

        if (request.Extras != null && request.Extras.Any())
        {
            foreach (var e in request.Extras)
            {
                product.Extras.Add(new ProductExtra
                {
                    Id = Guid.NewGuid(),
                    ProductId = product.Id,
                    NameAr = e.NameAr,
                    NameEn = e.NameEn,
                    Price = e.Price,
                    IsAvailable = e.IsAvailable
                });
            }
        }

        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
    }

    [Authorize]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(Guid id, [FromBody] UpdateProductRequest request)
    {
        var product = await _context.Products
            .Include(p => p.Sizes)
            .Include(p => p.Extras)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (product == null)
            return NotFound(new { message = "الصنف غير موجود" });

        product.CategoryId = request.CategoryId;
        product.NameAr = request.NameAr;
        product.NameEn = request.NameEn;
        product.DescriptionAr = request.DescriptionAr;
        product.DescriptionEn = request.DescriptionEn;
        product.ImageUrl = request.ImageUrl;
        product.BasePrice = request.BasePrice;
        product.IsAvailable = request.IsAvailable;
        product.IsSampleRequiringAdminConfirmation = request.IsSampleRequiringAdminConfirmation;
        product.PreparationNotes = request.PreparationNotes;
        product.IsFeatured = request.IsFeatured;
        product.IsBestSeller = request.IsBestSeller;

        // Update Sizes
        _context.ProductSizes.RemoveRange(product.Sizes);
        if (request.Sizes != null)
        {
            foreach (var s in request.Sizes)
            {
                product.Sizes.Add(new ProductSize
                {
                    Id = Guid.NewGuid(),
                    ProductId = product.Id,
                    NameAr = s.NameAr,
                    NameEn = s.NameEn,
                    Price = s.Price,
                    IsDefault = s.IsDefault
                });
            }
        }

        // Update Extras
        _context.ProductExtras.RemoveRange(product.Extras);
        if (request.Extras != null)
        {
            foreach (var e in request.Extras)
            {
                product.Extras.Add(new ProductExtra
                {
                    Id = Guid.NewGuid(),
                    ProductId = product.Id,
                    NameAr = e.NameAr,
                    NameEn = e.NameEn,
                    Price = e.Price,
                    IsAvailable = e.IsAvailable
                });
            }
        }

        await _context.SaveChangesAsync();
        return Ok(product);
    }

    [Authorize]
    [HttpPatch("{id}/toggle-availability")]
    public async Task<IActionResult> ToggleAvailability(Guid id)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null)
            return NotFound(new { message = "الصنف غير موجود" });

        product.IsAvailable = !product.IsAvailable;
        await _context.SaveChangesAsync();

        return Ok(new { product.Id, product.IsAvailable });
    }

    [Authorize]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(Guid id)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null)
            return NotFound(new { message = "الصنف غير موجود" });

        _context.Products.Remove(product);
        await _context.SaveChangesAsync();

        return Ok(new { message = "تم حذف الصنف بنجاح" });
    }
}
