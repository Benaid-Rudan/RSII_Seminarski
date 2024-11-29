using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class UslugaController : BaseCRUDController<Model.Usluga, Model.SearchObjects.UslugaSearchObject, Model.Requests.UslugaInsertRequest, Model.Requests.UslugaUpdateRequest>
    {
        public UslugaController(IUslugaService service) : base(service)
        {
        }
    }
}
