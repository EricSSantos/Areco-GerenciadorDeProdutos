using GerenciadorDeProdutos.Domain.Entities;
using GerenciadorDeProdutos.Domain.Interfaces.Repositories;
using GerenciadorDeProdutos.Infrastructure.Data.Context;

namespace GerenciadorDeProdutos.Infrastructure.Data.Repositories
{
    public class ProductRepository : BaseRepository<Product>, IProductRepository
    {
        public ProductRepository(AppDbContext context)
            : base(context)
        { }
    }
}
