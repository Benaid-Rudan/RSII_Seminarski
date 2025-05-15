using eBarbershop.Model;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class MailController : ControllerBase
    {
        public IMailService _service;

        public MailController(IMailService service)
        {
            _service = service;


        }

        [HttpPost]
        public async Task<IActionResult> sendMail([FromBody] MailObject obj)
        {
            await _service.startConnection(obj);
            return Ok("Mail sent to queue.");
        }

    }
}
