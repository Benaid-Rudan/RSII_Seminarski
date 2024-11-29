using eBarbershop.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [Route("[controller]")]
    //[Authorize]
    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : class
    {
        protected readonly IService<T, TSearch> _service;


        public BaseController(IService<T, TSearch> service)
        {
            _service = service;
        }

        [HttpGet()]
        public async Task<IEnumerable<T>> Get([FromQuery]TSearch search = null)
        {
            return await _service.Get(search);
        }
        [HttpGet("{id}")]
        public async Task<T> GetById(int id)
        {
            return await _service.GetById(id);
        }
    }
}
