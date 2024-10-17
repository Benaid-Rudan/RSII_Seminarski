using eBarbershop.Model;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class DrzavaController : BaseController<Model.Drzava, BaseSearchObject>
    {
        public DrzavaController(ILogger<BaseController<Drzava, BaseSearchObject>> logger
            , IService<Model.Drzava, BaseSearchObject> service) : base(logger, service)
        {
        }
    }
}
