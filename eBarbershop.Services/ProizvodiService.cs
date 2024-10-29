using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class ProizvodiService : BaseCRUDService<Model.Proizvod, Database.Proizvod, ProizvodiSearchObject, ProizvodiInsertRequest, ProizvodiUpdateRequest>, IProizvodiService
    {
        public ProizvodiService(EBarbershop1Context context, IMapper mapper) : base(context, mapper)
        {

        }
    }
}
