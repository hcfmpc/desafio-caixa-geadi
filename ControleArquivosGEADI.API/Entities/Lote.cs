using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ControleArquivosGEADI.API.Entities
{
    [Table("aditb002_lote_arquivos")]
    public class Lote
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("nu_id")]
        public long Id { get; set; }

        [Required]
        [Column("dt_criacao")]
        public DateTime DataCriacao { get; set; }

        [Required]
        [Column("qt_arquivos")]
        public int QuantidadeArquivos { get; set; }

        public ICollection<Arquivo> Arquivos { get; set; }

        public Lote()
        {
            Arquivos = new List<Arquivo>();
        }

        public Lote(DateTime dataCriacao, int quantidadeArquivos)
        {
            DataCriacao = dataCriacao;
            QuantidadeArquivos = quantidadeArquivos;
            Arquivos = new List<Arquivo>();
        }
    }
}