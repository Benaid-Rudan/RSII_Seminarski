using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class UlogaController : BaseCRUDController<Model.Uloga, Model.SearchObjects.UlogaSearchObject, Model.Requests.UlogaInsertRequest, Model.Requests.UlogaUpdateRequest>
    {
        public UlogaController(IUlogaService service) : base(service)
        {
        }
    }
}
