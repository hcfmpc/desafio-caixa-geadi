using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ControleArquivosGEADI.API.Entities;

[Table("aditb001_controle_arquivos")]
public class Arquivo
{
    [Key]
    [Column("nu_id")]
    public long Id { get; set; }
    
    [Required]
    [Column("no_arquivo", TypeName = "varchar(max)")]
    public required string Nome { get; set; }
    
    [Required]
    [Column("no_local", TypeName = "varchar(max)")]
    public required string Local { get; set; }
    
    [Required]
    [Column("qt_bytes")]
    public required long Tamanho { get; set; }
    
    [Required]
    [Column("dt_criacao")]
    public required DateTime DataCriacao { get; set; }
    
    [Required]
    [Column("dt_modificacao")]
    public required DateTime DataModificacao { get; set; }
    
    [Column("dt_log")]
    public DateTime DataLog { get; set; }

    [ForeignKey("Lote")]
    [Column("nu_lote_id")]
    public long LoteId { get; set; }
    public Lote Lote { get; set; }

    public Arquivo() { }
    
    [SetsRequiredMembers]
    public Arquivo(long id, string nome, string local, long tamanho, DateTime dataModificacao, DateTime dataCriacao, DateTime dataLog, long loteId)
    {
        Id = id;
        Nome = nome;
        Local = local;
        Tamanho = tamanho;
        DataModificacao = dataModificacao;
        DataCriacao = dataCriacao;
        DataLog = dataLog;
        LoteId = loteId;
    }
}