using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class GradController : BaseCRUDController<Model.Grad, Model.SearchObjects.GradSearchObject, Model.Requests.GradInsertRequest, Model.Requests.GradUpdateRequest>
    {
        public GradController(IGradService service) : base(service)
        {
        }
    }
}
