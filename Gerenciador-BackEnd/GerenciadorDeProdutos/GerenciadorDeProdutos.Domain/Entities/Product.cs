namespace GerenciadorDeProdutos.Domain.Entities
{
    public class Product : Entity
    {
        public int Code { get; private set; }
        public string Name { get; private set; } = string.Empty;
        public string? Description { get; private set; }
        public decimal Price { get; private set; }
        public int Stock { get; private set; }

        public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; private set; }

        private Product() { }

        public Product(string name, string? description, decimal price, int stock)
        {
            EnsureValidPrice(price);
            EnsureValidStock(stock);

            Name = name;
            Description = description;
            Price = price;
            Stock = stock;
            CreatedAt = DateTime.UtcNow;
        }

        public void Update(string name, string? description, decimal price, int stock)
        {
            EnsureValidPrice(price);
            EnsureValidStock(stock);

            Name = name;
            Description = description;
            Price = price;
            Stock = stock;
            UpdatedAt = DateTime.UtcNow;
        }

        private static void EnsureValidStock(int stock)
        {
            if (stock < 0)
                throw new ArgumentException("O estoque não pode ser negativo.", nameof(stock));
        }

        private static void EnsureValidPrice(decimal price)
        {
            if (price <= 0)
                throw new ArgumentException("O preço deve ser maior que zero.", nameof(price));
        }
    }
}
