using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class UslugaService : BaseCRUDService<Model.Usluga, Database.Usluga, UslugaSearchObject, UslugaInsertRequest,UslugaUpdateRequest>, IUslugaService 
    {
        
        public UslugaService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }
        public override IQueryable<Database.Usluga> AddInclude(IQueryable<Database.Usluga> entity, UslugaSearchObject obj)
        {
            if (!string.IsNullOrWhiteSpace(obj.Naziv))
            {
                entity = entity.Where(x => x.Naziv.Contains(obj.Naziv));
            }
            
            return entity;
        }
        public override IQueryable<Database.Usluga> AddFilter(IQueryable<Database.Usluga> entity, UslugaSearchObject? obj = null)
        {

            if (!string.IsNullOrWhiteSpace(obj.Naziv))
            {
                entity = entity.Where(x => x.Naziv.ToLower().StartsWith(obj.Naziv.ToLower()));
            }
            //if (obj.datumRezervacije.HasValue)
            //{
            //    entity = entity.Where(x => x.DatumRezervacije.Date == obj.datumRezervacije.Value.Date); // Poredi samo datum
            //}
            
            return entity;
        }
    }
}
