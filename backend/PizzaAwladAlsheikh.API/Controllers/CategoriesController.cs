using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PizzaAwladAlsheikh.API.Data;
using PizzaAwladAlsheikh.API.DTOs;
using PizzaAwladAlsheikh.API.Models;

namespace PizzaAwladAlsheikh.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly AppDbContext _context;

    public CategoriesController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<CategoryDto>>> GetCategories([FromQuery] bool includeInactive = false)
    {
        var query = _context.Categories.AsQueryable();
        if (!includeInactive)
        {
            query = query.Where(c => c.IsActive);
        }

        var categories = await query
            .OrderBy(c => c.DisplayOrder)
            .Select(c => new CategoryDto(
                c.Id,
                c.NameAr,
                c.NameEn,
                c.Icon,
                c.DisplayOrder,
                c.IsActive
            ))
            .ToListAsync();

        return Ok(categories);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Category>> GetCategory(Guid id)
    {
        var category = await _context.Categories
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null)
            return NotFound(new { message = "القسم غير موجود" });

        return Ok(category);
    }

    [Authorize]
    [HttpPost]
    public async Task<ActionResult<Category>> CreateCategory([FromBody] CategoryDto dto)
    {
        var category = new Category
        {
            Id = Guid.NewGuid(),
            NameAr = dto.NameAr,
            NameEn = dto.NameEn,
            Icon = string.IsNullOrWhiteSpace(dto.Icon) ? "local_pizza" : dto.Icon,
            DisplayOrder = dto.DisplayOrder,
            IsActive = dto.IsActive,
            CreatedAt = DateTime.UtcNow
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetCategory), new { id = category.Id }, category);
    }

    [Authorize]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateCategory(Guid id, [FromBody] CategoryDto dto)
    {
        var category = await _context.Categories.FindAsync(id);
        if (category == null)
            return NotFound(new { message = "القسم غير موجود" });

        category.NameAr = dto.NameAr;
        category.NameEn = dto.NameEn;
        category.Icon = dto.Icon;
        category.DisplayOrder = dto.DisplayOrder;
        category.IsActive = dto.IsActive;

        await _context.SaveChangesAsync();
        return Ok(category);
    }

    [Authorize]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCategory(Guid id)
    {
        var category = await _context.Categories
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null)
            return NotFound(new { message = "القسم غير موجود" });

        if (category.Products.Any())
        {
            // Soft delete/deactivate if it has products
            category.IsActive = false;
            await _context.SaveChangesAsync();
            return Ok(new { message = "تم إلغاء تنشيط القسم لوجود أصناف مرتبطة به" });
        }

        _context.Categories.Remove(category);
        await _context.SaveChangesAsync();

        return Ok(new { message = "تم حذف القسم بنجاح" });
    }
}
