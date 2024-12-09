using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Narudzba
    {
        public int NarudzbaId { get; set; }
        public DateTime Datum { get; set; }
        public decimal UkupnaCijena { get; set; }

        // Veza sa korisnikom
        public int KorisnikId { get; set; }

        public ICollection<NarudzbaProizvodi> NarudzbaProizvodi { get; set; }
    }

}
