namespace GerenciadorDeProdutos.Domain.Commons.Models.InputModels
{
    public sealed record UpdateProductInputModel(
        Guid Id,
        string Name,
        string? Description,
        decimal Price,
        int Stock
    );
}
