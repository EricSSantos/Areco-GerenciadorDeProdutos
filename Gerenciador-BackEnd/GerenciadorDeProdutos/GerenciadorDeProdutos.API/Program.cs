using GerenciadorDeProdutos.API.Configurations;
using GerenciadorDeProdutos.Infrastructure.Data.Context;

var builder = WebApplication.CreateBuilder(args);

builder.AddDatabase();
builder.AddDependencies();
builder.AddCorsPolicies();
builder.AddSwagger();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();

    using (var scope = app.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await InitialTableLoad.LoadAsync(context);
    }
}

app.UseExceptionHandling();
app.UseSwagger();
app.UseCorsAndHttps();
app.MapControllers();

app.Run();
