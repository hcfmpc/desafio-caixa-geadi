using ControleArquivosGEADI.API.EndpointFilters;
using ControleArquivosGEADI.API.EndpointHandlers;
namespace ControleArquivosGEADI.API.Extensions;

public static class EndpointRouteBuilderExtensions
{
    public static void RegisterArquivosEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var arquivosEndpoints = endpoints.MapGroup("/arquivos");
        var arquivosComIdEndpoints = arquivosEndpoints.MapGroup("/{arquivoId:int}");
        arquivosEndpoints.MapGet("", ArquivosHandlers.GetArquivosAsync)
            .WithOpenApi()
            .WithSummary("Esta rota retorna os arquivos capturados");
        arquivosComIdEndpoints.MapGet("", ArquivosHandlers.GetArquivosComIdAsync)
            .WithOpenApi()
            .WithSummary("Esta rota retorna o arquivo por ID");
        arquivosComIdEndpoints.MapDelete("", ArquivosHandlers.GetArquivosComIdAsync)
            .WithOpenApi(operation => {
                operation.Deprecated = true;
                return operation;
            })
            .WithSummary("Este endpoint está deprecated e será descontinuado na versão 2 desta API")
            .WithDescription("Por favor utilize outra rota desta API para esta funcionalidade!");
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
        endpoints.MapPost("/mapearpasta", CapturasHandlers.PostMapearArquivosAsync)
            .AddEndpointFilter<ValidateAnnotationFilter>()
            .AddEndpointFilter(new PastasIsLockedFilter(new string[] { "C:\\Windows", "C:\\Program Files", "C:\\Program Files (x86)" }));

        endpoints.MapPost("/etlbasemensal", CapturasHandlers.PostCapturaEtlBaseMensalAsync)
            .AddEndpointFilter<ValidateAnnotationFilter>()
            .AddEndpointFilter(new PastasIsLockedFilter(new string[] { "C:\\Windows", "C:\\Program Files", "C:\\Program Files (x86)" }));
    }   
}
