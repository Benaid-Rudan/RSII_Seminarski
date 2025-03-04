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

        //[HttpGet("api/usluge/{datum}")]
        //public async Task<IActionResult> GetUslugeForDate(DateTime datum)
        //{
        //    try
        //    {
        //        var usluge = await _service.GetUslugeForDateAsync(datum);
        //        return Ok(usluge); // Vraća listu usluga sa opisima i cijenama
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(new { message = ex.Message });
        //    }
        //}

    }
}
