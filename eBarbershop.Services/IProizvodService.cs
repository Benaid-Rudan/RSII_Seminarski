using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface IProizvodService : ICRUDService<Proizvod,ProizvodSearchObject,ProizvodInsertRequest,ProizvodUpdateRequest>
    {
        Task<List<Model.Proizvod>> GetRecommendedProducts(int id);
    }
}
