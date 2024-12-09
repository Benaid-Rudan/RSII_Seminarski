using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Proizvod
    {
        public int ProizvodId { get; set; }
        public string Naziv { get; set; }
        public string Opis { get; set; }
        public decimal Cijena { get; set; }
        public int Zalihe { get; set; }

        // Veza sa vrstom proizvoda
        public int VrstaProizvodaId { get; set; }
        //public virtual VrstaProizvoda VrstaProizvoda { get; set; }
    }

}
