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

            CreateMap<Database.Proizvod,Model.Proizvod>();
            CreateMap<Model.Requests.ProizvodiInsertRequest, Database.Proizvod>();
            CreateMap<Model.Requests.ProizvodiUpdateRequest, Database.Proizvod>();

            CreateMap<Database.Grad, Model.Grad>();
            CreateMap<Database.Drzava, Model.Drzava>();
            CreateMap<Database.KorisnikUloga, Model.KorisnikUloga>();
            CreateMap<Database.Uloga, Model.Uloga>();



        }
    }
}
