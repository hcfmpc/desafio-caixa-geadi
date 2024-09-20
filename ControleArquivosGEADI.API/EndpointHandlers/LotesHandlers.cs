using AutoMapper;
using ControleArquivosGEADI.API.DbContexts;
using ControleArquivosGEADI.API.Models;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace ControleArquivosGEADI.API.EndpointHandlers;

public static class LotesHandlers
{
    public static async Task<Results<NoContent, Ok<IEnumerable<LoteDTO>>>> GetLotesAsync
        (ControleDboContext controleDboContext,
        ILogger<LoteDTO> logger,
        IMapper mapper)
    {
        var lotes = await controleDboContext.Aditb002LoteArquivos.ToListAsync();

        if (lotes.Count <= 0 || lotes == null)
        {
            logger.LogInformation($"Lotes não encontrados.");
            return TypedResults.NoContent();
        }
        else
        {
            logger.LogInformation("Retornando lotes localizados");
            return TypedResults.Ok(mapper.Map<IEnumerable<LoteDTO>>(lotes));
        }
    }

    public static async Task<Results<NoContent, Ok<LoteDTO>>> GetLotesComIdAsync
    (ControleDboContext controleDboContext,
    IMapper mapper,
    ILogger<LoteDTO> logger,
    int loteId)
    {
        var lote = await controleDboContext.Aditb002LoteArquivos.FirstOrDefaultAsync(a => a.NuId == loteId);

        if (lote == null)
        {
            logger.LogInformation($"Lote não encontrados. Parâmetro: {loteId}");
            return TypedResults.NoContent();
        }
        else
        {
            logger.LogInformation("Retornando lote localizado");
            return TypedResults.Ok(mapper.Map<LoteDTO>(lote));
        }
    }
}

