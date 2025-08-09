using GerenciadorDeProdutos.Domain.Entities;

namespace GerenciadorDeProdutos.Domain.Interfaces.Repositories
{
    public interface IBaseRepository<T> where T : Entity
    {
        Task<T> Add(T entity, CancellationToken cancellationToken = default);
        Task<T> Update(T entity, CancellationToken cancellationToken = default);
        Task<bool> Delete(Guid id, CancellationToken cancellationToken = default);
        Task<T?> GetById(Guid id, CancellationToken cancellationToken = default);
        IQueryable<T> GetAll();
    }
}
