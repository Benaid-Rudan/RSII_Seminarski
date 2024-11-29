using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class RecenzijaController : BaseCRUDController<Model.Recenzija, Model.SearchObjects.RecenzijaSearchObject, Model.Requests.RecenzijaInsertRequest, Model.Requests.RecenzijaUpdateRequest>
    {
        public RecenzijaController(IRecenzijaService service) : base(service)
        {
        }
    }
}
