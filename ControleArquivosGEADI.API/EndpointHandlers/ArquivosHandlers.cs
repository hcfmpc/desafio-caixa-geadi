using AutoMapper;
using ControleArquivosGEADI.API.DbContexts;
using ControleArquivosGEADI.API.Models;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ControleArquivosGEADI.API.EndpointHandlers;

public class ArquivosHandlers
{
    public static async Task<Results<NoContent, Ok<IEnumerable<ArquivoDTO>>>> GetArquivosAsync
    (ControleDboContext controleDboContext,
    IMapper mapper,
    ILogger<ArquivoDTO> logger,
    [FromQuery(Name = "nome")]string? arquivoNome)
    {
        var arquivos = await controleDboContext.Aditb001ControleArquivos
                                                .Where(a => arquivoNome == null || a.NoArquivo.ToLower().Contains(arquivoNome.ToLower()))
                                                .ToListAsync();

        if (arquivos.Count <= 0 || arquivos == null)
        {
            logger.LogInformation($"Arquivos não encontrados. Parâmetro: {arquivoNome}");
            return TypedResults.NoContent();
        }
        else
        {
            logger.LogInformation("Retornando arquivos localizados");
            return TypedResults.Ok(mapper.Map<IEnumerable<ArquivoDTO>>(arquivos));
        }
    }

    public static async Task<Ok<ArquivoDTO>> GetArquivosComIdAsync(
    ControleDboContext controleDboContext,
    IMapper mapper,
    int arquivoId)
    {
        return TypedResults.Ok(mapper.Map<ArquivoDTO>(await controleDboContext.Aditb001ControleArquivos.FirstOrDefaultAsync(a => a.NuId == arquivoId)));
    }
}

