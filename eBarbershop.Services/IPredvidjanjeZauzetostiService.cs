using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;

namespace eBarbershop.Services
{
    public interface IPredvidjanjeZauzetostiService : ICRUDService<PredvidjanjeZauzetosti,
        PredvidjanjeZauzetostiSearchObject, 
        PredvidjanjeZauzetostiInsertRequest, 
        PredvidjanjeZauzetostiUpdateRequest>
    {
        Task<eBarbershop.Model.PredvidjanjeZauzetosti> PredvidiZauzetost(int korisnikId, DateTime datum);

    }
}
