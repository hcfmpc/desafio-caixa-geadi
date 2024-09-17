using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ControleArquivosGEADI.API.Migrations
{
    /// <inheritdoc />
    public partial class Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "aditb002_lote_arquivos",
                columns: table => new
                {
                    nu_id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    dt_criacao = table.Column<DateTime>(type: "datetime2", nullable: false),
                    qt_arquivos = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_aditb002_lote_arquivos", x => x.nu_id);
                });

            migrationBuilder.CreateTable(
                name: "aditb001_controle_arquivos",
                columns: table => new
                {
                    nu_id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    no_arquivo = table.Column<string>(type: "varchar(max)", nullable: false),
                    no_local = table.Column<string>(type: "varchar(max)", nullable: false),
                    qt_bytes = table.Column<long>(type: "bigint", nullable: false),
                    dt_criacao = table.Column<DateTime>(type: "datetime2", nullable: false),
                    dt_modificacao = table.Column<DateTime>(type: "datetime2", nullable: false),
                    dt_log = table.Column<DateTime>(type: "datetime2", nullable: false),
                    nu_lote_id = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_aditb001_controle_arquivos", x => x.nu_id);
                    table.ForeignKey(
                        name: "FK_aditb001_controle_arquivos_aditb002_lote_arquivos_nu_lote_id",
                        column: x => x.nu_lote_id,
                        principalTable: "aditb002_lote_arquivos",
                        principalColumn: "nu_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_aditb001_controle_arquivos_nu_lote_id",
                table: "aditb001_controle_arquivos",
                column: "nu_lote_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "aditb001_controle_arquivos");

            migrationBuilder.DropTable(
                name: "aditb002_lote_arquivos");
        }
    }
}
