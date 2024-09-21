using System.ComponentModel.DataAnnotations;

namespace ControleArquivosGEADI.API.Models;

public class CapturaDTO
{

    [Required]
    [StringLength(200, MinimumLength = 3)]
    public string pasta { get; set; }
}
