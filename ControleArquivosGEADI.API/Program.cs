using Microsoft.EntityFrameworkCore;
using ControleArquivosGEADI.API.DbContexts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http.HttpResults;
using ControleArquivosGEADI.API.Entities;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<ControleDbContext>(
    options => options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"))
    );

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.MapGet("/arquivos", async Task<Results<NoContent, Ok<List<Arquivo>>>>
    (ControleDbContext controleDbContext, 
    [FromQuery(Name = "nome")]string? arquivoNome) =>
{
    var arquivosEntity = await controleDbContext.Arquivos
                                                .Where(a => arquivoNome == null || a.Nome.ToLower().Contains(arquivoNome.ToLower()))
                                                .ToListAsync();

    if (arquivosEntity.Count <= 0 || arquivosEntity == null)
        return TypedResults.NoContent();
    else
        return TypedResults.Ok(arquivosEntity);
    
});

app.MapGet("/arquivo/{id:int}", async (ControleDbContext controleDbContext, int id) =>
{
    return await controleDbContext.Arquivos.FirstOrDefaultAsync(a => a.Id == id);
});

app.MapGet("/mapearpasta", (string pasta) =>
{

    if (!Directory.Exists(pasta))
    {
        return Results.NotFound("Pasta não encontrada");
    }

    var files = Directory.GetFiles(pasta)
                         .Select(file => new
                         {
                             Name = Path.GetFileName(file),
                             Size = new FileInfo(file).Length,
                             Path = file,
                             CreationDate = File.GetCreationTime(file)
                         });

    if (files.Count() == 0)
    {
        return Results.NotFound("Nenhum arquivo encontrado na pasta");
    }



    return Results.Ok(files);
});

app.Run();
