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
    /// <param name="pasta">Caminho informado pelo usuário</param>
    /// <returns>Caminho normalizado para o ambiente atual</returns>
    private static string NormalizarCaminho(string pasta)
    {
        // Verificar se estamos em ambiente Docker
        var isDocker = Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true" ||
                       Directory.Exists("/app/data");

        if (isDocker)
        {
            // Em Docker, assumir que a pasta do projeto está mapeada para /app/data
            // Se o caminho for relativo ou absoluto Windows, converter para Linux
            if (Path.IsPathRooted(pasta) && pasta.Contains("\\"))
            {
                // Detectar se é um caminho que aponta para dentro do projeto
                var projectIndicators = new[] { "desafio-caixa-geadi", "database", "massa-de-teste-db" };
                
                foreach (var indicator in projectIndicators)
                {
                    var indicatorIndex = pasta.LastIndexOf(indicator, StringComparison.OrdinalIgnoreCase);
                    if (indicatorIndex >= 0)
                    {
                        // Extrair caminho relativo a partir do indicador
                        var relativePath = pasta.Substring(indicatorIndex);
                        var linuxPath = relativePath.Replace('\\', '/');
                        return $"/app/data/{linuxPath}";
                    }
                }
                
                // Se não encontrou indicadores, assumir que é um caminho relativo ao projeto
                var pathFromRoot = pasta.Replace('\\', '/');
                if (pathFromRoot.StartsWith("C:", StringComparison.OrdinalIgnoreCase))
                {
                    // Tentar encontrar uma pasta comum e usar caminho relativo
                    return "/app/data"; // Fallback para raiz dos dados
                }
                return $"/app/data/{pathFromRoot}";
            }
            else
            {
                // Caminho já no formato Linux ou relativo
                return pasta.StartsWith("/") ? pasta : $"/app/data/{pasta.Replace('\\', '/')}";
            }
        }
        else
        {
            // Ambiente local - detectar automaticamente o diretório do projeto
            var currentDirectory = Directory.GetCurrentDirectory();
            
            // Se o caminho é absoluto, usar como está
            if (Path.IsPathRooted(pasta))
            {
                return pasta;
            }
            
            // Se é relativo, combinar com diretório atual ou buscar raiz do projeto
            var projectRoot = FindProjectRoot(currentDirectory);
            if (projectRoot != null)
            {
                return Path.Combine(projectRoot, pasta);
            }
            
            // Fallback: usar diretório atual
            return Path.Combine(currentDirectory, pasta);
        }
    }

    /// <summary>
    /// Encontra a raiz do projeto procurando por arquivos indicadores
    /// </summary>
    /// <param name="startPath">Caminho inicial para busca</param>
    /// <returns>Caminho da raiz do projeto ou null se não encontrado</returns>
    private static string? FindProjectRoot(string startPath)
    {
        var current = new DirectoryInfo(startPath);
        
        while (current != null)
        {
            // Procurar por arquivos que indicam a raiz do projeto
            var indicators = new[] { 
                "docker-compose.yml", 
                "ControleArquivosGEADI.sln",
                ".git"
            };
            
            foreach (var indicator in indicators)
            {
                if (File.Exists(Path.Combine(current.FullName, indicator)) ||
                    Directory.Exists(Path.Combine(current.FullName, indicator)))
                {
                    return current.FullName;
                }
            }
            
            current = current.Parent;
        }
        
        return null;
    }
}

