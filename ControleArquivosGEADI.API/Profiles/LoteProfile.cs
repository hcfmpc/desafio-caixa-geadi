using AutoMapper;
using ControleArquivosGEADI.API.Entities;
using ControleArquivosGEADI.API.Models;

namespace ControleArquivosGEADI.API.Profiles;

public class LoteProfile : Profile
{
    public LoteProfile()
    {
        CreateMap<Lote, LoteDTO>().ReverseMap();
        CreateMap<Arquivo, ArquivoDTO>().ReverseMap();
    }
}

