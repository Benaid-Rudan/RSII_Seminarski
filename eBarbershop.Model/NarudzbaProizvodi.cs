using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class NarudzbaProizvodi
    {
        public int NarudzbaProizvodiId { get; set; }

        // Veza sa narudžbom
        public int NarudzbaId { get; set; }
        public Narudzba Narudzba { get; set; }

        // Veza sa proizvodom
        public int ProizvodId { get; set; }
        public Proizvod Proizvod { get; set; }

        public int Kolicina { get; set; }
        public decimal Cijena { get; set; }
    }

}
