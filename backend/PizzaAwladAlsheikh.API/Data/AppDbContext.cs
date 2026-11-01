using Microsoft.EntityFrameworkCore;
using PizzaAwladAlsheikh.API.Models;

namespace PizzaAwladAlsheikh.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<ProductSize> ProductSizes => Set<ProductSize>();
    public DbSet<ProductExtra> ProductExtras => Set<ProductExtra>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<OrderItemExtra> OrderItemExtras => Set<OrderItemExtra>();
    public DbSet<RestaurantSetting> RestaurantSettings => Set<RestaurantSetting>();
    public DbSet<AdminUser> AdminUsers => Set<AdminUser>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Product - Category
        modelBuilder.Entity<Product>()
            .HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        // Product - Sizes
        modelBuilder.Entity<ProductSize>()
            .HasOne(s => s.Product)
            .WithMany(p => p.Sizes)
            .HasForeignKey(s => s.ProductId)
            .OnDelete(DeleteBehavior.Cascade);

        // Product - Extras
        modelBuilder.Entity<ProductExtra>()
            .HasOne(e => e.Product)
            .WithMany(p => p.Extras)
            .HasForeignKey(e => e.ProductId)
            .OnDelete(DeleteBehavior.Cascade);

        // Order - OrderItems
        modelBuilder.Entity<OrderItem>()
            .HasOne(i => i.Order)
            .WithMany(o => o.Items)
            .HasForeignKey(i => i.OrderId)
            .OnDelete(DeleteBehavior.Cascade);

        // OrderItem - Extras
        modelBuilder.Entity<OrderItemExtra>()
            .HasOne(e => e.OrderItem)
            .WithMany(i => i.Extras)
            .HasForeignKey(e => e.OrderItemId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes for performance
        modelBuilder.Entity<Product>().HasIndex(p => p.CategoryId);
        modelBuilder.Entity<Product>().HasIndex(p => p.IsAvailable);
        modelBuilder.Entity<Order>().HasIndex(o => o.OrderReference).IsUnique();
        modelBuilder.Entity<Order>().HasIndex(o => o.Status);
        modelBuilder.Entity<Order>().HasIndex(o => o.CreatedAt);
        modelBuilder.Entity<AdminUser>().HasIndex(u => u.Username).IsUnique();
    }
}
