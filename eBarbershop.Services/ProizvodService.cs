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
    public class ProizvodService : BaseCRUDService<Model.Proizvod, 
        Database.Proizvod, ProizvodSearchObject, 
        ProizvodInsertRequest, ProizvodUpdateRequest>, IProizvodService
    {
        public ProizvodService(EBarbershop1Context context, IMapper mapper) : base(context, mapper)
        {

        }
        public override IQueryable<Database.Proizvod> AddInclude(
            IQueryable<Database.Proizvod> entity, ProizvodSearchObject obj)
        {
            if (obj.IncludeVrstaProizvoda == true)
            {
                entity = entity.Include(x => x.VrstaProizvoda);
            }

            return entity;
        }
        public override IQueryable<Database.Proizvod> AddFilter(
            IQueryable<Database.Proizvod> entity, ProizvodSearchObject? obj = null)
        {
            if (obj.VrstaProizvodaID.HasValue)
            {
                entity = entity.Where(x => x.VrstaProizvodaId == obj.VrstaProizvodaID);
            }

            if (!string.IsNullOrWhiteSpace(obj.Naziv))
            {
                entity = entity.Where(x => x.Naziv.ToLower().Contains(obj.Naziv.ToLower()));
            }
            if (!string.IsNullOrWhiteSpace(obj.Opis))
            {
                entity = entity.Where(x => x.Opis.ToLower().Contains(obj.Opis.ToLower()));
            }
            return entity;
        }
        public async Task<List<Model.Proizvod>> GetRecommendedProducts()
        {
            var query = _context.Proizvod
                .Include(p => p.NarudzbaProizvodis) // Uključi vezu s narudžbama
                .Select(p => new
                {
                    Proizvod = p,
                    OrderCount = p.NarudzbaProizvodis.Sum(np => np.Kolicina) // Suma količina narudžbi
                })
                .OrderByDescending(x => x.OrderCount)
                .Take(3) 
                .Select(x => x.Proizvod);

            var list = await query.ToListAsync();
            return _mapper.Map<List<Model.Proizvod>>(list);
        }
    }
}
