using AutoMapper;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore.Metadata.Conventions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class BaseCRUDService<T, TDb, TSearch, TInsert, TUpdate> : BaseService<T, TDb, TSearch> where T : class where TDb : class where TSearch : BaseSearchObject
    {
        public BaseCRUDService(EBarbershop1Context context, IMapper mapper) : base(context, mapper)
        {

        }
        public virtual async Task BeforeInsert(TDb entity, TInsert insert)
        {

        }
        public virtual async Task<T> Insert(TInsert insert)
        {
            var set = _context.Set<TDb>();
            TDb entity = _mapper.Map<TDb>(insert);
            set.Add(entity);
            await BeforeInsert(entity, insert);
            await _context.SaveChangesAsync();
            return _mapper.Map<T>(entity);
        }

        public virtual async Task<T> Update(int id, TUpdate update)
        {
            var set = _context.Set<TDb>();

            var entity = await set.FindAsync(id);
            _mapper.Map(update, entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<T>(entity);
        }
        public async Task<T> Delete(int id)
        {
            var set = _context.Set<TDb>();
            var entity = await set.FindAsync(id);
            var temp = entity;

            if (entity != null)
                _context.Remove(entity);

            await _context.SaveChangesAsync();
            return _mapper.Map<T>(temp);
        }
    }
}
