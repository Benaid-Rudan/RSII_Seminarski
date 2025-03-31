using eBarbershop.Model;
using eBarbershop.Services;
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

        public ProizvodController(IProizvodService service) : base(service)
        {

        }

    }
}
