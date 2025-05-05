using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [Route("api/notifications")]
    [ApiController]
    public class NotificationController : BaseCRUDController<Notification, NotificationSearchObject, NotificationUpsertRequest, NotificationUpsertRequest>
    {
        public NotificationController(NotificationService service) : base(service)
        {
        }
    }
}
