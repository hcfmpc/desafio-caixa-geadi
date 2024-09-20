using ControleArquivosGEADI.API.EndpointHandlers;
namespace ControleArquivosGEADI.API.Extensions;

public static class EndpointRouteBuilderExtensions
{
    public static void RegisterArquivosEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var arquivosEndpoints = endpoints.MapGroup("/arquivos");
        var arquivosComIdEndpoints = arquivosEndpoints.MapGroup("/{arquivoId:int}");
        arquivosEndpoints.MapGet("", ArquivosHandlers.GetArquivosAsync);
        arquivosComIdEndpoints.MapGet("", ArquivosHandlers.GetArquivosComIdAsync);
    }

    public static void RegisterLotesEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var lotesEndpoints = endpoints.MapGroup("/lotes");
        var lotesComIdEndpoints = lotesEndpoints.MapGroup("/{loteId:int}");
        lotesEndpoints.MapGet("", LotesHandlers.GetLotesAsync);
        lotesComIdEndpoints.MapGet("", LotesHandlers.GetLotesComIdAsync).WithName("GetLotes");
        lotesComIdEndpoints.MapPost("", () =>
        {
            throw new NotImplementedException();
        });
    }
    public static void RegisterCapturasEndpoints(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapPost("/mapearpasta", CapturasHandlers.PostMapearArquivosAsync);
        endpoints.MapPost("/etlbasemensal", CapturasHandlers.PostCapturaEtlBaseMensalAsync);
    }   
}
