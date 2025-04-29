using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class NotificationRabbitService : BaseCRUDService<NotificationRabbit,NotificationRabbit, NotificationRabbitSearchObject, NotificationRabbitUpsertDto, NotificationRabbitUpsertDto>, INotificationRabbitService
    {
        private readonly EBarbershop1Context _db;
        private readonly IMapper _mapper;

        public NotificationRabbitService(EBarbershop1Context db, IMapper mapper) : base(db, mapper)
        {
            _db = db;
            _mapper = mapper;
        }
    }
}
