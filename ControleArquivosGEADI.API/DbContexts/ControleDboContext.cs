using System;
using System.Collections.Generic;
using ControleArquivosGEADI.API.Models;
using Microsoft.EntityFrameworkCore;

namespace ControleArquivosGEADI.API.DbContexts;

public partial class ControleDboContext : DbContext
{
    public ControleDboContext()
    {
    }

    public ControleDboContext(DbContextOptions<ControleDboContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Aditb001ControleArquivo> Aditb001ControleArquivos { get; set; }

    public virtual DbSet<Aditb002LoteArquivo> Aditb002LoteArquivos { get; set; }

    public virtual DbSet<Aditb003BaseMensalEtl> Aditb003BaseMensalEtls { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            IConfigurationRoot configuration = new ConfigurationBuilder()
                                                           .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
                                                           .AddJsonFile("appsettings.json", optional: true)
                                                           .AddEnvironmentVariables()
                                                           .Build();

            optionsBuilder.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Aditb001ControleArquivo>(entity =>
        {
            entity.HasKey(e => e.NuId);

            entity.ToTable("aditb001_controle_arquivos");

            entity.Property(e => e.NuId).HasColumnName("nu_id");
            entity.Property(e => e.DtCriacao).HasColumnName("dt_criacao");
            entity.Property(e => e.DtLog).HasColumnName("dt_log");
            entity.Property(e => e.DtModificacao).HasColumnName("dt_modificacao");
            entity.Property(e => e.NoArquivo)
                .IsUnicode(false)
                .HasColumnName("no_arquivo");
            entity.Property(e => e.NoLocal)
                .IsUnicode(false)
                .HasColumnName("no_local");
            entity.Property(e => e.NuLoteId).HasColumnName("nu_lote_id");
            entity.Property(e => e.QtBytes).HasColumnName("qt_bytes");

            entity.HasOne(d => d.NuLote).WithMany(p => p.Aditb001ControleArquivos).HasForeignKey(d => d.NuLoteId);
        });

        modelBuilder.Entity<Aditb002LoteArquivo>(entity =>
        {
            entity.HasKey(e => e.NuId);

            entity.ToTable("aditb002_lote_arquivos");

            entity.Property(e => e.NuId).HasColumnName("nu_id");
            entity.Property(e => e.DtCriacao).HasColumnName("dt_criacao");
            entity.Property(e => e.QtArquivos).HasColumnName("qt_arquivos");
        });

        modelBuilder.Entity<Aditb003BaseMensalEtl>(entity =>
        {
            entity.HasKey(e => e.NuId);

            entity.ToTable("aditb003_base_mensal_ETL");

            entity.Property(e => e.NuId).HasColumnName("nu_id");
            entity.Property(e => e.AmHonrado)
                .IsUnicode(false)
                .HasColumnName("am_honrado");
            entity.Property(e => e.BaseCalculo)
                .IsUnicode(false)
                .HasColumnName("base_calculo");
            entity.Property(e => e.Cart)
                .IsUnicode(false)
                .HasColumnName("cart");
            entity.Property(e => e.CoAgRelac)
                .IsUnicode(false)
                .HasColumnName("co_ag_relac");
            entity.Property(e => e.CoCart)
                .IsUnicode(false)
                .HasColumnName("co_cart");
            entity.Property(e => e.CoMod)
                .IsUnicode(false)
                .HasColumnName("co_mod");
            entity.Property(e => e.CoOpe)
                .IsUnicode(false)
                .HasColumnName("co_ope");
            entity.Property(e => e.CoSeg)
                .IsUnicode(false)
                .HasColumnName("co_seg");
            entity.Property(e => e.CoSegad)
                .IsUnicode(false)
                .HasColumnName("co_segad");
            entity.Property(e => e.CoSegger)
                .IsUnicode(false)
                .HasColumnName("co_segger");
            entity.Property(e => e.CoSeggerGp)
                .IsUnicode(false)
                .HasColumnName("co_segger_gp");
            entity.Property(e => e.CoSis)
                .IsUnicode(false)
                .HasColumnName("co_sis");
            entity.Property(e => e.CpfCnpj)
                .IsUnicode(false)
                .HasColumnName("cpf_cnpj");
            entity.Property(e => e.Ctr)
                .IsUnicode(false)
                .HasColumnName("ctr");
            entity.Property(e => e.DaAtual)
                .IsUnicode(false)
                .HasColumnName("da_atual");
            entity.Property(e => e.DaIni)
                .IsUnicode(false)
                .HasColumnName("da_ini");
            entity.Property(e => e.DdVencimentoContrato)
                .IsUnicode(false)
                .HasColumnName("DD_VENCIMENTO_CONTRATO");
            entity.Property(e => e.DtConce)
                .IsUnicode(false)
                .HasColumnName("dt_conce");
            entity.Property(e => e.DtMov)
                .IsUnicode(false)
                .HasColumnName("dt_mov");
            entity.Property(e => e.IcAtacado)
                .IsUnicode(false)
                .HasColumnName("ic_atacado");
            entity.Property(e => e.IcCaixa)
                .IsUnicode(false)
                .HasColumnName("ic_caixa");
            entity.Property(e => e.IcHonrado)
                .IsUnicode(false)
                .HasColumnName("ic_honrado");
            entity.Property(e => e.IcReg)
                .IsUnicode(false)
                .HasColumnName("ic_reg");
            entity.Property(e => e.IcRj)
                .IsUnicode(false)
                .HasColumnName("ic_rj");
            entity.Property(e => e.NoSeg)
                .IsUnicode(false)
                .HasColumnName("no_seg");
            entity.Property(e => e.NuTabelaAtual)
                .IsUnicode(false)
                .HasColumnName("nu_tabela_atual");
            entity.Property(e => e.Posicao)
                .IsUnicode(false)
                .HasColumnName("posicao");
            entity.Property(e => e.RatH5)
                .IsUnicode(false)
                .HasColumnName("rat_h5");
            entity.Property(e => e.RatH6)
                .IsUnicode(false)
                .HasColumnName("rat_h6");
            entity.Property(e => e.RatHh)
                .IsUnicode(false)
                .HasColumnName("rat_hh");
            entity.Property(e => e.RatProv)
                .IsUnicode(false)
                .HasColumnName("rat_prov");
            entity.Property(e => e.TpPessoa)
                .IsUnicode(false)
                .HasColumnName("tp_pessoa");
            entity.Property(e => e.Unidade)
                .IsUnicode(false)
                .HasColumnName("unidade");
            entity.Property(e => e.VlrConce)
                .IsUnicode(false)
                .HasColumnName("vlr_conce");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
