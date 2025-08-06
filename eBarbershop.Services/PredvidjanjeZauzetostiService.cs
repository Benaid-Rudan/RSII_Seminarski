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
    public class PredvidjanjeZauzetostiService
        : BaseCRUDService<eBarbershop.Model.PredvidjanjeZauzetosti,
                          eBarbershop.Services.Database.PredvidjanjeZauzetosti,
                          PredvidjanjeZauzetostiSearchObject,
                          PredvidjanjeZauzetostiInsertRequest,
                          PredvidjanjeZauzetostiUpdateRequest>,
          IPredvidjanjeZauzetostiService
    {
        private readonly IMachineLearningService _mlService;

        public PredvidjanjeZauzetostiService(EBarbershop1Context context, IMapper mapper, IMachineLearningService mlService)
            : base(context, mapper)
        {
            _mlService = mlService;
        }

        public async Task<Model.PredvidjanjeZauzetosti> PredvidiZauzetost(int korisnikId, DateTime datum)
        {
            var historija = await _context.Termin
                .Where(x => x.KorisnikID == korisnikId && x.Vrijeme < DateTime.Now)
                .ToListAsync();

            var historijaModel = _mapper.Map<List<eBarbershop.Model.Termin>>(historija);

            var predvidjanje = await _mlService.PredictBusyness(korisnikId, datum, historijaModel);

            var entity = _mapper.Map<Database.PredvidjanjeZauzetosti>(predvidjanje);
            await _context.PredvidjanjeZauzetosti.AddAsync(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.PredvidjanjeZauzetosti>(entity);
        }


    }
}
