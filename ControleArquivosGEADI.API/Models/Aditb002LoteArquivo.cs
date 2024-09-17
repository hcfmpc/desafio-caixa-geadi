using System;
using System.Collections.Generic;

namespace ControleArquivosGEADI.API.Models;

public partial class Aditb002LoteArquivo
{
    public long NuId { get; set; }

    public DateTime DtCriacao { get; set; }

    public int QtArquivos { get; set; }

    public virtual ICollection<Aditb001ControleArquivo> Aditb001ControleArquivos { get; set; } = new List<Aditb001ControleArquivo>();
}
