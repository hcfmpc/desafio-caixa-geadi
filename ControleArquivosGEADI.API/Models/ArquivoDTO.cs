namespace ControleArquivosGEADI.API.Models;

public class ArquivoDTO
{
    public string NoArquivo { get; set; }
    public string NoLocal { get; set; }
    public long QtBytes { get; set; }
    public DateTime DtCriacao { get; set; }
    public DateTime DtModificacao { get; set; }
    public DateTime DtLog { get; set; }

}
