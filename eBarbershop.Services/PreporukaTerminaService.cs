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

        public async Task<List<eBarbershop.Model.PreporukaTermina>> GenerirajPreporuke(int klijentId, int uslugaId)
        {
            var historija = await _context.Rezervacija
                .Include(x => x.Termins)
                .Where(x => x.KlijentId == klijentId)
                .ToListAsync();

            var historijaModel = _mapper.Map<List<eBarbershop.Model.Rezervacija>>(historija);

            var preporuke = await _mlService.GenerateRecommendations(klijentId, uslugaId, historijaModel);

            var entities = _mapper.Map<List<Database.PreporukaTermina>>(preporuke);
            await _context.PreporukaTermina.AddRangeAsync(entities);
            await _context.SaveChangesAsync();

            return _mapper.Map<List<eBarbershop.Model.PreporukaTermina>>(entities);
        }



        public async Task<bool> PrihvatiPreporuku(int preporukaId)
        {
            var preporuka = await _context.PreporukaTermina.FindAsync(preporukaId);
            if (preporuka == null)
                return false;

            preporuka.IsAccepted = true;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
