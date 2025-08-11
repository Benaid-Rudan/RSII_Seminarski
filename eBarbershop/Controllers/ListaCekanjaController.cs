using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class ListaCekanjaController : BaseCRUDController<ListaCekanja, ListaCekanjaSearchObject, ListaCekanjaInsertRequest, ListaCekanjaUpdateRequest>
    {
        private readonly IListaCekanjaService _service;

        public ListaCekanjaController(IListaCekanjaService service) : base(service)
        {
            _service = service;
        }

        [HttpPost("join")]
        public async Task<ActionResult<ListaCekanja>> JoinWaitingList([FromBody] ListaCekanjaInsertRequest request)
        {
            try
            {
                var result = await _service.JoinWaitingList(request);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("leave/{listaCekanjaId}")]
        public async Task<ActionResult<bool>> RemoveFromWaitingList(int listaCekanjaId)
        {
            var result = await _service.RemoveFromWaitingList(listaCekanjaId);
            if (result)
                return Ok(new { message = "Uspješno uklonjeni sa liste čekanja" });
            else
                return NotFound(new { message = "Stavka nije pronađena" });
        }

        [HttpGet("frizer/{frizerId}")]
        [Authorize(Roles = "Admin,Frizer")]
        public async Task<ActionResult<List<ListaCekanja>>> GetWaitingListForBarber(int frizerId, [FromQuery] DateTime? datum = null)
        {
            var result = await _service.GetWaitingListForBarber(frizerId, datum);
            return Ok(result);
        }

        [HttpGet("my-waiting-list")]
        public async Task<ActionResult<List<ListaCekanja>>> GetMyWaitingList()
        {
            var klijentId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var result = await _service.GetMyWaitingList(klijentId);
            return Ok(result);
        }

        [HttpPost("process-slot/{terminId}")]
        [Authorize(Roles = "Admin,Frizer")]
        public async Task<ActionResult> ProcessAvailableSlot(int terminId)
        {
            await _service.ProcessAvailableSlot(terminId);
            return Ok(new { message = "Slot je obrađen i notifikacije su poslane" });
        }

        [HttpPost("respond-notification/{notifikacijaId}")]
        public async Task<ActionResult<bool>> RespondToNotification(int notifikacijaId, [FromBody] NotificationResponseRequest request)
        {
            var result = await _service.RespondToNotification(notifikacijaId, request.Accepted);
            if (result)
            {
                var message = request.Accepted ? "Rezervacija je kreirana" : "Notifikacija je odbačena";
                return Ok(new { message = message, accepted = request.Accepted });
            }
            else
            {
                return BadRequest(new { message = "Notifikacija nije validna ili je istekla" });
            }
        }

        [HttpGet("pending-notifications")]
        public async Task<ActionResult<List<NotifikacijaListeCekanja>>> GetPendingNotifications()
        {
            var klijentId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var result = await _service.GetPendingNotifications(klijentId);
            return Ok(result);
        }

        [HttpPost("optimize")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> OptimizeWaitingListOrder()
        {
            await _service.OptimizeWaitingListOrder();
            return Ok(new { message = "Lista čekanja je optimizovana pomoću ML algoritma" });
        }

        [HttpGet("stats")]
        [Authorize(Roles = "Admin,Frizer")]
        public async Task<ActionResult<WaitingListStats>> GetWaitingListStats([FromQuery] int? frizerId = null)
        {
            var result = await _service.GetWaitingListStats(frizerId);
            return Ok(result);
        }

        [HttpPost("manual-trigger-expired")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> TriggerExpiredNotifications()
        {
            await _service.ProcessExpiredNotifications();
            return Ok(new { message = "Istekle notifikacije su obrađene" });
        }
    }

    public class NotificationResponseRequest
    {
        public bool Accepted { get; set; }
    }
}