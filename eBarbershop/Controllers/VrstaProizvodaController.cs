using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class VrstaProizvodaController : BaseCRUDController<Model.VrstaProizvoda, Model.SearchObjects.VrstaProizvodaSearchObject, Model.Requests.VrstaProizvodaInsertRequest, Model.Requests.VrstaProizvodaUpdateRequest>
    {
        public VrstaProizvodaController(IVrstaProizvodaService service) : base(service)
        {
        }

        
    }
}
