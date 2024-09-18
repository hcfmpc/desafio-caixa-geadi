using CsvHelper;
using CsvHelper.Configuration;
using Microsoft.EntityFrameworkCore;
using ControleArquivosGEADI.API.DbContexts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http.HttpResults;
using AutoMapper;
using ControleArquivosGEADI.API.Models;
using System.Globalization;
using ControleArquivosGEADI.API.EndpointHandlers;

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

app.MapGet("/", () => "Produção temática Elias Jácome - PSI MASTER GEADI - API C# NET8");

var arquivosEndpoints = app.MapGroup("/arquivos");
var arquivosComIdEndpoints = arquivosEndpoints.MapGroup("/{arquivoId:int}");
var lotesEndpoints = app.MapGroup("/lotes");
var lotesComIdEndpoints = lotesEndpoints.MapGroup("/{loteId:int}");

arquivosEndpoints.MapGet("", ArquivosHandlers.GetArquivosAsync);
arquivosComIdEndpoints.MapGet("", ArquivosHandlers.GetArquivosComIdAsync);
lotesEndpoints.MapGet("", LotesHandlers.GetListasAsync);
lotesComIdEndpoints.MapGet("", LotesHandlers.GetListasComIdAsync).WithName("GetLotes");
app.MapPost("/mapearpasta", CapturasHandlers.PostMapearArquivosAsync);
app.MapPost("/etlbasemensal", CapturasHandlers.PostCapturaEtlBaseMensalAsync);

app.UseSwagger();
app.UseSwaggerUI();

app.Run();
