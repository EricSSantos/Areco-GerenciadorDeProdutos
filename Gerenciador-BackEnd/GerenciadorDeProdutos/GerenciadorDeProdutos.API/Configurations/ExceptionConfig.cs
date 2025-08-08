using System.Net;
using System.Text.Json;
using GerenciadorDeProdutos.Domain.Commons.Models.ViewModels;

namespace GerenciadorDeProdutos.API.Configurations
{
    public static class ExceptionConfig
    {
        public static void UseExceptionHandling(this WebApplication app)
        {
            app.UseMiddleware<ExceptionMiddleware>();
        }

        private sealed class ExceptionMiddleware
        {
            private readonly RequestDelegate _next;
            private readonly IHostEnvironment _env;

            public ExceptionMiddleware(
                RequestDelegate next,
                IHostEnvironment env)
            {
                _next = next;
                _env = env;
            }

            public async Task InvokeAsync(HttpContext context)
            {
                try
                {
                    await _next(context);
                }
                catch (Exception ex)
                {
                    var isDev = _env.IsDevelopment();
                    var message = isDev ? ex.ToString() : ex.Message;

                    var errors = new List<string> { message };

                    await WriteErrorAsync(
                        context,
                        errors,
                        HttpStatusCode.InternalServerError,
                        "Erro interno no servidor"
                    );
                }
            }

            private static async Task WriteErrorAsync(
                HttpContext context,
                IReadOnlyCollection<string> errors,
                HttpStatusCode status,
                string title)
            {
                context.Response.ContentType = "application/json";
                context.Response.StatusCode = (int)status;

                var response = ResponseViewModel<object>.Error(
                    errors: errors,
                    statusCode: status,
                    title: title
                );

                var json = JsonSerializer.Serialize(
                    response,
                    new JsonSerializerOptions
                    {
                        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                        WriteIndented = false
                    });

                await context.Response.WriteAsync(json);
            }
        }
    }
}
