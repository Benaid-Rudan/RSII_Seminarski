using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [Route("api/rabbit-notifications")]
    [ApiController]
    public class NotificationRabbitController : BaseCRUDController<NotificationRabbit, NotificationRabbitSearchObject, NotificationRabbitUpsertDto, NotificationRabbitUpsertDto>
    {
        public NotificationRabbitController(NotificationRabbitService service) : base(service)
        {
        }
    }
}
