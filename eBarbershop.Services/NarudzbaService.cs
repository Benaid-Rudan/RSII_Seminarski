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
    public class NarudzbaService : BaseCRUDService<Model.Narudzba, Database.Narudzba, NarudzbaSearchObject , NarudzbaInsertRequest, NarudzbaUpdateRequest>, INarudzbaService
    {
        
        public NarudzbaService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }

        public override IQueryable<Database.Narudzba> AddFilter(IQueryable<Database.Narudzba> entity, NarudzbaSearchObject? obj = null)
        {
            if (obj.NarudzbaId.HasValue)
            {
                entity = entity.Where(x => x.NarudzbaId == obj.NarudzbaId);
            }
            if (obj.KorisnikId.HasValue)
            {
                entity = entity.Where(x => x.KorisnikId == obj.KorisnikId);
            }
            return entity;
        }
        public override IQueryable<Database.Narudzba> AddInclude(IQueryable<Database.Narudzba> entity, NarudzbaSearchObject obj)
        {

            if (obj.IncludeNarudzbaProizvodi == true)
            {
                entity = entity.Include(x => x.NarudzbaProizvodis).ThenInclude(np => np.Proizvod);
            }

            return entity;
        }
        public override async Task<Model.Narudzba> Insert(NarudzbaInsertRequest request)
        {
            var entity = await base.Insert(request);

            foreach (var proizvod in request.ListaProizvoda)
            {
                Database.NarudzbaProizvodi Proizvod = new Database.NarudzbaProizvodi();

                Proizvod.ProizvodId = proizvod.ProizvodID;
                Proizvod.Kolicina = proizvod.Kolicina;
                Proizvod.NarudzbaId = entity.NarudzbaId;
                Proizvod.Cijena = entity.UkupnaCijena;

                _context.Add(Proizvod);
            }

            await _context.SaveChangesAsync();

            return entity;
        }

        public override async Task BeforeInsert(Database.Narudzba entity, NarudzbaInsertRequest insert)
        {
            _context.Add(entity);
            await _context.SaveChangesAsync(); // Ovdje se stvarno sačuva Narudzba i dodeljuje se NarudzbaId

            // Sada možete dodati povezane NarudzbaProizvodi entitete
            //foreach (var proizvod in insert.ListaProizvoda)
            //{
            //    Database.NarudzbaProizvodi narudzbaProizvod = new Database.NarudzbaProizvodi
            //    {
            //        ProizvodId = proizvod.ProizvodID,
            //        Kolicina = proizvod.Kolicina,
            //        NarudzbaId = entity.NarudzbaId // NarudzbaId je sada sigurno postavljen
            //    };

            //    _context.Add(narudzbaProizvod);
            //}

            //// Sačuvajte promene u bazi
            //await _context.SaveChangesAsync();
            //2
            ////foreach (var proizvod in insert.ListaProizvoda)
            //{
            //    Database.NarudzbaProizvodi narudzbaProizvod = new Database.NarudzbaProizvodi
            //    {
            //        ProizvodId = proizvod.ProizvodID,
            //        Kolicina = proizvod.Kolicina,
            //        NarudzbaId = entity.NarudzbaId 
            //    };

            //    _context.Add(narudzbaProizvod);
            //}


            //3
            //await _context.SaveChangesAsync(); 
            //if (insert.ListaProizvoda == null || insert.ListaProizvoda.Count == 0)
            //{
            //    throw new ArgumentException("Lista proizvoda ne može biti prazna.");
            //}
        }

    }
}
