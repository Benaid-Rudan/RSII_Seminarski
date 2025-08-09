using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eBarbershop.Services
{
    public class PreporukaTerminaService : BaseCRUDService<eBarbershop.Model.PreporukaTermina, eBarbershop.Model.PreporukaTermina, PreporukaTerminaSearchObject, PreporukaTerminaInsertRequest, PreporukaTerminaUpdateRequest>, IPreporukaTerminaService
    {
        private readonly IMachineLearningService _mlService;

        public PreporukaTerminaService(EBarbershop1Context context, IMapper mapper, IMachineLearningService mlService)
            : base(context, mapper)
        {
            _mlService = mlService;
        }

        public async Task<List<Model.PreporukaTermina>> GenerirajPreporuke(int klijentId, int uslugaId)
        {
            var historija = await _context.Rezervacija
                .Include(x => x.Termins)
                .Where(x => x.KlijentId == klijentId)
                .ToListAsync();

            var historijaModel = _mapper.Map<List<Model.Rezervacija>>(historija);

            var preporuke = await _mlService.GenerateRecommendations(klijentId, uslugaId, historijaModel);

            // Create database entities without mapping
            var entities = preporuke.Select(p => new Database.PreporukaTermina
            {
                KlijentId = p.KlijentId,
                KorisnikId = p.KorisnikId,
                UslugaId = p.UslugaId,
                PreporuceniTermin = p.PreporuceniTermin,
                SkorPovjerenja = p.SkorPovjerenja,
                RazlogPreporuke = p.RazlogPreporuke,
                IsAccepted = p.IsAccepted
            }).ToList();

            await _context.PreporukaTermina.AddRangeAsync(entities);
            await _context.SaveChangesAsync();

            // Map back to model without navigation properties
            return entities.Select(e => new Model.PreporukaTermina
            {
                PreporukaId = e.PreporukaId,
                KlijentId = e.KlijentId,
                KorisnikId = e.KorisnikId,
                UslugaId = e.UslugaId,
                PreporuceniTermin = e.PreporuceniTermin,
                SkorPovjerenja = e.SkorPovjerenja,
                RazlogPreporuke = e.RazlogPreporuke,
                IsAccepted = e.IsAccepted
            }).ToList();
        }



        public async Task<bool> PrihvatiPreporuku(int preporukaId)
        {
            var preporuka = await _context.PreporukaTermina.FindAsync(preporukaId);
            if (preporuka == null)
                return false;

            // Check if the time slot is still available
            var isAlreadyBooked = await _context.Termin
                .AnyAsync(t => t.KorisnikID == preporuka.KorisnikId &&
                              t.Vrijeme == preporuka.PreporuceniTermin);

            if (isAlreadyBooked)
            {
                return false; // Time slot is no longer available
            }

            preporuka.IsAccepted = true;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
