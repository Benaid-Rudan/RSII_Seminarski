using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
namespace eBarbershop.Services
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Database.Korisnik, Model.Korisnik>();
            CreateMap<Model.Requests.KorisniciInsertRequest, Database.Korisnik>();
            CreateMap<Model.Requests.KorisniciUpdateRequest, Database.Korisnik>();

        }
    }
}
