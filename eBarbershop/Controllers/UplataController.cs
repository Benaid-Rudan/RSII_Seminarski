using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class UplataController : BaseCRUDController<Model.Uplata, Model.SearchObjects.UplataSearchObject, Model.Requests.UplataInsertRequest, Model.Requests.UplataUpdateRequest>
    {
        public UplataController(IUplataService service) : base(service)
        {
        }
    }
}
