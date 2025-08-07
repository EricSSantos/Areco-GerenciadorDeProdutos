using GerenciadorDeProdutos.Domain.Interfaces.Repositories;
using GerenciadorDeProdutos.Infrastructure.Data.Context;

namespace GerenciadorDeProdutos.Infrastructure.Data.Repositories
{
    public class UnitOfWork : IUnitOfWork, IAsyncDisposable
    {
        private readonly AppDbContext _context;
        private IProductRepository? _productRepository;

        public UnitOfWork(AppDbContext context)
        {
            _context = context;
        }

        public IProductRepository ProductRepository =>
            _productRepository ??= new ProductRepository(_context);

        public async Task SaveChanges(CancellationToken cancellationToken = default)
        {
            await _context.SaveChangesAsync(cancellationToken);
        }

        public async ValueTask DisposeAsync()
        {
            await _context.DisposeAsync();
        }
    }
}
