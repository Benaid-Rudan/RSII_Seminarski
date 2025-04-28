using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class RezervacijaController : BaseCRUDController<Model.Rezervacija, Model.SearchObjects.RezervacijaSearchObject, Model.Requests.RezervacijaInsertRequest, Model.Requests.RezervacijaUpdateRequest>
    {
        RezervacijaService _service;
        public RezervacijaController(IRezervacijaService service) : base(service)
        {
            service = _service;
        }

        

    }
}
