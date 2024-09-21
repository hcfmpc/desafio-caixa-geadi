
namespace ControleArquivosGEADI.API.EndpointFilters;

public class PastasIsLockedFilter : IEndpointFilter
{
    public readonly string[] _arrayStringPastaProibida;

    public PastasIsLockedFilter(string[] arrayStringPastaProibida)
    {
        _arrayStringPastaProibida = arrayStringPastaProibida;
    }
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {

        string pasta;

        if (context.HttpContext.Request.Path.Value.ToLower().Contains("etlbasemensal"))
        {
            pasta = context.GetArgument<string>(1);
        }
        else if(context.HttpContext.Request.Path.Value.ToLower().Contains("mapearpasta"))
        {
            pasta = context.GetArgument<string>(2);
        }
        else
        {
            throw new NotSupportedException("Rota irregular para captura de dados");
        }
        
        //var pastaProibida = new string[] { "C:\\Windows", "C:\\Program Files", "C:\\Program Files (x86)" };
        if (_arrayStringPastaProibida.Any(p => pasta.StartsWith(p)))
            return TypedResults.Problem(new()
            {
                Status = 400,
                Title = "Pasta proibida!",
                Detail = "Não podem ser capturados dados da pasta informada."
            });

        var result = await next.Invoke(context);
        return result;
        
    }
}
