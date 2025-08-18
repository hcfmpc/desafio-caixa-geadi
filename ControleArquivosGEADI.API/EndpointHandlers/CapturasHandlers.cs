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
        // Normalizar caminho baseado no ambiente
        var caminhoNormalizado = NormalizarCaminho(pasta);

        if (!Directory.Exists(caminhoNormalizado))
            return TypedResults.NotFound<string>($"Pasta não encontrada: {caminhoNormalizado}");

        var dataLog = DateTime.Now;
        var arquivos = Directory.GetFiles(caminhoNormalizado)
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
        var caminhoNormalizado = NormalizarCaminho(pasta);
        
        if (!Directory.Exists(caminhoNormalizado))
            return TypedResults.NotFound($"Pasta não encontrada: {caminhoNormalizado}");

        var csvFilePath = Path.Combine(caminhoNormalizado, "BASE_MENSAL.csv");

        if (!File.Exists(csvFilePath))
            return TypedResults.NotFound("Arquivo BASE_MENSAL.csv não encontrado na pasta");

        var csvData = new List<Aditb003BaseMensalEtl>();
        Console.WriteLine("Iniciando leitura do arquivo CSV...");
        
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

        Console.WriteLine($"Arquivo CSV processado: {csvData.Count} registros lidos");
        Console.WriteLine("Salvando dados no banco...");
        
        await controleDboContext.Aditb003BaseMensalEtls.AddRangeAsync(csvData);
        await controleDboContext.SaveChangesAsync();

        Console.WriteLine("Dados salvos com sucesso!");
        return TypedResults.Ok($"Dados carregados com sucesso para ETL: {csvData.Count} registros");
    }

    /// <summary>
    /// Normaliza o caminho baseado no ambiente de execução
    /// </summary>
    /// <param name="pasta">Caminho informado pelo usuário (sempre no formato C:\)</param>
    /// <returns>Caminho normalizado para o ambiente atual</returns>
    private static string NormalizarCaminho(string pasta)
    {
        // Verificar se estamos em ambiente Docker
        var isDocker = Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true" ||
                       Directory.Exists("/app/data");

        if (isDocker)
        {
            // Ambiente Docker - converter C:\LocalGit\Caixa\... para /app/data/...
            if (pasta.StartsWith("C:\\LocalGit\\Caixa\\", StringComparison.OrdinalIgnoreCase))
            {
                // Remove "C:\LocalGit\Caixa\" e substitui por "/app/data/"
                var relativePath = pasta.Substring("C:\\LocalGit\\Caixa\\".Length);
                var linuxPath = relativePath.Replace('\\', '/');
                return $"/app/data/{linuxPath}";
            }
            else if (pasta.StartsWith("C:\\LocalGit\\Caixa", StringComparison.OrdinalIgnoreCase))
            {
                // Se for exatamente "C:\LocalGit\Caixa"
                return "/app/data";
            }
            else
            {
                // Se não começar com o caminho esperado, retorna como está (pode ser já normalizado)
                return pasta;
            }
        }
        else
        {
            // Ambiente local - usar caminho Windows como está
            return pasta;
        }
    }
}

