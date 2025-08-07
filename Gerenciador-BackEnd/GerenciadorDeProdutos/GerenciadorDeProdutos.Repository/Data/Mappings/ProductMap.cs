using GerenciadorDeProdutos.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace GerenciadorDeProdutos.Infrastructure.Data.Mappings
{
    public class ProductMap : IEntityTypeConfiguration<Product>
    {
        public void Configure(EntityTypeBuilder<Product> builder)
        {
            builder.ToTable("products");

            builder.HasKey(p => p.Id);

            builder.Property(p => p.Id)
                .HasColumnName("id")
                .IsRequired();

            builder.Property(p => p.Code)
                .HasColumnName("code")
                .IsRequired()
                .ValueGeneratedOnAdd();

            builder.HasIndex(p => p.Code).IsUnique();

            builder.Property(p => p.Name)
                .HasColumnName("name")
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(p => p.Description)
                .HasColumnName("description")
                .HasMaxLength(255);

            builder.Property(p => p.Price)
                .HasColumnName("price")
                .IsRequired()
                .HasColumnType("decimal(10,2)");

            builder.Property(p => p.Stock)
                .HasColumnName("stock")
                .IsRequired();

            builder.Property(p => p.CreatedAt)
                .HasColumnName("created_at")
                .IsRequired();

            builder.Property(p => p.UpdatedAt)
                .HasColumnName("updated_at");
        }
    }
}
