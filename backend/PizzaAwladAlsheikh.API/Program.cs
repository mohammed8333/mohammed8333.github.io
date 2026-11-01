using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PizzaAwladAlsheikh.API.Data;
using PizzaAwladAlsheikh.API.Services;

var builder = WebApplication.CreateBuilder(args);

// Add Database Context (PostgreSQL or SQLite based on configuration)
var dbProvider = builder.Configuration["DatabaseProvider"] ?? "Sqlite";
var pgConn = builder.Configuration.GetConnectionString("PostgreSQL");
var sqliteConn = builder.Configuration.GetConnectionString("Sqlite") ?? "Data Source=pizza_awlad_alsheikh.db";

builder.Services.AddDbContext<AppDbContext>(options =>
{
    if (dbProvider.Equals("PostgreSQL", StringComparison.OrdinalIgnoreCase) && !string.IsNullOrWhiteSpace(pgConn))
    {
        options.UseNpgsql(pgConn);
    }
    else
    {
        options.UseSqlite(sqliteConn);
    }
});

// Register Application Services
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IWhatsAppService, WhatsAppService>();

// Configure JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] ?? "PizzaAwladAlsheikhSuperSecureSecretKey20261101_ProductionReadyKey!";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "PizzaAwladAlsheikh";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "PizzaAwladAlsheikhApp";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    };
});

builder.Services.AddAuthorization();

// Configure CORS for Mobile App and Web
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configure Controllers & JSON serialization
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    });

// Configure OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

var app = builder.Build();

// Auto-migrate and seed database on startup
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        await DbInitializer.SeedAsync(context);
        Console.WriteLine("--> [Database] SQLite/Postgres database initialized and seeded successfully.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"--> [Database Error] Could not initialize database: {ex.Message}");
    }
}

// Configure HTTP pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors("AllowAll");

app.UseDefaultFiles();
app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapGet("/api/info", () => Results.Ok(new
{
    Name = "بيتزا أولاد الشيخ API - Pizza Awlad Alsheikh API",
    Version = "1.0.0",
    Status = "Running 24/7",
    Branch = "امتداد شارع الوحدة، المنيرة، إمبابة، الجيزة",
    WhatsApp = "+201112962692",
    Phone = "01112962692"
}));

app.Run();
