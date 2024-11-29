using eBarbershop.Model;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SlikaController : BaseCRUDController<Model.Slika, Model.SearchObjects.SlikaSearchObject, Model.Requests.SlikaInsertRequest, Model.Requests.SlikaUpdateRequest>
    {

        public SlikaController(ISlikaService service) : base(service)
        {

        }

    }
}
