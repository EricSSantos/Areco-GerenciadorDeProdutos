namespace GerenciadorDeProdutos.Domain.Commons.Models.ViewModels
{
    public sealed record ProductViewModel(
        Guid Id,
        int Code,
        string Name,
        string? Description,
        decimal Price,
        int Stock,
        DateTime CreatedAt,
        DateTime? UpdatedAt
    );
}
