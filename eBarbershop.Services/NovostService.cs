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
    public class NovostService : BaseCRUDService<Model.Novost, Database.Novost, NovostSearchObject, NovostInsertRequest, NovostUpdateRequest>, INovostService
    {
        
        public NovostService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }

        
        public override IQueryable<Database.Novost> AddFilter(IQueryable<Database.Novost> entity, NovostSearchObject obj)
        {
            if (!string.IsNullOrWhiteSpace(obj.Naslov))
            {
                entity = entity.Where(x => x.Naslov.ToLower().Contains(obj.Naslov.ToLower()));
            }
            if (obj.DatumOd.HasValue)
            {
                entity = entity.Where(x => x.DatumObjave.Date >= obj.DatumOd.Value);
            }

            if (obj.DatumDo.HasValue)
            {
                entity = entity.Where(x => x.DatumObjave.Date <= obj.DatumDo.Value);
            }

            return entity;
        }
    }
}
