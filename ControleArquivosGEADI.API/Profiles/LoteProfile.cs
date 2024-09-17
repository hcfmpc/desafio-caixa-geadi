using AutoMapper;
using ControleArquivosGEADI.API.Entities;
using ControleArquivosGEADI.API.Models;

namespace ControleArquivosGEADI.API.Profiles;

public class LoteProfile : Profile
{
    public LoteProfile()
    {
        CreateMap<Aditb002LoteArquivo, LoteDTO>().ReverseMap();
        CreateMap<Aditb001ControleArquivo, ArquivoDTO>().ReverseMap();
    }
}

