using ControleArquivosGEADI.API.DbContexts;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddDbContext<ControleDbContext>(
    options => options.UseSqlServer(builder.Configuration.GetConnectionString("ConnectionStrings:DefaultConnection"))
    );

var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.Run();
