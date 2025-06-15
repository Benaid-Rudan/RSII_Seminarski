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
    public class RecenzijaService : BaseCRUDService<Model.Recenzija, Database.Recenzija, RecenzijaSearchObject, RecenzijaInsertRequest,RecenzijaUpdateRequest>, IRecenzijaService 
    {
        
        public RecenzijaService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }
        public override IQueryable<Database.Recenzija> AddInclude(IQueryable<Database.Recenzija> entity, RecenzijaSearchObject? obj = null)
        {
            if (obj.IncludeKorisnik == true)
            {
                entity = entity.Include(x => x.Korisnik); 
            }

            return entity;
        }
        


    }
}
