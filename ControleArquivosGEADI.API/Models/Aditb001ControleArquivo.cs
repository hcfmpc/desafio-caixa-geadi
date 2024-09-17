namespace ControleArquivosGEADI.API.Models;

public partial class Aditb001ControleArquivo
{
    public long NuId { get; set; }

    public string NoArquivo { get; set; } = null!;

    public string NoLocal { get; set; } = null!;

    public long QtBytes { get; set; }

    public DateTime DtCriacao { get; set; }

    public DateTime DtModificacao { get; set; }

    public DateTime DtLog { get; set; }

    public long NuLoteId { get; set; }

    public virtual Aditb002LoteArquivo NuLote { get; set; } = null!;
}
