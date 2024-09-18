using CsvHelper;
using CsvHelper.Configuration;
using Microsoft.EntityFrameworkCore;
using ControleArquivosGEADI.API.DbContexts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http.HttpResults;
using AutoMapper;
using ControleArquivosGEADI.API.Models;
using System.Globalization;
using System.Text.Json;

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

app.MapGet("/arquivos", async Task<Results<NoContent, Ok<IEnumerable<ArquivoDTO>>>>
    (ControleDboContext controleDboContext,
    IMapper mapper,
    [FromQuery(Name = "nome")]string? arquivoNome) =>
{
    var arquivos = await controleDboContext.Aditb001ControleArquivos
                                            .Where(a => arquivoNome == null || a.NoArquivo.ToLower().Contains(arquivoNome.ToLower()))
                                            .ToListAsync();

    if (arquivos.Count <= 0 || arquivos == null)
        return TypedResults.NoContent();
    else
        return TypedResults.Ok(mapper.Map< IEnumerable < ArquivoDTO >>(arquivos));
    
});

app.MapGet("/arquivo/{id:int}", async (
    ControleDboContext controleDboContext, 
    IMapper mapper,
    int id) =>
{
    return mapper.Map<ArquivoDTO>(await controleDboContext.Aditb001ControleArquivos.FirstOrDefaultAsync(a => a.NuId == id));
});

app.MapGet("/lotes", async Task<Results<NoContent, Ok<IEnumerable<LoteDTO>>>>
    (ControleDboContext controleDboContext,
    IMapper mapper) =>
{
    var lotes = await controleDboContext.Aditb002LoteArquivos.ToListAsync();

    if (lotes.Count <= 0 || lotes == null)
        return TypedResults.NoContent();
    else
        return TypedResults.Ok(mapper.Map<IEnumerable<LoteDTO>>(lotes));

});

app.MapGet("/lote/{id:int}", async Task<Results<NoContent, Ok<LoteDTO>>>
    (ControleDboContext controleDboContext,
    IMapper mapper,
    int id) =>
{
    var lote = await controleDboContext.Aditb002LoteArquivos.FirstOrDefaultAsync(a => a.NuId == id);

    if (lote == null)
        return TypedResults.NoContent();
    else
        return TypedResults.Ok(mapper.Map<LoteDTO>(lote));

});

app.MapPost("/mapearpasta", async (
    ControleDboContext controleDboContext,
    IMapper mapper,
    string pasta) =>
{

    if (!Directory.Exists(pasta))
        return Results.NotFound("Pasta não encontrada");

    var dataLog = DateTime.Now;
    var arquivos = Directory.GetFiles(pasta)
                         .Select(file => new
                         {
                             Name = Path.GetFileName(file),
                             Tamanho = new FileInfo(file).Length,
                             Local = file,
                             DataCriacao = File.GetCreationTime(file),
                             DataModificacao = File.GetLastWriteTime(file),
                             DataLog = dataLog
                         });

    if (arquivos.Count() <= 0 || arquivos == null)
        return Results.NotFound("Nenhum arquivo encontrado na pasta");

    Aditb002LoteArquivo aditb002LoteArquivo = new Aditb002LoteArquivo();

    aditb002LoteArquivo.DtCriacao = dataLog;
    aditb002LoteArquivo.QtArquivos = arquivos.Count();

    List<Aditb001ControleArquivo> aditb001ControleArquivos = new List<Aditb001ControleArquivo>();

    foreach (var item in arquivos)
    {
        Aditb001ControleArquivo arquivo = new Aditb001ControleArquivo();
        arquivo.NoArquivo = item.Name;
        arquivo.NoLocal = item.Local;
        arquivo.QtBytes = item.Tamanho;
        arquivo.DtCriacao = item.DataCriacao;
        arquivo.DtModificacao = item.DataModificacao;
        arquivo.DtLog = item.DataLog;
        aditb001ControleArquivos.Add(arquivo);
    }

    //controleDboContext.AddRange(aditb001ControleArquivos);
    aditb002LoteArquivo.Aditb001ControleArquivos = new List<Aditb001ControleArquivo>(aditb001ControleArquivos);
    controleDboContext.Add(aditb002LoteArquivo);

    await controleDboContext.SaveChangesAsync();

    
    return TypedResults.Created($"https://localhost:5001/lote/{aditb002LoteArquivo.NuId}", mapper.Map<LoteDTO>(aditb002LoteArquivo));
});

app.MapPost("/etlbasemensal", async (
    [FromServices] ControleDboContext controleDboContext,
    string pasta) =>
{
    if (!Directory.Exists(pasta))
        return Results.NotFound("Pasta não encontrada");

    var csvFilePath = Path.Combine(pasta, "BASE_MENSAL.csv");

    if (!File.Exists(csvFilePath))
        return Results.NotFound("Arquivo BASE_MENSAL.csv não encontrado na pasta");

    var csvData = new List<Aditb003BaseMensalEtl>();
    using (var reader = new StreamReader(csvFilePath))
    using (var csv = new CsvReader(reader, new CsvConfiguration(CultureInfo.InvariantCulture)
    {
        Delimiter = ";",
        HasHeaderRecord = true // Ignorar a primeira linha (cabeçalho)
    }))
    {
        csv.Context.RegisterClassMap<Aditb003BaseMensalEtlMap>();
        csvData = csv.GetRecords<Aditb003BaseMensalEtl>().ToList();
    }

    await controleDboContext.Aditb003BaseMensalEtls.AddRangeAsync(csvData);
    await controleDboContext.SaveChangesAsync();

    await controleDboContext.Database.ExecuteSqlRawAsync("EXEC [dbo].[adisp001_executa_update_base_mensal]");

    return Results.Ok("Dados carregados com sucesso para ETL");
});

app.UseSwagger();
app.UseSwaggerUI();

app.Run();
