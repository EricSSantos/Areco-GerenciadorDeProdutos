using GerenciadorDeProdutos.Domain.Commons.Models.InputModels;
using GerenciadorDeProdutos.Domain.Commons.Models.ViewModels;
using GerenciadorDeProdutos.Domain.Entities;
using GerenciadorDeProdutos.Domain.Interfaces.Repositories;
using GerenciadorDeProdutos.Domain.Interfaces.Services;

namespace GerenciadorDeProdutos.Application.Services
{
    public class ProductService : IProductService
    {
        private readonly IUnitOfWork _unitOfWork;

        public ProductService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ProductViewModel> Add(
            CreateProductInputModel input,
            CancellationToken cancellationToken = default)
        {
            var product = new Product(
                input.Name,
                input.Description,
                input.Price,
                input.Stock
            );

            var newproduct = await _unitOfWork.ProductRepository.Add(product, cancellationToken);

            await _unitOfWork.SaveChanges(cancellationToken);

            return ToViewModel(newproduct);
        }

        public async Task<ProductViewModel> Update(
            UpdateProductInputModel input,
            CancellationToken cancellationToken = default)
        {
            var product = await _unitOfWork.ProductRepository.GetById(input.Id, cancellationToken)
                ?? throw new Exception("Produto não encontrado.");

            product.Update(input.Name, input.Description, input.Price, input.Stock);

            await _unitOfWork.ProductRepository.Update(product, cancellationToken);
            await _unitOfWork.SaveChanges(cancellationToken);

            return ToViewModel(product);
        }

        public async Task<bool> Delete(
            Guid id,
            CancellationToken cancellationToken = default)
        {
            var product = await _unitOfWork.ProductRepository.GetById(id, cancellationToken)
                ?? throw new Exception("Produto não encontrado.");

            var success = await _unitOfWork.ProductRepository.Delete(product.Id, cancellationToken);

            if (success)
                await _unitOfWork.SaveChanges(cancellationToken);

            return success;
        }

        public async Task<IEnumerable<ProductViewModel>> GetAll(
            CancellationToken cancellationToken = default)
        {
            var products = _unitOfWork.ProductRepository.GetAll().ToList();
            return await Task.FromResult(products.Select(ToViewModel));
        }

        public async Task<ProductViewModel?> GetById(
            Guid id,
            CancellationToken cancellationToken = default)
        {
            var product = await _unitOfWork.ProductRepository.GetById(id, cancellationToken)
                ?? throw new Exception("Produto não encontrado.");

            return ToViewModel(product);
        }

        #region Batch Methods

        public async Task<IEnumerable<ProductViewModel>> AddBatch(
            IEnumerable<CreateProductInputModel> input,
            CancellationToken cancellationToken = default)
        {
            var products = input.Select(i => new Product(i.Name, i.Description, i.Price, i.Stock)).ToList();

            foreach (var product in products)
                await _unitOfWork.ProductRepository.Add(product, cancellationToken);

            await _unitOfWork.SaveChanges(cancellationToken);

            return products.Select(ToViewModel);
        }

        public async Task<IEnumerable<ProductViewModel>> UpdateBatch(
            IEnumerable<UpdateProductInputModel> input,
            CancellationToken cancellationToken = default)
        {
            var products = new List<Product>();

            foreach (var item in input)
            {
                var product = await _unitOfWork.ProductRepository.GetById(item.Id, cancellationToken)
                    ?? throw new Exception($"Produto {item.Id} não encontrado.");

                product.Update(item.Name, item.Description, item.Price, item.Stock);

                await _unitOfWork.ProductRepository.Update(product, cancellationToken);
                products.Add(product);
            }

            await _unitOfWork.SaveChanges(cancellationToken);

            return products.Select(ToViewModel);
        }

        public async Task<int> DeleteBatch(
            IEnumerable<Guid> ids,
            CancellationToken cancellationToken = default)
        {
            var count = 0;

            foreach (var id in ids)
            {
                var product = await _unitOfWork.ProductRepository.GetById(id, cancellationToken)
                    ?? throw new Exception($"Produto {id} não encontrado.");

                var success = await _unitOfWork.ProductRepository.Delete(product.Id, cancellationToken);
                if (success) count++;
            }

            if (count > 0)
                await _unitOfWork.SaveChanges(cancellationToken);

            return count;
        }

        #endregion

        #region Private Methods

        private static ProductViewModel ToViewModel(Product product) =>
            new(
                product.Id,
                product.Code,
                product.Name,
                product.Description,
                product.Price,
                product.Stock,
                product.CreatedAt,
                product.UpdatedAt
            );

        #endregion
    }
}
