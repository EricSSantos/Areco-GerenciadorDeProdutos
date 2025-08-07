using GerenciadorDeProdutos.Domain.Commons.Settings;
using GerenciadorDeProdutos.Infrastructure.Data.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace GerenciadorDeProdutos.API.Configurations
{
    public static class DatabaseConfig
    {
        public static void AddDatabase(this WebApplicationBuilder builder)
        {
            builder.AddPostgreSql();
        }

        private static void AddPostgreSql(this WebApplicationBuilder builder)
        {
            builder.Services.AddDbContext<AppDbContext>((sp, options) =>
            {
                var settings = sp.GetRequiredService<IOptions<DatabaseSettings>>().Value;
                var connectionString = settings.Postgres.ConnectionString;

                if (string.IsNullOrWhiteSpace(connectionString))
                    throw new InvalidOperationException("A string de conexão do PostgreSQL não foi definida.");

                options.UseNpgsql(connectionString, npgsql =>
                    npgsql.MigrationsAssembly(typeof(AppDbContext).Assembly.FullName));
            });
        }
    }
}
