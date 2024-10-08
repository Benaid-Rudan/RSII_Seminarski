using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class VrstaProizvoda
    {
        public int VrstaProizvodaId { get; set; }
        public string Naziv { get; set; }

        // Veza sa proizvodima
        public ICollection<Proizvod> Proizvodi { get; set; }
    }

}
