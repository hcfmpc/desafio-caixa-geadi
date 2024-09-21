using ControleArquivosGEADI.API.Models;
using MiniValidation;

namespace ControleArquivosGEADI.API.EndpointFilters;

public class ValidateAnnotationFilter : IEndpointFilter
{

    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var queryPasta = context.GetArgument<string>(2);
        var model = new CapturaDTO { pasta = queryPasta };

        if (!MiniValidator.TryValidate(model, out var validationErrors))
        {
            return TypedResults.ValidationProblem(validationErrors);
        }

        return await next(context);
    }
}
