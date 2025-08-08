using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace GerenciadorDeProdutos.Infrastructure.Data.Context.Migrations
{
    /// <inheritdoc />
    public partial class Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "products",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    price = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    stock = table.Column<int>(type: "integer", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_products", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_products_code",
                table: "products",
                column: "code",
                unique: true);

            var now = DateTime.UtcNow;

            migrationBuilder.InsertData(
                table: "products",
                columns: new[] { "id", "name", "description", "price", "stock", "created_at", "updated_at" },
                values: new object[,]
                {
                    { Guid.NewGuid(), "Monitor LED 24", "Monitor Full HD para estação de trabalho", 899.90m, 20, now, null },
                    { Guid.NewGuid(), "Teclado Mecânico", "Teclado com teclas silenciosas e layout ABNT2", 249.90m, 50, now, null },
                    { Guid.NewGuid(), "Mouse Óptico USB", "Mouse ergonômico com fio", 59.90m, 80, now, null },
                    { Guid.NewGuid(), "Suporte para Monitor", "Base ajustável para monitor até 27\"", 129.90m, 25, now, null },
                    { Guid.NewGuid(), "Cadeira Ergonômica", "Cadeira com ajuste lombar e apoio para braço", 1199.00m, 10, now, null },
                    { Guid.NewGuid(), "Bloco de Anotações", "Bloco com 200 folhas pautadas", 6.90m, 300, now, null },
                    { Guid.NewGuid(), "Grampeador Médio", "Grampeador para até 25 folhas", 29.90m, 100, now, null },
                    { Guid.NewGuid(), "Furador de Papel", "Furador metálico para 2 furos", 34.50m, 60, now, null },
                    { Guid.NewGuid(), "Envelope Ofício", "Pacote com 100 unidades - branco", 22.90m, 75, now, null },
                    { Guid.NewGuid(), "Pasta Suspensa", "Pacote com 10 pastas verdes", 14.90m, 90, now, null },
                    { Guid.NewGuid(), "Papel Timbrado A4", "Resma com 500 folhas personalizadas", 59.90m, 40, now, null },
                    { Guid.NewGuid(), "Cartucho de Tinta Preto", "Cartucho compatível HP 664", 89.00m, 30, now, null },
                    { Guid.NewGuid(), "Cabo HDMI 1.5m", "Cabo para conexão de monitores", 24.90m, 100, now, null },
                    { Guid.NewGuid(), "Extensão Elétrica", "Extensão com 5 tomadas e 3 metros", 34.90m, 45, now, null },
                    { Guid.NewGuid(), "Relógio de Ponto Eletrônico", "Sistema biométrico com software incluso", 1599.00m, 5, now, null },
                    { Guid.NewGuid(), "Projetor Multimídia", "Projetor portátil com entrada HDMI/VGA", 1899.00m, 8, now, null },
                    { Guid.NewGuid(), "Telefone IP", "Telefone com display e suporte a VOIP", 249.90m, 15, now, null },
                    { Guid.NewGuid(), "Filtro de Linha", "Filtro bivolt com 4 saídas", 27.90m, 60, now, null },
                    { Guid.NewGuid(), "Estabilizador 500VA", "Estabilizador bivolt automático", 189.90m, 25, now, null },
                    { Guid.NewGuid(), "Notebook Empresarial", "Notebook i5, 8GB RAM, 256GB SSD", 3499.00m, 12, now, null }
                }
            );
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "products");
        }
    }
}
