using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PreporukaTerminaController : BaseCRUDController<PreporukaTermina, PreporukaTerminaSearchObject, PreporukaTerminaInsertRequest, PreporukaTerminaUpdateRequest>
    {
        private readonly IPreporukaTerminaService _service;

        public PreporukaTerminaController(IPreporukaTerminaService service) : base(service)
        {
            _service = service;
        }

        [HttpPost("generiraj/{klijentId}/{uslugaId}")]
        public async Task<List<PreporukaTermina>> GenerirajPreporuke(int klijentId, int uslugaId)
        {
            return await _service.GenerirajPreporuke(klijentId, uslugaId);
        }

        [HttpPut("prihvati/{preporukaId}")]
        public async Task<bool> PrihvatiPreporuku(int preporukaId)
        {
            return await _service.PrihvatiPreporuku(preporukaId);
        }
    }
}
