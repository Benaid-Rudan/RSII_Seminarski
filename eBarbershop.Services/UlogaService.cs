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
    public class UlogaService : BaseCRUDService<Model.Uloga, Database.Uloga, UlogaSearchObject , UlogaInsertRequest, UlogaUpdateRequest>, IUlogaService 
    {
        
        public UlogaService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }

        public override IQueryable<Database.Uloga> AddInclude(IQueryable<Database.Uloga> entity, UlogaSearchObject obj)
        {
            if (!string.IsNullOrWhiteSpace(obj.Naziv))
            {
                entity = entity.Where(x => x.Naziv.Contains(obj.Naziv));
            }
            return entity;
        }

    }
}
