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
    public class NotificationService : BaseCRUDService<Notification, Notification, NotificationSearchObject, NotificationUpsertRequest, NotificationUpsertRequest>, INotificationService
    {
        private readonly EBarbershop1Context _db;
        private readonly IMapper _mapper;

        public NotificationService(EBarbershop1Context db, IMapper mapper) : base(db, mapper)
        {
            _db = db;
            _mapper = mapper;
        }

        public override IQueryable<Notification> AddFilter(IQueryable<Notification> entity, NotificationSearchObject obj)
        {
            if (!string.IsNullOrWhiteSpace(obj.Name))
            {
                entity = entity.Where(x => x.Name.ToLower().Contains(obj.Name.ToLower()));
            }

            return entity;
        }

        public override IQueryable<Notification> AddInclude(IQueryable<Notification> entity, NotificationSearchObject obj)
        {
            entity = entity.Include(x => x.User);

            return base.AddInclude(entity, obj);
        }
    }
}
