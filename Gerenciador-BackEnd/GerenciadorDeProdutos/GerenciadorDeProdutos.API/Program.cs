using GerenciadorDeProdutos.API.Configurations;

var builder = WebApplication.CreateBuilder(args);

builder.AddDatabase();
builder.AddDependencies();
builder.AddCors();
builder.AddSwagger();

builder.Services.AddControllers();
builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.UseSwagger();
app.UseExceptionHandling();
app.UseCors();

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
