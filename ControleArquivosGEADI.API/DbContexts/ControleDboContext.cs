using System;
using System.Collections.Generic;
using ControleArquivosGEADI.API.Entities;
using ControleArquivosGEADI.API.Models;
using Microsoft.EntityFrameworkCore;

namespace ControleArquivosGEADI.API.DbContexts;

public partial class ControleDboContext(DbContextOptions<ControleDboContext> options) : DbContext(options)
{
    //public ControleDboContext()
    //{
    //}

    //public ControleDboContext(DbContextOptions<ControleDboContext> options)
    //    : base(options)
    //{
    //}

    //public DbSet<Arquivo> Arquivos { get; set; } = null!;
    //public DbSet<Lote> Lotes { get; set; } = null!;

    public virtual DbSet<Aditb001ControleArquivo> Aditb001ControleArquivos { get; set; }

    public virtual DbSet<Aditb002LoteArquivo> Aditb002LoteArquivos { get; set; }

//    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
//#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
//        => optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=DBTeste;User ID=sa;Password=Ge@di2024;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Aditb001ControleArquivo>(entity =>
        {
            entity.HasKey(e => e.NuId);

            entity.ToTable("aditb001_controle_arquivos");

            entity.HasIndex(e => e.NuLoteId, "IX_aditb001_controle_arquivos_nu_lote_id");

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

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
