using eBarbershop.Model;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProizvodiController : BaseCRUDController<Model.Proizvod, Model.SearchObjects.ProizvodiSearchObject, Model.Requests.ProizvodiInsertRequest, Model.Requests.ProizvodiUpdateRequest>
    {

        public ProizvodiController(ILogger<BaseController<Proizvod, Model.SearchObjects.ProizvodiSearchObject>> logger, IProizvodiService service) : base(logger, service)
        {

        }

    }
}
