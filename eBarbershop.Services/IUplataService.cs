using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface IUplataService : ICRUDService<Model.Uplata, UplataSearchObject, UplataInsertRequest,UplataUpdateRequest>
    {
        Task<Model.Uplata> CreateUplata(UplataInsertRequest request);
    }
}
