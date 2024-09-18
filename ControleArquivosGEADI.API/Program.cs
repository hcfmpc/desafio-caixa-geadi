using Microsoft.EntityFrameworkCore;
using ControleArquivosGEADI.API.DbContexts;
using ControleArquivosGEADI.API.EndpointHandlers;
using ControleArquivosGEADI.API.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<ControleDboContext>(
    options => options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"))
    );

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

builder.Services.AddControllers();
builder.Services.AddSwaggerGen();

var app = builder.Build();

//Criação do aplicativo

//app.MapGet("/", () => "Produção temática Elias Jácome - PSI MASTER GEADI - API C# NET8");

app.RegisterArquivosEndpoints();
app.RegisterLotesEndpoints();
app.RegisterCapturasEndpoints();

app.UseSwagger();
app.UseSwaggerUI();

app.Run();
