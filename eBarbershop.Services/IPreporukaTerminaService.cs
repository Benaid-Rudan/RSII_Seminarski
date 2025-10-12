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
    public interface IPreporukaTerminaService : ICRUDService<PreporukaTermina, 
        PreporukaTerminaSearchObject, PreporukaTerminaInsertRequest,
        PreporukaTerminaUpdateRequest>
    {
        Task<List<PreporukaTermina>> GenerirajPreporuke(int klijentId, int uslugaId);
        Task<bool> PrihvatiPreporuku(int preporukaId);
    }
}
