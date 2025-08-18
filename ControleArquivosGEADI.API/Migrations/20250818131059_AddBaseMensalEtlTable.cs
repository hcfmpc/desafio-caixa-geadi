using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ControleArquivosGEADI.API.Migrations
{
    /// <inheritdoc />
    public partial class AddBaseMensalEtlTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "aditb003_base_mensal_ETL",
                columns: table => new
                {
                    nu_id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ctr = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_ope = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    cpf_cnpj = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    ic_caixa = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    tp_pessoa = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_sis = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    unidade = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_ag_relac = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    dt_conce = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    DD_VENCIMENTO_CONTRATO = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    vlr_conce = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    posicao = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    da_ini = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    dt_mov = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    da_atual = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    nu_tabela_atual = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    base_calculo = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    rat_prov = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    rat_hh = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_mod = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    cart = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_cart = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_seg = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    no_seg = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_segger = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_segger_gp = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    co_segad = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    rat_h5 = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    rat_h6 = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    ic_atacado = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    ic_reg = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    ic_rj = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    ic_honrado = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    am_honrado = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_aditb003_base_mensal_ETL", x => x.nu_id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "aditb003_base_mensal_ETL");
        }
    }
}
