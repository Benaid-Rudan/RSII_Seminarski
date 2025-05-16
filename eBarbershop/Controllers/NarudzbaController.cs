using eBarbershop.Model;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NarudzbaController : BaseCRUDController<Model.Narudzba, Model.SearchObjects.NarudzbaSearchObject, Model.Requests.NarudzbaInsertRequest, Model.Requests.NarudzbaUpdateRequest>
    {

        public NarudzbaController(INarudzbaService service) : base(service)
        {

        }

    }
}
