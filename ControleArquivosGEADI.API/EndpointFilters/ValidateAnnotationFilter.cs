using ControleArquivosGEADI.API.Models;
using MiniValidation;

namespace ControleArquivosGEADI.API.EndpointFilters;

public class ValidateAnnotationFilter : IEndpointFilter
{

    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        // Procurar pelo parâmetro string que representa a pasta
        string? queryPasta = null;
        
        // Tentar encontrar o parâmetro string (pasta) em qualquer posição
        for (int i = 0; i < context.Arguments.Count; i++)
        {
            if (context.Arguments[i] is string stringParam)
            {
                queryPasta = stringParam;
                break;
            }
        }

        if (queryPasta == null)
        {
            return TypedResults.BadRequest("Parâmetro 'pasta' não encontrado");
        }

        var model = new CapturaDTO { pasta = queryPasta };

        if (!MiniValidator.TryValidate(model, out var validationErrors))
        {
            return TypedResults.ValidationProblem(validationErrors);
        }

        return await next(context);
    }
}
