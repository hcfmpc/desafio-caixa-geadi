using ControleArquivosGEADI.API.Entities;
using Microsoft.EntityFrameworkCore;

namespace ControleArquivosGEADI.API.DbContexts;

public class ControleDbContext(DbContextOptions<ControleDbContext> options) : DbContext(options)
{
    public DbSet<Arquivo> Arquivos { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
    }
}

