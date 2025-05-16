using eBarbershop.Model;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DrzavaController : BaseCRUDController<Model.Drzava, Model.SearchObjects.DrzavaSearchObject, Model.Requests.DrzavaInsertRequest, Model.Requests.DrzavaUpdateRequest>
    {

        public DrzavaController(IDrzavaService service) : base(service)
        {

        }

    }
}
