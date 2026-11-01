using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PizzaAwladAlsheikh.API.Data;
using PizzaAwladAlsheikh.API.DTOs;
using PizzaAwladAlsheikh.API.Services;

namespace PizzaAwladAlsheikh.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ITokenService _tokenService;

    public AuthController(AppDbContext context, ITokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        var user = await _context.AdminUsers
            .FirstOrDefaultAsync(u => u.Username.ToLower() == request.Username.ToLower() && u.IsActive);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { message = "اسم المستخدم أو كلمة المرور غير صحيحة" });
        }

        var token = _tokenService.GenerateToken(user);
        var expiresAt = DateTime.UtcNow.AddDays(7);

        return Ok(new LoginResponse(
            Token: token,
            Username: user.Username,
            Email: user.Email,
            Role: user.Role,
            ExpiresAt: expiresAt
        ));
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<ActionResult> GetCurrentAdmin()
    {
        var username = User.Identity?.Name;
        var user = await _context.AdminUsers
            .FirstOrDefaultAsync(u => u.Username == username);

        if (user == null)
            return NotFound();

        return Ok(new
        {
            user.Id,
            user.Username,
            user.Email,
            user.Role,
            user.CreatedAt
        });
    }
}
