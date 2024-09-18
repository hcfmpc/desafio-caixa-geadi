using AutoMapper;
using ControleArquivosGEADI.API.DbContexts;
using ControleArquivosGEADI.API.Models;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;

namespace ControleArquivosGEADI.API.EndpointHandlers;

public static class LotesHandlers
{
    public static async Task<Results<NoContent, Ok<IEnumerable<LoteDTO>>>> GetListasAsync
        (ControleDboContext controleDboContext,
        IMapper mapper)
    {
        var lotes = await controleDboContext.Aditb002LoteArquivos.ToListAsync();

        if (lotes.Count <= 0 || lotes == null)
            return TypedResults.NoContent();
        else
            return TypedResults.Ok(mapper.Map<IEnumerable<LoteDTO>>(lotes));
    }

    public static async Task<Results<NoContent, Ok<LoteDTO>>> GetListasComIdAsync
    (ControleDboContext controleDboContext,
    IMapper mapper,
    int loteId)
    {
        var lote = await controleDboContext.Aditb002LoteArquivos.FirstOrDefaultAsync(a => a.NuId == loteId);

        if (lote == null)
            return TypedResults.NoContent();
        else
            return TypedResults.Ok(mapper.Map<LoteDTO>(lote));
    }
}

