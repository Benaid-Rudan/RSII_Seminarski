using eBarbershop.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class ProizvodiService : IProizvodiService
    {
        List<Proizvod> proizvodis = new List<Proizvod>()
        {
            new Proizvod()
            {
                ProizvodId = 1,
                Naziv = "Krema za kosu"
            }
        };
        public IList<Proizvod> Get()
        {
            return proizvodis;
        }
    }
}
