using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class TerminService : BaseCRUDService<Model.Termin, Database.Termin, TerminSearchObject , TerminInsertRequest, TerminUpdateRequest>, ITerminService 
    {
        
        public TerminService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }
        public void BeforeInsert(TerminInsertRequest insert, Database.Termin entity)
        {
            entity.Vrijeme = DateTime.Now;
        }

        public override IQueryable<Database.Termin> AddInclude(IQueryable<Database.Termin> entity, TerminSearchObject obj)
        {
            if (obj.IncludeKorisnik == true)
            {
                entity = entity.Include(x => x.Korisnik);

            }
            if (obj.IncludeRezervacija == true)
            {
                entity = entity.Include(x => x.Rezervacija);

            }
            
            return entity;
        }

        public override IQueryable<Database.Termin> AddFilter(IQueryable<Database.Termin> entity, TerminSearchObject obj)
        {
            if (obj.KorisnikID.HasValue)
            {
                entity = entity.Where(x => x.KorisnikID == obj.KorisnikID);
            }
            if (!string.IsNullOrWhiteSpace(obj.imePrezime))
            {
                entity = entity.Where(x => x.Korisnik.Ime.ToLower().Contains(obj.imePrezime.ToLower()) || x.Korisnik.Prezime.ToLower().Contains(obj.imePrezime.ToLower()));
            }

            if (obj.Datum.HasValue)
            {
                entity = entity.Where(x => x.Vrijeme.Date == obj.Datum.Value);
            }

            if (obj.DatumOd.HasValue)
            {
                entity = entity.Where(x => x.Vrijeme.Date >= obj.DatumOd.Value);
            }

            if (obj.DatumDo.HasValue)
            {
                entity = entity.Where(x => x.Vrijeme.Date <= obj.DatumDo.Value);
            }

            if (obj.isBooked.HasValue)
            {
                entity = entity.Where(x => x.isBooked == obj.isBooked);
            }

            return entity;
        }


    }
}
