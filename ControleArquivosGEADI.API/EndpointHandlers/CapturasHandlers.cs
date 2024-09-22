using AutoMapper;
using ControleArquivosGEADI.API.DbContexts;
using ControleArquivosGEADI.API.Models;
using CsvHelper;
using CsvHelper.Configuration;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Globalization;

namespace ControleArquivosGEADI.API.EndpointHandlers;

public class CapturasHandlers
{
    public static async Task<Results<NotFound<string>, CreatedAtRoute<LoteDTO>>> PostMapearArquivosAsync
    (ControleDboContext controleDboContext,
    IMapper mapper,
    string pasta)
    {

        if (!Directory.Exists(pasta))
            return TypedResults.NotFound<string>("Pasta não encontrada");

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
            return TypedResults.NotFound<string>("Nenhum arquivo encontrado na pasta");

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

        aditb002LoteArquivo.Aditb001ControleArquivos = new List<Aditb001ControleArquivo>(aditb001ControleArquivos);
        controleDboContext.Add(aditb002LoteArquivo);

        await controleDboContext.SaveChangesAsync();

        return TypedResults.CreatedAtRoute(mapper.Map<LoteDTO>(aditb002LoteArquivo), "GetLotes", new { loteId = aditb002LoteArquivo.NuId });
    }

    public static async Task<Results<NotFound<string>, Ok<string>>> PostCapturaEtlBaseMensalAsync
    ([FromServices] ControleDboContext controleDboContext,
    string pasta)
    {
        if (!Directory.Exists(pasta))
            return TypedResults.NotFound("Pasta não encontrada");

        var csvFilePath = Path.Combine(pasta, "BASE_MENSAL.csv");

        if (!File.Exists(csvFilePath))
            return TypedResults.NotFound("Arquivo BASE_MENSAL.csv não encontrado na pasta");

        var csvData = new List<Aditb003BaseMensalEtl>();
        using (var reader = new StreamReader(csvFilePath))
        using (var csv = new CsvReader(
                                        reader, 
                                        new CsvConfiguration(CultureInfo.InvariantCulture)
                                            {
                                                Delimiter = ";",
                                                HasHeaderRecord = true // Ignorar a primeira linha (cabeçalho)
                                            }
                                      )
        )
        {
            csv.Context.RegisterClassMap<Aditb003BaseMensalEtlMap>();
            csvData = csv.GetRecords<Aditb003BaseMensalEtl>().ToList();
        }

        await controleDboContext.Aditb003BaseMensalEtls.AddRangeAsync(csvData);
        await controleDboContext.SaveChangesAsync();

        await controleDboContext.Database.ExecuteSqlRawAsync("EXEC [dbo].[adisp001_executa_update_base_mensal]");

        return TypedResults.Ok("Dados carregados com sucesso para ETL");
    }
}

