using GerenciadorDeProdutos.API.Configurations;

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
}

app.UseExceptionHandling();
app.UseSwagger();
app.UseCorsAndHttps();
app.MapControllers();

app.Run();
