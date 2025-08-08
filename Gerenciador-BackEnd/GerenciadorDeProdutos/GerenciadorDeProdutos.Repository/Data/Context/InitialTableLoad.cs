using GerenciadorDeProdutos.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace GerenciadorDeProdutos.Infrastructure.Data.Context
{
    public static class InitialTableLoad
    {
        public static async Task LoadAsync(AppDbContext context)
        {
            await context.Database.MigrateAsync();
            await LoadProductsAsync(context);
        }

        private static async Task LoadProductsAsync(AppDbContext context)
        {
            if (await context.Products.AnyAsync())
                return;

            var items = new List<Product>
            {
                new("Monitor LED 24''", "Monitor Full HD para estação de trabalho", 899.90m, 20),
                new("Teclado Mecânico", "Teclado com teclas silenciosas e layout ABNT2", 249.90m, 50),
                new("Mouse Óptico USB", "Mouse ergonômico com fio", 59.90m, 80),
                new("Suporte para Monitor", "Base ajustável para monitor até 27", 129.90m, 25),
                new("Cadeira Ergonomica", "Cadeira com ajuste lombar e apoio para braço", 1199.00m, 10),
                new("Bloco de Anotações", "Bloco com 200 folhas pautadas", 6.90m, 300),
                new("Grampeador Médio", "Grampeador para até 25 folhas", 29.90m, 100),
                new("Furador de Papel", "Furador metálico para 2 furos", 34.50m, 60),
                new("Envelope Ofício", "Pacote com 100 unidades - branco", 22.90m, 75),
                new("Pasta Suspensa", "Pacote com 10 pastas verdes", 14.90m, 90),
                new("Papel Timbrado A4", "Resma com 500 folhas personalizadas", 59.90m, 40),
                new("Cartucho de Tinta Preto", "Cartucho compatível HP 664", 89.00m, 30),
                new("Cabo HDMI 1.5m", "Cabo para conexão de monitores", 24.90m, 100),
                new("Extensão Elétrica", "Extensão com 5 tomadas e 3 metros", 34.90m, 45),
                new("Relógio de Ponto Eletrônico", "Sistema biométrico com software incluso", 1599.00m, 5),
                new("Projetor Multimídia", "Projetor portátil com entrada HDMI/VGA", 1899.00m, 8),
                new("Telefone IP", "Telefone com display e suporte a VOIP", 249.90m, 15),
                new("Filtro de Linha", "Filtro bivolt com 4 saídas", 27.90m, 60),
                new("Estabilizador 500VA", "Estabilizador bivolt automático", 189.90m, 25),
                new("Notebook Empresarial", "Notebook i5, 8GB RAM, 256GB SSD", 3499.00m, 12)
            };

            context.Products.AddRange(items);
            await context.SaveChangesAsync();
        }
    }
}
