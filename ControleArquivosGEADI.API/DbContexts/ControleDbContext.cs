using ControleArquivosGEADI.API.Entities;
using Microsoft.EntityFrameworkCore;

namespace ControleArquivosGEADI.API.DbContexts;

public class ControleDbContext(DbContextOptions<ControleDbContext> options) : DbContext(options)
{
    public DbSet<Arquivo> Arquivos { get; set; } = null!;
    public DbSet<Lote> Lotes { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        _ = modelBuilder.Entity<Arquivo>().HasData(
            new Arquivo(1, "Arquivo1.csv", "/caminho/para/Arquivo1.csv", 1024, new DateTime(2023, 1, 1, 12, 0, 0), new DateTime(2023, 1, 1, 12, 0, 0), new DateTime(2023, 1, 1, 12, 0, 0), 1),
            new Arquivo(2, "Arquivo2.csv", "/caminho/para/Arquivo2.csv", 2048, new DateTime(2023, 1, 2, 12, 0, 0), new DateTime(2023, 1, 2, 12, 0, 0), new DateTime(2023, 1, 2, 12, 0, 0), 1),
            new Arquivo(3, "Arquivo3.csv", "/caminho/para/Arquivo3.csv", 3072, new DateTime(2023, 1, 3, 12, 0, 0), new DateTime(2023, 1, 3, 12, 0, 0), new DateTime(2023, 1, 3, 12, 0, 0), 1),
            new Arquivo(4, "Arquivo4.csv", "/caminho/para/Arquivo4.csv", 4096, new DateTime(2023, 1, 4, 12, 0, 0), new DateTime(2023, 1, 4, 12, 0, 0), new DateTime(2023, 1, 4, 12, 0, 0), 2)
            );

        _ = modelBuilder.Entity<Lote>().HasData(
            new Lote(1, new DateTime(2023, 1, 1, 12, 0, 0), 3),
            new Lote(2, new DateTime(2023, 1, 1, 12, 0, 0), 1)
            );

        _ = modelBuilder
            .Entity<Arquivo>()
            .HasOne(a => a.Lote)
            .WithMany(l => l.Arquivos)
            .HasForeignKey(a => a.LoteId);

        base.OnModelCreating(modelBuilder);
    }
}

