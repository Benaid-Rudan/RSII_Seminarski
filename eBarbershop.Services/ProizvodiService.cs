using eBarbershop.Model;
using eBarbershop.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class ProizvodiService : IProizvodiService
    {
        EBarbershop1Context _context;
        public ProizvodiService(EBarbershop1Context context)
        {
            _context = context;
        }
        List<Model.Proizvod> proizvodis = new List<Model.Proizvod>()
        {
            new Model.Proizvod()
            {
                ProizvodId = 1,
                Naziv = "Krema za kosu"
            }
        };
        public IList<Model.Proizvod> Get()
        {
            //var list = _context.Proizvods.ToList();
            return proizvodis;
        }
    }
}
