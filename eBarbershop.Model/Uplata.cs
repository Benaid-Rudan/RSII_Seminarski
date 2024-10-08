using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Uplata
    {
        public int UplataId { get; set; }
        public decimal Iznos { get; set; }
        public DateTime DatumUplate { get; set; }
        public string NacinUplate { get; set; } // Npr. kartica, PayPal itd.

        // Veza sa narudžbom
        public int NarudzbaId { get; set; }
        public Narudzba Narudzba { get; set; }
    }
}
