using eBarbershop.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBarbershop.Controllers
{
    [Route("[controller]")]
    public class BaseCRUDController<T, TSearch, TInsert, TUpdate> : BaseController<T,TSearch> where T : class where TSearch : class
    {
        protected readonly ICRUDService<T, TSearch,TInsert,TUpdate> _service;


        public BaseCRUDController( ICRUDService<T, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _service = service;
        }
        [HttpPost]
        public virtual async Task<T> Insert([FromBody]TInsert insert)
        {
            return await _service.Insert(insert);
        }
        [HttpPut("{id}")]
        public virtual async Task<T> Update(int id, [FromBody]TUpdate update)
        {
            return await _service.Update(id, update);
        }
        [HttpDelete("{id}")]
        public virtual async Task<T> Delete(int id)
        {
            return await _service.Delete(id);
        }
    }
}
