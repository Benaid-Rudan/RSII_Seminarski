using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Services;
using eBarbershop.Services.Database;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    public class UplataController : BaseCRUDController<Model.Uplata, Model.SearchObjects.UplataSearchObject, Model.Requests.UplataInsertRequest, Model.Requests.UplataUpdateRequest>
    {
        private readonly IUplataService _uplataService;

        public UplataController(IUplataService service) : base(service)
        {
            _uplataService = service;
        }

    }

    
}