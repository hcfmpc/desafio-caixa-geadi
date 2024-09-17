using ControleArquivosGEADI.API.Models;
using CsvHelper.Configuration;

public class Aditb003BaseMensalEtlMap : ClassMap<Aditb003BaseMensalEtl>
{
    public Aditb003BaseMensalEtlMap()
    {
        Map(m => m.Ctr).Name("ctr");
        Map(m => m.CoOpe).Name("co_ope");
        Map(m => m.CpfCnpj).Name("cpf_cnpj");
        Map(m => m.IcCaixa).Name("ic_caixa");
        Map(m => m.TpPessoa).Name("tp_pessoa");
        Map(m => m.CoSis).Name("co_sis");
        Map(m => m.Unidade).Name("unidade");
        Map(m => m.CoAgRelac).Name("co_ag_relac");
        Map(m => m.DtConce).Name("dt_conce");
        Map(m => m.DdVencimentoContrato).Name("DD_VENCIMENTO_CONTRATO");
        Map(m => m.VlrConce).Name("vlr_conce");
        Map(m => m.Posicao).Name("posicao");
        Map(m => m.DaIni).Name("da_ini");
        Map(m => m.DtMov).Name("dt_mov");
        Map(m => m.DaAtual).Name("da_atual");
        Map(m => m.NuTabelaAtual).Name("nu_tabela_atual");
        Map(m => m.BaseCalculo).Name("base_calculo");
        Map(m => m.RatProv).Name("rat_prov");
        Map(m => m.RatHh).Name("rat_hh");
        Map(m => m.CoMod).Name("co_mod");
        Map(m => m.Cart).Name("cart");
        Map(m => m.CoCart).Name("co_cart");
        Map(m => m.CoSeg).Name("co_seg");
        Map(m => m.NoSeg).Name("no_seg");
        Map(m => m.CoSegger).Name("co_segger");
        Map(m => m.CoSeggerGp).Name("co_segger_gp");
        Map(m => m.CoSegad).Name("co_segad");
        Map(m => m.RatH5).Name("rat_h5");
        Map(m => m.RatH6).Name("rat_h6");
        Map(m => m.IcAtacado).Name("ic_atacado");
        Map(m => m.IcReg).Name("ic_reg");
        Map(m => m.IcRj).Name("ic_rj");
        Map(m => m.IcHonrado).Name("ic_honrado");
        Map(m => m.AmHonrado).Name("am_honrado");
    }
}