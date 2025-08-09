using GerenciadorDeProdutos.Domain.Commons.Settings;

namespace GerenciadorDeProdutos.API.Configurations
{
    public static class CorsConfig
    {
        private const string DevPolicy = "DevPolicy";
        private const string ProdPolicy = "ProdPolicy";

        public static void AddCorsPolicies(this WebApplicationBuilder builder)
        {
            var corsSettings = builder.Configuration
                .GetSection("Cors")
                .Get<CorsSettings>() ?? new CorsSettings();

            builder.Services.AddCors(options =>
            {
                options.AddPolicy(DevPolicy, policy =>
                    policy
                        .WithOrigins(corsSettings.DevelopmentOrigins.ToArray())
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials());
                options.AddPolicy(ProdPolicy, policy =>
                    policy
                        .WithOrigins(corsSettings.ProductionOrigins.ToArray())
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials());
            });
        }

        public static void UseCorsAndHttps(this WebApplication app)
        {
            var env = app.Services.GetRequiredService<IWebHostEnvironment>();

            app.UseHttpsRedirection();
            app.UseRouting();

            app.UseCors(env.IsProduction()
                ? ProdPolicy
                : DevPolicy);
        }
    }
}
