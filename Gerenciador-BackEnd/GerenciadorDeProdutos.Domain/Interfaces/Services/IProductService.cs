using GerenciadorDeProdutos.Domain.Commons.Models.InputModels;
using GerenciadorDeProdutos.Domain.Commons.Models.ViewModels;

namespace GerenciadorDeProdutos.Domain.Interfaces.Services
{
    public interface IProductService
    {
        Task<IEnumerable<ProductViewModel>> GetAll(
            CancellationToken cancellationToken = default);

        Task<ProductViewModel?> GetById(
            Guid id,
            CancellationToken cancellationToken = default);

        Task<ProductViewModel> Add(
            CreateProductInputModel input,
            CancellationToken cancellationToken = default);

        Task<ProductViewModel> Update(
            UpdateProductInputModel input,
            CancellationToken cancellationToken = default);

        Task<bool> Delete(
            Guid id,
            CancellationToken cancellationToken = default);

        Task<int> DeleteBatch(
            IEnumerable<Guid> ids,
            CancellationToken cancellationToken = default);
    }
}
