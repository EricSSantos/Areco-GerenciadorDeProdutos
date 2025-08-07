namespace GerenciadorDeProdutos.Domain.Commons.Settings
{
    public class DatabaseSettings
    {
        public PostgresSettings Postgres { get; set; } = null!;

        public class PostgresSettings
        {
            public string ConnectionString { get; set; } = null!;
        }
    }
}
