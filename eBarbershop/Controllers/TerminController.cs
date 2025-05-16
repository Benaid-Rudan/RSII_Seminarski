using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class TerminController : BaseCRUDController<Model.Termin, Model.SearchObjects.TerminSearchObject, Model.Requests.TerminInsertRequest, Model.Requests.TerminUpdateRequest>
    {
        public TerminController(ITerminService service) : base(service)
        {
        }
    }
}
