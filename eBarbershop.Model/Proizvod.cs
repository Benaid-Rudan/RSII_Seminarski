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
        public string Slika { get; set; }
        public int VrstaProizvodaId { get; set; }
       
    }

}
