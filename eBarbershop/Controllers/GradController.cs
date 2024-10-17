using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class GradController : BaseController<Model.Grad, Model.SearchObjects.GradSearchObject>
    {
        public GradController(ILogger<BaseController<Grad, Model.SearchObjects.GradSearchObject>> logger, IGradService service) : base(logger, service)
        {
        }
    }
}
