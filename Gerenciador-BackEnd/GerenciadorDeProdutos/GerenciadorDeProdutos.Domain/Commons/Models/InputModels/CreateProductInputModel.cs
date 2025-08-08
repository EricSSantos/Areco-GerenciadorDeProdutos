namespace GerenciadorDeProdutos.Domain.Commons.Models.InputModels
{
    public sealed record CreateProductInputModel(
        string Name,
        string? Description,
        decimal Price,
        int Stock
    );
}
