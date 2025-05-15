using eBarbershop.Model;
using eBarbershop.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProizvodController : BaseCRUDController<Model.Proizvod,
        Model.SearchObjects.ProizvodSearchObject,
        Model.Requests.ProizvodInsertRequest, 
        Model.Requests.ProizvodUpdateRequest>
    {
        IProizvodService _service;

        public ProizvodController(IProizvodService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("recommend")]
        public virtual  List<Model.Proizvod> Recommend(int id)
        {
            return (_service as IProizvodService).Recommend(id);
        }

    }
}
