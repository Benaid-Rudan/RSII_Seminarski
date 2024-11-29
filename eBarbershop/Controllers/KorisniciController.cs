using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisniciController : BaseCRUDController<Model.Korisnik, Model.SearchObjects.KorisnikSearchObject, Model.Requests.KorisniciInsertRequest,Model.Requests.KorisniciUpdateRequest>
    {
       
        public KorisniciController(IKorisniciService service) : base(service)
        {
            
        }

    }
}
