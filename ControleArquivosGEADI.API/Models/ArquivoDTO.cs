namespace ControleArquivosGEADI.API.Models;

public class ArquivoDTO
{
    public string Nome { get; set; }
    public string Local { get; set; }
    public long Tamanho { get; set; }
    public DateTime DataCriacao { get; set; }
    public DateTime DataModificacao { get; set; }
    public DateTime DataLog { get; set; }

}
