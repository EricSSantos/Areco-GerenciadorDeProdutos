using GerenciadorDeProdutos.Domain.Commons.Settings;
using Microsoft.OpenApi.Models;

public static class SwaggerConfig
{
    public static void AddSwagger(this WebApplicationBuilder builder)
    {
        var appSettings = builder.Configuration
            .GetSection("App")
            .Get<AppSettings>();

        builder.Services.AddSwaggerGen(c =>
        {
            foreach (var (versionKey, versionInfo) in appSettings.Versions)
            {
                c.SwaggerDoc(versionKey, new OpenApiInfo
                {
                    Title = versionInfo.Name,
                    Version = versionKey,
                    Description = versionInfo.Description
                });
            }
        });
    }


    public static void UseSwagger(this WebApplication app)
    {
        var appSettings = app.Services.GetRequiredService<AppSettings>();

        SwaggerBuilderExtensions.UseSwagger(app);
        app.UseSwaggerUI(c =>
        {
            foreach (var (versionKey, versionInfo) in appSettings.Versions)
            {
                c.SwaggerEndpoint($"/swagger/{versionKey}/swagger.json", versionInfo.Name);
            }

            c.DefaultModelsExpandDepth(-1);
            c.RoutePrefix = string.Empty;
            c.ConfigObject.AdditionalItems["withCredentials"] = true;
        });
    }
}
