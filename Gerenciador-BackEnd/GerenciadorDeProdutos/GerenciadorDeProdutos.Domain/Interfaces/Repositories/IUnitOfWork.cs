namespace GerenciadorDeProdutos.Domain.Interfaces.Repositories
{
    public interface IUnitOfWork : IAsyncDisposable
    {
        IProductRepository ProductRepository { get; }
        Task SaveChanges(CancellationToken cancellationToken = default);
    }
}
