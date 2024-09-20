using Microsoft.EntityFrameworkCore;
using ControleArquivosGEADI.API.DbContexts;
using ControleArquivosGEADI.API.Extensions;
using System.Net;

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
    //app.UseExceptionHandler(configureApplicationBuilder =>
    //{
    //    configureApplicationBuilder.Run(
    //    async context =>
    //    {
    //        context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
    //        context.Response.ContentType = "text/html";
    //        await context.Response.WriteAsync("An unexpected problem happened.");
    //    });
    //});
}

app.RegisterArquivosEndpoints();
app.RegisterLotesEndpoints();
app.RegisterCapturasEndpoints();

app.UseSwagger();
app.UseSwaggerUI();

app.Run();
