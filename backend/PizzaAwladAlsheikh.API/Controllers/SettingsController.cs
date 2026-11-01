using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PizzaAwladAlsheikh.API.Data;
using PizzaAwladAlsheikh.API.DTOs;
using PizzaAwladAlsheikh.API.Models;

namespace PizzaAwladAlsheikh.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SettingsController : ControllerBase
{
    private readonly AppDbContext _context;

    public SettingsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<Dictionary<string, string>>> GetSettings()
    {
        var settings = await _context.RestaurantSettings
            .ToDictionaryAsync(s => s.Key, s => s.Value);

        return Ok(settings);
    }

    [HttpGet("detailed")]
    public async Task<ActionResult<IEnumerable<SettingDto>>> GetDetailedSettings()
    {
        var settings = await _context.RestaurantSettings
            .Select(s => new SettingDto(s.Key, s.Value, s.Description))
            .ToListAsync();

        return Ok(settings);
    }

    [Authorize]
    [HttpPut("{key}")]
    public async Task<IActionResult> UpdateSetting(string key, [FromBody] UpdateSettingRequest request)
    {
        var setting = await _context.RestaurantSettings.FirstOrDefaultAsync(s => s.Key == key);
        if (setting == null)
        {
            setting = new RestaurantSetting
            {
                Key = key,
                Value = request.Value,
                Description = key,
                UpdatedAt = DateTime.UtcNow
            };
            _context.RestaurantSettings.Add(setting);
        }
        else
        {
            setting.Value = request.Value;
            setting.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
        return Ok(new SettingDto(setting.Key, setting.Value, setting.Description));
    }
}
