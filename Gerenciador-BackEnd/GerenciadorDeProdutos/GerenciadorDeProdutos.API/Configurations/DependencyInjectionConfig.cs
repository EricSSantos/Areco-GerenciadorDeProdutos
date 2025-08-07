using GerenciadorDeProdutos.Application.Services;
using GerenciadorDeProdutos.Domain.Commons.Settings;
using GerenciadorDeProdutos.Domain.Interfaces.Repositories;
using GerenciadorDeProdutos.Domain.Interfaces.Services;
using GerenciadorDeProdutos.Infrastructure.Data.Repositories;
using Microsoft.Extensions.Options;

namespace GerenciadorDeProdutos.API.Configurations
{
    public static class DependencyInjectionConfig
    {
        public static void AddDependencies(this WebApplicationBuilder builder)
        {
            var services = builder.Services;

            services.AddSettings(builder.Configuration);
            services.AddRepositories();
            services.AddServices();
        }

        private static IServiceCollection AddServices(this IServiceCollection services)
        {
            services.AddScoped<IProductService, ProductService>();

            return services;
        }

        private static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped<IUnitOfWork, UnitOfWork>();
            services.AddScoped(typeof(IBaseRepository<>), typeof(BaseRepository<>));

            services.AddScoped<IProductRepository, ProductRepository>();

            return services;
        }

        private static IServiceCollection AddSettings(this IServiceCollection services, IConfiguration config)
        {
            services.Configure<AppSettings>(config.GetSection("App"));
            services.Configure<DatabaseSettings>(config.GetSection("Database"));
            services.Configure<CorsSettings>(config.GetSection("Cors"));

            services.AddSingleton(sp => sp.GetRequiredService<IOptions<AppSettings>>().Value);
            services.AddSingleton(sp => sp.GetRequiredService<IOptions<CorsSettings>>().Value);
            services.AddSingleton(sp => sp.GetRequiredService<IOptions<DatabaseSettings>>().Value);

            return services;
        }
    }
}
