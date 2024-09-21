using Microsoft.EntityFrameworkCore;
using ControleArquivosGEADI.API.DbContexts;
using ControleArquivosGEADI.API.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<ControleDboContext>(
    options => options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"))
    );

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

builder.Services.AddControllers();
builder.Services.AddSwaggerGen();
builder.Services.AddProblemDetails();

var app = builder.Build();

if(!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler();
}

app.RegisterArquivosEndpoints();
app.RegisterLotesEndpoints();
app.RegisterCapturasEndpoints();

app.UseSwagger();
app.UseSwaggerUI();

app.Run();
