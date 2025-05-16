using eBarbershop.Model;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NovostController : BaseCRUDController<Model.Novost, Model.SearchObjects.NovostSearchObject, Model.Requests.NovostInsertRequest, Model.Requests.NovostUpdateRequest>
    {

        public NovostController(INovostService service) : base(service)
        {

        }

    }
}
