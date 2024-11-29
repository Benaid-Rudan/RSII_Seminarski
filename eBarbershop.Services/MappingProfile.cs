using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Services.Database;
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
            CreateMap<Model.Requests.ProizvodInsertRequest, Database.Proizvod>();
            CreateMap<Model.Requests.ProizvodUpdateRequest, Database.Proizvod>();

            CreateMap<Database.Grad, Model.Grad>();
            CreateMap<Model.Requests.GradInsertRequest, Database.Grad>();
            CreateMap<Model.Requests.GradUpdateRequest, Database.Grad>();

            CreateMap<Database.Drzava, Model.Drzava>();
            CreateMap<Model.Requests.DrzavaInsertRequest, Database.Drzava>();
            CreateMap<Model.Requests.DrzavaUpdateRequest, Database.Drzava>();

            CreateMap<Database.VrstaProizvodum, Model.VrstaProizvoda>();
            CreateMap<Model.Requests.VrstaProizvodaInsertRequest, Database.VrstaProizvodum>();
            CreateMap<Model.Requests.VrstaProizvodaUpdateRequest, Database.VrstaProizvodum>();

            CreateMap<Database.Usluga, Model.Usluga>();
            CreateMap<Model.Requests.UslugaInsertRequest, Database.Usluga>();
            CreateMap<Model.Requests.UslugaUpdateRequest, Database.Usluga>();

            CreateMap<Database.Uplatum, Model.Uplata>();
            CreateMap<Model.Requests.UplataInsertRequest, Database.Uplatum>();
            CreateMap<Model.Requests.UplataUpdateRequest, Database.Uplatum>();

            CreateMap<Database.Uloga, Model.Uloga>();
            CreateMap<Model.Requests.UlogaInsertRequest, Database.Uloga>();
            CreateMap<Model.Requests.UlogaUpdateRequest, Database.Uloga>();

            CreateMap<Database.Termin, Model.Termin>();
            CreateMap<Model.Requests.TerminInsertRequest, Database.Termin>();
            CreateMap<Model.Requests.TerminUpdateRequest, Database.Termin>();

            CreateMap<Database.Narudzba, Model.Narudzba>();
            CreateMap<Model.Requests.NarudzbaInsertRequest, Database.Narudzba>();
            CreateMap<Model.Requests.NarudzbaUpdateRequest, Database.Narudzba>();

            CreateMap<Database.Rezervacija, Model.Rezervacija>();
            CreateMap<Model.Requests.RezervacijaInsertRequest, Database.Rezervacija>();
            CreateMap<Model.Requests.RezervacijaUpdateRequest, Database.Rezervacija>();

            CreateMap<Database.Recenzija, Model.Recenzija>();
            CreateMap<Model.Requests.RecenzijaInsertRequest, Database.Recenzija>();
            CreateMap<Model.Requests.RecenzijaUpdateRequest, Database.Recenzija>();

            CreateMap<Database.Novost, Model.Novost>();
            CreateMap<Model.Requests.NovostInsertRequest, Database.Novost>();
            CreateMap<Model.Requests.NovostUpdateRequest, Database.Novost>();

            CreateMap<Database.KorisnikUloga, Model.KorisnikUloga>();

            

        }
    }
}
