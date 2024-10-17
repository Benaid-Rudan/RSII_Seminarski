using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisniciController : ControllerBase
    {
        private readonly IKorisniciService _service;

        private readonly ILogger<WeatherForecastController> _logger;

        public KorisniciController(IKorisniciService service)
        {
            //_logger = logger;
            _service = service;
        }

        [HttpGet()]
        public async Task<List<Model.Korisnik>> Get()
        {
            return await _service.Get();
        }
        [HttpPost()]
        public Model.Korisnik Insert(KorisniciInsertRequest request)
        {
            return _service.Insert(request);
        }
        [HttpPut("{id}")]
        public Model.Korisnik Update(int id,KorisniciUpdateRequest request) {
            return _service.Update(id, request);
        }
    }
}
