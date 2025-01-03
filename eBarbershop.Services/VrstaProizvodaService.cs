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
    public class VrstaProizvodaService : BaseCRUDService<Model.VrstaProizvoda, Database.VrstaProizvodum, VrstaProizvodaSearchObject, VrstaProizvodaInsertRequest, VrstaProizvodaUpdateRequest>, IVrstaProizvodaService
    {
        
        public VrstaProizvodaService(EBarbershop1Context context, IMapper mapper) : base(context,mapper) {
           
        }
        public override IQueryable<VrstaProizvodum> AddInclude(IQueryable<VrstaProizvodum> query, VrstaProizvodaSearchObject? search = null)
        {
           if (search?.IsProizvodiIncluded == true)
                // Ako je potrebno, uključite proizvode
            {
                query = query.Include(x=>x.Proizvods); // Povezivanje sa proizvodima u entitetu 
                                                    }

            return base.AddInclude(query, search);
        }
       

    }
}
