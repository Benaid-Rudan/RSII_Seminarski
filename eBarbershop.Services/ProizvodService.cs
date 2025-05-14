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
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

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
        public override async Task<Model.Proizvod> Delete(int id)
        {
            var entity = await _context.Proizvod.FindAsync(id);

            if (entity == null)
                throw new Exception("Proizvod nije pronađen");

            entity.IsDeleted = true;
            entity.Zalihe = 
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Proizvod>(entity);
        }
        public override IQueryable<Database.Proizvod> AddFilter(
            IQueryable<Database.Proizvod> entity, ProizvodSearchObject? obj = null)
        {
            entity = base.AddFilter(entity, obj);
            entity = entity.Where(x => !x.IsDeleted);
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
        public async Task<List<Model.Proizvod>> GetRecommendedProducts(int userId)
        {
          
            var userProductIds = await _context.NarudzbaProizvodi
                .Where(np => np.Narudzba.KorisnikId == userId)
                .Select(np => np.ProizvodId)
                .Distinct()
                .ToListAsync();

            // If user has purchased products, try to find similar users
            if (userProductIds.Any())
            {
                var similarUserIds = await _context.NarudzbaProizvodi
                    .Where(np => np.Narudzba.KorisnikId != userId &&
                                userProductIds.Contains(np.ProizvodId))
                    .Select(np => np.Narudzba.KorisnikId)
                    .Distinct()
                    .Take(5)
                    .ToListAsync();

                if (similarUserIds.Any())
                {
                    var recommendedProductIds = await _context.NarudzbaProizvodi
                        .Where(np => similarUserIds.Contains(np.Narudzba.KorisnikId) &&
                                    !userProductIds.Contains(np.ProizvodId))
                        .GroupBy(np => np.ProizvodId)
                        .OrderByDescending(g => g.Count())
                        .Select(g => g.Key)
                        .Take(3)
                        .ToListAsync();

                    if (recommendedProductIds.Any())
                    {
                        var recommendedProducts = await _context.Proizvod
                            .Where(p => recommendedProductIds.Contains(p.ProizvodId))
                            .ToListAsync();

                        return _mapper.Map<List<Model.Proizvod>>(recommendedProducts);
                    }
                }
            }

            // Fallback: Return most popular products overall
            var fallbackProducts = await _context.Proizvod
                .OrderByDescending(p => p.NarudzbaProizvodis.Sum(np => np.Kolicina))
                .Take(3)
                .ToListAsync();

            if (fallbackProducts.Count < 3)
            {
                var needed = 3 - fallbackProducts.Count;
                var popularProducts = await _context.Proizvod
                    .OrderByDescending(p => p.NarudzbaProizvodis.Sum(np => np.Kolicina))
                    .Where(p => !fallbackProducts.Select(rp => rp.ProizvodId).Contains(p.ProizvodId))
                    .Take(needed)
                    .ToListAsync();

                fallbackProducts.AddRange(popularProducts);
            }
            return _mapper.Map<List<Model.Proizvod>>(fallbackProducts);
        }
    }
}
