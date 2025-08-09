using GerenciadorDeProdutos.Domain.Entities;
using GerenciadorDeProdutos.Domain.Interfaces.Repositories;
using GerenciadorDeProdutos.Infrastructure.Data.Context;
using Microsoft.EntityFrameworkCore;

namespace GerenciadorDeProdutos.Infrastructure.Data.Repositories
{
    public class BaseRepository<T> : IBaseRepository<T> where T : Entity
    {
        protected readonly AppDbContext _context;

        public BaseRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<T> Add(T entity, CancellationToken cancellationToken = default)
        {
            await _context.Set<T>().AddAsync(entity, cancellationToken);
            return entity;
        }

        public Task<T> Update(T entity, CancellationToken cancellationToken = default)
        {
            _context.Set<T>().Update(entity);
            return Task.FromResult(entity);
        }

        public async Task<bool> Delete(Guid id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Set<T>().FindAsync([id], cancellationToken);

            if (entity is null)
                return false;

            _context.Set<T>().Remove(entity);
            return true;
        }

        public IQueryable<T> GetAll()
        {
            return _context
                .Set<T>()
                .AsNoTracking()
                .AsQueryable();
        }

        public async Task<T?> GetById(Guid id, CancellationToken cancellationToken = default)
        {
            return await _context.Set<T>()
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);
        }
    }
}
