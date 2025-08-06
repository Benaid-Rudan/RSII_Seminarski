using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PredvidjanjeZauzetostiController : BaseCRUDController<PredvidjanjeZauzetosti, PredvidjanjeZauzetostiSearchObject, PredvidjanjeZauzetostiInsertRequest, PredvidjanjeZauzetostiUpdateRequest>
    {
        private readonly IPredvidjanjeZauzetostiService _service;

        public PredvidjanjeZauzetostiController(IPredvidjanjeZauzetostiService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("predvidi/{korisnikId}")]
        public async Task<PredvidjanjeZauzetosti> PredvidiZauzetost(int korisnikId, [FromQuery] DateTime datum)
        {
            return await _service.PredvidiZauzetost(korisnikId, datum);
        }
    }
}
