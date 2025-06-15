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
                    //Proizvod.Cijena = entity.UkupnaCijena;

                    _context.Add(Proizvod);
                }

                await _context.SaveChangesAsync();

                return entity;
            }
        public override async Task<Model.Narudzba> Update(int id, NarudzbaUpdateRequest request)
        {
            var entity = await _context.Narudzba
                .Include(n => n.NarudzbaProizvodis) 
                .FirstOrDefaultAsync(n => n.NarudzbaId == id);

            if (entity == null)
            {
                throw new Exception("Narudžba ne postoji.");
            }

            entity.Datum = request.Datum;
            entity.UkupnaCijena = request.UkupnaCijena;
            entity.KorisnikId = request.KorisnikId;

            
            var noviProizvodi = request.ListaProizvoda.Select(p => p.ProizvodID).ToList();
            var proizvodiZaBrisanje = entity.NarudzbaProizvodis
                    .Where(p => !noviProizvodi.Contains(p.ProizvodId))
                    .ToList(); 

            foreach (var proizvod in proizvodiZaBrisanje)
            {
                entity.NarudzbaProizvodis.Remove(proizvod);
                _context.NarudzbaProizvodi.Remove(proizvod); 
            }
            
            foreach (var proizvod in request.ListaProizvoda)
            {
                var postojeciProizvod = entity.NarudzbaProizvodis.FirstOrDefault(p => p.ProizvodId == proizvod.ProizvodID);

                if (postojeciProizvod != null)
                {
                    postojeciProizvod.Kolicina = proizvod.Kolicina;
                }
                else
                {
                    entity.NarudzbaProizvodis.Add(new Database.NarudzbaProizvodi
                    {
                        ProizvodId = proizvod.ProizvodID,
                        Kolicina = proizvod.Kolicina,
                        NarudzbaId = entity.NarudzbaId
                    });
                }
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Narudzba>(entity);
        }

        public override async Task BeforeInsert(Database.Narudzba entity, NarudzbaInsertRequest insert)
            {
                _context.Add(entity);
                await _context.SaveChangesAsync(); 

                
            }

        }
    }
